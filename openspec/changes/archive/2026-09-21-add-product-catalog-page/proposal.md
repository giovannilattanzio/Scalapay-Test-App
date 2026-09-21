# Proposal

## Why

The repo has a design system but no app: `main.dart` is still the Flutter counter and `routes` is empty. The assessment asks for the Figma catalog screen (`0:3908`, "Product catalog - results"), wired to the Scalapay catalog API, with loading and error states and tests. The design system already carries every component that screen needs, so this change is the first feature that consumes it.

## What Changes

- New `product-catalog` feature across all four layers: search by text, sort (price ascending/descending), filter by price range, and a two-column product grid with infinite scroll.
- Integration with `https://catalog-api.dev-cat.scalapay.com/v1/products/search` through `dio` (the `dev.scalapay.com` host answers 401 and is not used).
- Explicit screen states: empty (no query yet), loading, results, no results, and failure with a retry action; appending further pages has its own states so a failure there never blanks the grid.
- Localization with `easy_localization`, shipping Italian and English; the app locale also drives money formatting in `ScalapayProductCard`.
- The app is wired up for the first time: theme, locale, DI registrations, one route, real `main.dart`.
- Design system corrections now that the Figma frame could be read: the installments line is 14/21 semibold (not 13/20) and the chip label is 11/16.5 semibold (not 12/18 medium), so two typography tokens are added; the product card gains the 12px bottom padding of the Figma frame.
- Unit tests for the repository, the use case and the cubit; widget tests for the page states; goldens updated for the touched design system components.

## Capabilities

### New Capabilities

- `product-catalog`: what the catalog screen shows and how searching, sorting and filtering behave, including every state.
- `product-search-api`: the request the app sends to the catalog API, how a response becomes products, and how transport and parsing errors become failures.
- `app-localization`: supported languages, how a string is resolved, and how the active locale formats money.

### Modified Capabilities

- `design-tokens-theme`: the typography inventory gains the two styles measured on the Figma frame (P2 14/21 semibold, P5 semibold 11/16.5).
- `design-organisms`: the filters bottom sheet gains an optional caller-supplied error message, shown once below the price fields. It still validates nothing; without the message it is unchanged. Discovered during implementation: the screen must report an inverted price range inside the sheet, and the organism exposed no way to show one.

### Non-goals

- Name ordering: the catalog service orders only by selling price, so Figma's "Nome A-Z" and "Nome Z-A" are **not** implemented and the sort sheet offers two options instead of four. This is the one deliberate functional divergence from the design, recorded in the README.
- A product counter or any "x of y" progress: the service reports no total.
- Product detail page, tapping a card, opening the affiliate URL, favourites, categories.
- Active/selected styling on the Filtri and Ordina chips, and a product counter (hidden in Figma).
- Image caching, offline mode, analytics, dark theme.

## Impact

- New: `lib/src/domain/catalog/`, `lib/src/data/catalog/`, `lib/src/presentation/catalog/`, `assets/translations/{it,en}.json`.
- Modified: `lib/main.dart`, `app_router.dart`, `injector.dart`, root `pubspec.yaml` (adds `easy_localization`), `packages/scalapay_ui` typography, chip and product card.
- External dependency: the catalog API must be reachable for the screen to show results.
- The API's corner cases (no name ordering, unknown sort fields accepted and ignored, no total, pagination clamping to page 1 past the end) are documented in `README.md`, since they shape the implementation.
