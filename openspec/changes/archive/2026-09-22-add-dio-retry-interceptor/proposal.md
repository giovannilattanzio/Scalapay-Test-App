## Why

The app's single shared `Dio` has connect/receive timeouts but no recovery: one dropped packet, a cold connection or a transient 503 from the catalog service surfaces immediately as a `NetworkFailure`/`ServerFailure` and the user must retry by hand. Most of these failures are transient and safe to repeat for a read-only search, so the transport should absorb them silently.

## What Changes

- Add a `RetryInterceptor` (Dio `Interceptor`) in the data layer that re-sends a failed request with exponential backoff and jitter, up to a bounded number of retries.
- Define exactly which failures trigger a retry: connection/send/receive timeouts, connection errors, and HTTP 408, 429 (honouring `Retry-After`), 502, 503 and 504, only for idempotent methods.
- Define what never triggers a retry: cancellation, bad certificates, other 4xx answers, 500, unreadable payloads, non-idempotent methods (unless a request opts in).
- Retry timeouts once (they already cost 15 s each) and other transient failures up to twice.
- Make `CatalogCubit` discard the outcome of superseded requests: today nothing stops a slow search from overwriting the results of a newer one, and retry widens that window.
- Allow a per-request override (opt out, or change the retry count) through `Options.extra`.
- Register the interceptor on the shared `Dio` in `_registerCore()`, so the generated `CatalogApi` gets it without changes.
- Once retries are exhausted, the existing `_mapDioException` in `ProductRepositoryImpl` maps the last error to a typed `Failure`, unchanged: presentation never sees retries.

## Capabilities

### New Capabilities
- `http-retry`: when, how often and with what delay the shared HTTP client transparently repeats a failed request, and when it must not.

### Modified Capabilities
- `generated-api-client`: the requirement that the client shares the application's configured transport now also states that the shared retry behaviour applies to it.
- `product-catalog`: results of a request superseded by a newer search, sort or filter are discarded.

## Impact

- New code: `lib/src/data/network/retry_interceptor.dart` (+ barrel export), unit tests under `test/data/network/`.
- Changed code: `lib/src/core/di/injector.dart` (`_registerCore` adds the interceptor to `Dio`); `lib/src/presentation/catalog/cubit/catalog_cubit.dart` (request generation guard).
- Dependencies: none added (hand-written interceptor on `dio ^5.11.1`); `dio_smart_retry` was considered and rejected (see design).
- No change to domain, widgets, `Failure` types or the generated `catalog_api` package.
- Worst-case latency of a failing search grows (see design, Risks).
