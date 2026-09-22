# Proposal

## Why

The catalog screen (`product-catalog` spec) is the app's only screen and its 9 requirements are currently verified only by unit and widget tests, which mock the cubit and the repository. Nothing exercises the real widget tree, the real `CatalogCubit`, and the real DI graph together end to end, so a wiring break between layers (like the base-URL regression the `add-dio-retry-interceptor` tasks call out) would not be caught before manual testing. Integration tests close that gap for the app's primary user journey.

## What Changes

- Add the `integration_test` package and a `test_driver/integration_test.dart` entrypoint to the app.
- Add integration tests driving the real `CatalogPage` (real cubit, real DI via `injector`, a fake `IProductRepository` bound for the test run) covering: initial prompt state, submitting a search, the empty-results and error+retry states, opening the sort sheet and re-sorting, opening the filters sheet and applying a price range, and appending a page via scroll.
- Document how to run the suite (`flutter test integration_test` and the driver command) in the project's testing commands.

## Capabilities

### New Capabilities
- `catalog-integration-tests`: end-to-end coverage of the catalog screen's primary journeys (search, sort, filter, pagination, error/retry) driving the real widget tree and cubit.

### Modified Capabilities
(none — this only adds test coverage, it does not change any screen's required behavior)

## Non-goals

- Not adding integration tests for the design system package (`packages/scalapay_ui`) or its Widgetbook — those use golden tests already.
- Not covering every scenario in the `product-catalog` spec (e.g. tablet width, superseded-request races); the suite targets the primary journeys reachable through real widget interaction, not every edge case already covered by cubit unit tests.
- Not running the suite against a real backend; the fake repository stands in for `catalog_api`/dio.

## Impact

- `pubspec.yaml`: adds `integration_test` as an SDK dev dependency (`sdk: flutter`) — not the discontinued standalone `integration_test` package on pub.dev.
- New `integration_test/` directory and `test_driver/integration_test.dart` in the app root.
- No changes to `lib/src/` production code or existing specs' required behavior.
