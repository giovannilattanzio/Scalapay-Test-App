## Context

`injector.dart` registers one `Dio` (`baseUrl`, 15 s connect and receive timeouts) that the generated `CatalogApi` uses. It has no interceptors. `ProductRepositoryImpl` catches `DioException` and maps it to `NetworkFailure` (timeouts, connection error), `ServerFailure` (any status) or `UnknownFailure`. The only endpoint today is `GET /v1/products/search`, which is idempotent. The design must also be safe for future non-idempotent calls.

## Goals / Non-Goals

**Goals:**
- Transparent, bounded retry of transient failures at the transport level.
- Zero change to domain, presentation, cubits and `Failure` mapping.
- Deterministic and unit-testable (no real sleeping in tests).

**Non-Goals:**
- Cancelling in-flight requests through the domain (a `CancelToken` would leak Dio into `IProductRepository`; see decision 8).
- Connectivity monitoring, offline queues, or a "Retry" button (UI retry stays a presentation concern).
- Circuit breaker, response caching, or auth-token refresh.
- Retrying at the repository or use case level.

## Decisions

**1. Where it lives: a Dio `Interceptor` in `lib/src/data/network/`, added in `_registerCore()`.**
Retry is transport behaviour, so it belongs to the data layer and to the single shared `Dio`; the generated client inherits it (the `generated-api-client` spec already requires sharing that instance). Alternative: retry inside `ProductRepositoryImpl` — rejected, it would need repeating for every repository and would rebuild requests by hand.

**2. Hand-written interceptor, no new dependency.**
`dio_smart_retry` was checked against every requirement below and covers only the interceptor wiring and a retry loop over a fixed `retryDelays` list:
- its default retryable statuses **include 500**, which decision 3 explicitly excludes, so its evaluator would have to be overridden anyway;
- it has no idempotent-method check, so any POST is retried unless the caller opts out — the opposite of decision 3's opt-in;
- `retryDelays` is a fixed list of `Duration`s, not a computed exponential backoff with jitter and a cap (decision 4);
- it does not parse `Retry-After` at all (decision 4);
- it checks `CancelToken` only after the delay has already elapsed, not during it (decision 7 stops the wait itself).

Every one of decisions 3, 4 and 7 would still have to be written by hand as a custom `retryEvaluator` and delay function on top of the package. The dependency's own tests cover its default behaviour, not these requirements, so adopting it would not reduce the code we own or the tests `http-retry` requires — it would only add an external package, with a default that actively conflicts with decision 3, to save the interceptor's ~20 lines of wiring. About 80 lines hand-written in `lib/src/data/network/` covers the wiring too, with no dependency and no default to override.

**3. Trigger cases (all conditions must hold).**
- The method is idempotent (GET, HEAD, PUT, DELETE, OPTIONS), or the request sets `extra['retry'] = true`.
- The error is one of:
  - `connectionTimeout`, `sendTimeout`, `receiveTimeout`, `connectionError` (the same set `_mapDioException` already calls network errors);
  - `badResponse` with status 408, 429, 502, 503 or 504.
- The request was not cancelled and the retry budget is not spent.

Never retried: `cancel`, `badCertificate`, `unknown` (includes parsing errors, which are not `DioException` anyway), status 500 (usually a deterministic server bug; repeating hides it), and every other 4xx (repeating cannot help).

**4. Policy: 2 retries (3 attempts total) for status errors and connection errors, 1 retry for timeouts; exponential backoff with full jitter.**
Timeouts (`connectionTimeout`, `sendTimeout`, `receiveTimeout`) already cost 15 s each, so they get a single retry: enough to recover from a transient slowdown, while bounding the wait (2 attempts, roughly 31 s when each attempt times out at 15 s; a slow connect followed by a receive timeout can push one attempt towards 30 s). Fast failures (connection error, 408/429/502/503/504) are cheap, so they keep 2 retries.
Delay = random(0, min(cap, base × 2^attempt)) with base 500 ms and cap 4 s. For 429/503 with a `Retry-After` header (seconds or HTTP date) the header wins, capped at 10 s so the UI never waits unboundedly; a larger value means no retry. Jitter avoids synchronised retries from many devices.

**5. Re-dispatch through the same `Dio`.**
On a retryable error: increment `extra['retryCount']`, wait, then `dio.fetch(err.requestOptions)` and resolve the handler with the response; if that fails again, the error re-enters `onError` and the count decides whether to continue. When the budget is exhausted the original `DioException` is passed on (`handler.next`), so `_mapDioException` behaves exactly as today.

**6. Per-request control via `Options.extra`.**
`retry: false` opts out, `retry: true` opts a non-idempotent call in, `maxRetries: n` overrides the count. Defaults live in a `RetryPolicy` value object passed to the interceptor; the delay function is injectable (`Future<void> Function(Duration)`), as is the random source, for tests.

**7. Cancellation.**
The wait honours `CancelToken`: if cancelled during the backoff, the interceptor stops and forwards the cancel error instead of re-sending.

**8. Superseded requests are discarded in the cubit, not cancelled in the transport.**
`ProductsApi.searchProducts` accepts a `cancelToken`, but the token cannot travel through `IProductRepository` and `SearchProductsUseCase` without putting a Dio type in the domain. Instead `CatalogCubit` keeps a request generation counter: every `search`, `changeSort`, `applyPriceRange` and `retry` first-page load increments it, each load remembers its value, and a result (success or failure) whose value no longer matches is dropped without emitting. A `loadMore` result is also dropped when the generation changed while it was in flight. The stale request still finishes its (bounded) retries in the background, which costs a little bandwidth but cannot corrupt the screen. Alternative: cancel through the repository — rejected for the layering reason above; it can be added later behind a domain-level cancellation abstraction.

## Risks / Trade-offs

- [Worst-case wait on a slow network: with 1 retry on timeouts, about 31 s before an error shows instead of 15 s, and the screen keeps its plain loading indicator meanwhile] → accepted trade-off; no retry-specific UI is added (non-goal). Revisit the timeouts if the UX is poor.
- [Retrying a non-idempotent call could duplicate a side effect] → methods gated by idempotency, explicit opt-in only.
- [Retry storms against a struggling backend] → jitter, small cap, no retry on 500.
- [Stale results: `CatalogCubit` has no guard against superseded requests, and `_loadFirstPage` / `_appendNextPage` merge into `state.pages` when the request *completes*. A search for "a" that is still retrying can finish after the user searched "b", and its products get appended to the results of "b". The race exists today on slow networks; retry widens the window from about 15 s to about 31 s] → decision 8.
- [Debuggability] → log each retry (attempt, reason, delay) at debug level only.

## Migration Plan

Additive. Register the interceptor in `_registerCore()`; rollback = remove that one line. No data or API migration.

## Open Questions

- Resolved: timeouts, including `receiveTimeout`, are retried once (decision 4).
- Resolved: 2 retries / 500 ms base is confirmed as the policy; no UI feedback beyond the existing loading indicator is added, consistent with the non-goal above.
