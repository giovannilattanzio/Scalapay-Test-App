# Spec Delta

## Purpose

Verifies the catalog screen's primary user journeys end to end through the real widget tree, the real `CatalogCubit` and the real DI graph, catching wiring regressions between layers that mocked unit and widget tests cannot.

## ADDED Requirements

### Requirement: Suite runs against the real app, not mocks
The app SHALL provide an `integration_test` suite that pumps the real `CatalogPage`, resolved through the app's real DI graph (`injector`), with a fake `IProductRepository` implementation bound only for the test run in place of the real data layer. The suite SHALL NOT mock or stub the `CatalogCubit` itself, and SHALL be runnable with `flutter test integration_test`.

#### Scenario: Suite runs standalone
- **WHEN** `flutter test integration_test` is run
- **THEN** every integration test executes against the real widget tree and the real `CatalogCubit`, with only the repository faked

### Requirement: Initial state and search journey coverage
The suite SHALL cover the catalog screen from launch through a successful search: the initial prompt-to-search state, submitting a query through the search field, and the resulting product grid being shown.

#### Scenario: Search from launch
- **WHEN** the app launches and the user types a query into the search field and submits it
- **THEN** the results area first shows the prompt state, then shows the products returned by the fake repository for that query

### Requirement: Empty and error state journey coverage
The suite SHALL cover a search that returns no products, and a search that fails and is retried, verifying the no-results message names the query and that retry re-issues the same request.

#### Scenario: No results
- **WHEN** a search is submitted for a query the fake repository resolves to zero products
- **THEN** the results area shows a no-results message naming that query

#### Scenario: Error then retry
- **WHEN** a search is submitted that the fake repository resolves to a failure, and the user activates the retry control
- **THEN** an error message is shown first, and after retry the results area shows the products the fake repository returns for the same query

### Requirement: Sort journey coverage
The suite SHALL cover opening the sort bottom sheet, choosing an ordering other than the default, and the results reloading in that order.

#### Scenario: Change sort order
- **WHEN** the user opens the sort control, selects price ascending, and the sheet closes
- **THEN** the results area shows the products the fake repository returns for the price-ascending ordering

### Requirement: Filter journey coverage
The suite SHALL cover opening the filters bottom sheet, applying a min/max price range, and the results reloading restricted to that range.

#### Scenario: Apply a price range
- **WHEN** the user opens the filters control, enters a minimum and maximum price, and applies
- **THEN** the results area shows the products the fake repository returns for that price range

### Requirement: Pagination journey coverage
The suite SHALL cover scrolling the results grid far enough to trigger the next page, verifying the appended products are shown without discarding the ones already on screen.

#### Scenario: Scroll appends a page
- **WHEN** the user scrolls the results grid near its end after an initial page of products is shown
- **THEN** the products from the next page returned by the fake repository are appended below the existing ones
