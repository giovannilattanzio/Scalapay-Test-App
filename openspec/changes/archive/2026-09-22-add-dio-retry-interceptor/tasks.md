## 1. Retry policy and interceptor (data layer)

- [x] 1.1 Create `lib/src/data/network/retry_policy.dart`: `RetryPolicy` (maxRetries 2, timeout errors 1, base 500 ms, cap 4 s, max Retry-After 10 s, idempotent methods, retryable statuses) and the `Options.extra` keys `retry` / `maxRetries`
- [x] 1.2 Create `lib/src/data/network/retry_interceptor.dart`: `onError` decides eligibility (design decision 3), computes the delay (backoff with full jitter, or `Retry-After` seconds/HTTP date), waits via an injectable delay function, re-dispatches with `dio.fetch(requestOptions)` and tracks `retryCount` in `extra`
- [x] 1.3 Honour `CancelToken` during the wait and skip cancelled requests
- [x] 1.4 Add a debug-only log per retry (attempt, reason, delay)
- [x] 1.5 Export the new files from `lib/src/data/data.dart` (or a `network/network.dart` barrel following the existing convention)

## 2. Wiring

- [x] 2.1 In `_registerCore()` (`lib/src/core/di/injector.dart`), add `RetryInterceptor` to the shared `Dio` (created after the `Dio` is built, passing that instance)
- [x] 2.2 Extend `test/core/di/injector_test.dart`: the resolved `Dio` contains a `RetryInterceptor` and `CatalogApi` uses that same `Dio`

## 3. Discard superseded requests (presentation)

- [x] 3.1 In `CatalogCubit`, add a request generation counter incremented by `search`, `changeSort`, `applyPriceRange` and the first-page `retry`; capture it in `_loadFirstPage` and `_appendNextPage`
- [x] 3.2 Drop (no `emit`) any success or failure whose captured generation no longer matches, including a `loadMore` that completes after the results were restarted; make sure `loadMoreStatus` is not left on `loading` by a dropped append
- [x] 3.3 Extend `test/presentation/catalog/catalog_cubit_test.dart` (no `cubit/` subfolder) with `Completer`-based use case fakes: late "a" after "b" (success and failure), late page after a sort change, and the unchanged normal flow

## 4. Tests

- [x] 4.1 `test/data/network/retry_interceptor_test.dart` with a fake `HttpClientAdapter` and a no-op delay: retries on timeout, connection error, 408/429/502/503/504
- [x] 4.2 Same file: no retry on 400/404/422, 500, cancel, bad certificate, POST without opt-in
- [x] 4.3 Same file: budget stops at 3 attempts (timeouts at 2), recovery on the 2nd attempt returns the response, per-request opt-out / opt-in / `maxRetries`
- [x] 4.4 Same file: recorded delays grow and never exceed 4 s; `Retry-After: 2` is used; `Retry-After: 60` prevents the retry
- [x] 4.5 Redirected to `test/data/network/retry_interceptor_test.dart` (real `Dio` + `RetryInterceptor` + generated `CatalogApi` + `ProductRepositoryImpl`, no mocktail): persistent timeout → `NetworkFailure`, persistent 503 → `ServerFailure(503)`. `product_repository_impl_test.dart` mocks `ProductsApi` directly with no `Dio` in the loop, so it cannot exercise the interceptor; left unchanged.

## 5. Verification

- [x] 5.1 `dart format lib test`, `flutter analyze`, `flutter test`
- [x] 5.2 Verify by hand one real search against the catalog service with the network toggled off and on, confirming the retry in the debug log (not only mocked tests) — confirmed by the user against a real device with no connectivity: `connectionError` retried twice (attempts 2 and 3, the non-timeout budget) with delays of 132 ms and 220 ms, within the expected jitter bounds (≤500 ms then ≤1000 ms), then no further attempt
