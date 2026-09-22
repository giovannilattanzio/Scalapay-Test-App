# Design

## Context

See proposal.md - Why. Relevant current state:
- `CatalogPage` (`lib/src/presentation/catalog/pages/catalog_page.dart`) builds its `CatalogCubit` inline from `injector<SearchProductsUseCase>()` — the cubit is not itself registered in `injector` (only its dependency chain is), so the real widget tree can be pumped with a real cubit as long as `injector` is set up first.
- `injector` (`lib/src/core/di/injector.dart`) registers `IProductRepository` as a lazy singleton built from `ProductsApi`/`Dio`. Swapping that single registration for a fake, before anything resolves `SearchProductsUseCase`, is enough to keep every other layer (cubit, use case, page) real while removing the real network call.
- `test/helpers/pump_app.dart` already solves `easy_localization` setup for `flutter_test` widget tests, including a `_FileAssetLoader` workaround for a `rootBundle` hang observed there. `integration_test` runs on a full engine (device/simulator/Chrome), not the same headless `flutter_test` binding, so that hang may not reproduce; this design does not assume either way (see Risks).
- There is exactly one screen/route (`AppRoutes.catalog` → `CatalogPage`), so `createRouter()` can be exercised directly instead of hand-building a `MaterialApp` around `CatalogPage`.

## Goals / Non-Goals

**Goals:**
- Define how the suite gets a real `CatalogPage` on screen with a real `CatalogCubit`, real `SearchProductsUseCase`, and only the repository faked.
- Define the fake repository's shape so every journey in the spec (search, empty, error+retry, sort, filter, pagination) can be scripted without a bespoke fake per test.
- Define test isolation: each test starts from a clean `injector` state.

**Non-Goals:**
- Wiring the suite into CI (noted as a risk/follow-up, not designed here).
- A page-object abstraction layer; six journeys do not justify one.
- Covering every `product-catalog` scenario (tablet width, superseded-request races) — out of scope per proposal.md Non-goals.

## Decisions

### 1. Drive the real app shell via `createRouter()`, not a hand-built `MaterialApp`
Pump `MaterialApp.router` with `routerConfig: createRouter()` inside the same `EasyLocalization` wrapper `main.dart` uses, rather than reusing `pump_app.dart`'s `Scaffold(body: CatalogPage())` shortcut. This exercises `go_router` too, which `pump_app.dart` deliberately skips for widget tests. A small `integration_test/support/pump_catalog_app.dart` helper wraps this so no test repeats the boilerplate.

**Alternative considered**: reuse `pump_app.dart` as-is. Rejected — it bypasses the router, which is part of the real wiring this suite exists to catch regressions in.

### 2. Fake the repository with a function, not canned per-scenario classes
`FakeProductRepository implements IProductRepository` takes a single `Future<Result<ProductSearchResult>> Function(ProductSearchParams) onSearch` and delegates `searchProducts` to it. Each test supplies its own closure inspecting `params.query`/`params.sort`/`params.priceRange`/`params.page`.

**Alternative considered**: a map of canned `ProductSearchParams -> Result`. Rejected — six journeys need different logic (e.g. pagination needs page-aware responses, error+retry needs a call counter), and a closure covers all of them with one fake class instead of several.

### 3. Full injector reset between tests, repository swapped after re-setup
Every test's `setUp` calls `await injector.reset()`, then `await setupInjector()`, then replaces the registration:
```dart
injector.unregister<IProductRepository>();
injector.registerLazySingleton<IProductRepository>(() => FakeProductRepository(onSearch: ...));
```
before pumping. Resetting the whole graph (not just swapping the repository) guarantees no test depends on registration order or on a previous test's already-built `SearchProductsUseCase` singleton, which would otherwise keep pointing at a stale repository instance.

**Alternative considered**: swap only `IProductRepository` without a full reset. Rejected — if any earlier test already resolved `SearchProductsUseCase` (which happens on the first `CatalogPage` build), that singleton has already closed over the old repository and a later swap would not reach it.

### 4. One `test_driver/integration_test.dart` shim, tests split by journey
Add the standard `integrationDriver()` shim so the suite is runnable both by `flutter test integration_test` (desktop/web/Android/iOS local run) and `flutter drive` (device farms), per Flutter's convention. Split test files by journey under `integration_test/` (`catalog_search_test.dart`, `catalog_sort_test.dart`, `catalog_filter_test.dart`, `catalog_pagination_test.dart`, `catalog_error_retry_test.dart`) rather than one file, so a failure names the journey directly.

## Risks / Trade-offs

- **Real animations/timers make integration tests slower and more flake-prone than widget tests** → Mitigation: bound every `pumpAndSettle()` with an explicit `timeout`, and prefer waiting on a specific `find` condition over broad settling when opening the sort/filter bottom sheets.
- **`easy_localization`'s asset loading might not behave the same under `integration_test`'s binding as under `pump_app.dart`'s `flutter_test` workaround** → Mitigation: the first `[tooling]` task verifies a translated string renders before any journey test is written; if `rootBundle` hangs the same way it did for widget tests, fall back to `pump_app.dart`'s `_FileAssetLoader` pattern inside the integration helper.
- **Sharing the `injector` singleton across tests in one binary risks state leaking if a test skips the reset** → Mitigation: the reset/re-register/swap sequence in Decision 3 lives in one shared helper (`integration_test/support/pump_catalog_app.dart`), not copy-pasted per file.
- **No CI wiring** → out of scope (Non-Goals), but the suite only protects against regressions once someone runs it; flagged here so it is not silently forgotten.
