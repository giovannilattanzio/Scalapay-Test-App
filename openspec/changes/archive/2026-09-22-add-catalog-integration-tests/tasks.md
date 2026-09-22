# Tasks

## 1. Setup

- [x] 1.1 [tooling] Add `integration_test` to `pubspec.yaml`'s `dev_dependencies` as an SDK dependency (`sdk: flutter`, not a pub.dev version — the standalone pub.dev package is discontinued/pre-Dart-3) and verify `flutter pub get` succeeds
- [x] 1.2 [tooling] Add the `test_driver/integration_test.dart` driver shim (design.md Decision 4), via the `dart-flutter:flutter-add-integration-test` skill, and verify `flutter test integration_test` runs (even with zero test files yet) without error

## 2. Test support

- [x] 2.1 [tooling] Add `integration_test/support/fake_product_repository.dart` implementing `IProductRepository` as the function-based fake from design.md Decision 2, and verify it compiles and satisfies `IProductRepository`
- [x] 2.2 [tooling] Add `integration_test/support/pump_catalog_app.dart` implementing design.md Decisions 1 and 3 (pumps `MaterialApp.router` with `createRouter()` inside `EasyLocalization`, and performs the `injector.reset()` -> `setupInjector()` -> swap-in-fake sequence), and verify a smoke test using it shows the catalog screen's initial prompt state (Requirement: Suite runs against the real app, not mocks) — if `easy_localization` asset loading hangs the way it did for `pump_app.dart`, fall back to that file's `_FileAssetLoader` pattern here (design.md Risks)

## 3. Journey tests

- [x] 3.1 [tooling] Add `integration_test/catalog_search_test.dart` covering the initial state and a submitted search returning products (Requirement: Initial state and search journey coverage) and verify it passes under `flutter test integration_test`
- [x] 3.2 [tooling] Add `integration_test/catalog_error_retry_test.dart` covering a no-results search and a failed search retried successfully (Requirement: Empty and error state journey coverage) and verify it passes
- [x] 3.3 [tooling] Add `integration_test/catalog_sort_test.dart` covering opening the sort sheet and choosing an ordering (Requirement: Sort journey coverage) and verify it passes
- [x] 3.4 [tooling] Add `integration_test/catalog_filter_test.dart` covering opening the filters sheet and applying a price range (Requirement: Filter journey coverage) and verify it passes
- [x] 3.5 [tooling] Add `integration_test/catalog_pagination_test.dart` covering scrolling to append a further page (Requirement: Pagination journey coverage) and verify it passes

## 4. Verification and docs

- [x] 4.1 [tooling] Run the full suite with `flutter test integration_test` and verify all five journey tests pass together in one run, not only individually
- [x] 4.2 [tooling] Document the run command in `CLAUDE.md`'s Commands section, next to the existing `flutter test` line, and verify the documented command matches the one actually used in 4.1
- [x] 4.3 [tooling] Run `dart format lib test integration_test test_driver`, then `flutter analyze`, and verify both report no issues
