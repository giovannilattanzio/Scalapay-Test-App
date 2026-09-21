# Design

## Context

See proposal.md — Why. The relevant current state:

- The app shell is empty: `main.dart` is the Flutter counter, `AppRoutes` has no constant, `routes` is `[]`, `setupInjector` registers nothing, and `Dio` is a dependency that is never constructed.
- `packages/scalapay_ui` already provides every component this screen needs: `ScalapaySearchField`, `ScalapayFilterChip`, `ScalapayProductCard`, `ScalapayFiltersBottomSheet.show`, `ScalapaySortBottomSheet.show`, `ScalapayButton`, `ScalapayIcon` with `filter`/`order`/`search`/`close`, and `context.tokens`.
- Figma access was restored for this change through the REST API (the MCP server is capped by the Figma plan). Frames read: `0:3908` (results), `0:4054` (filters sheet open), `0:4205` (sort sheet open). This closes the follow-up the product-card change left open ("re-read node `0:3926` when access returns and adjust values only").

### What the Figma frame actually says

Measured on `0:3908` (375 wide), top to bottom:

| Region | Measurement |
| --- | --- |
| Status bar | 44 (system, `SafeArea`) |
| Back arrow | **hidden** (`visible: false`), but its 56x65 slot still occupies the layout, leaving 57 of empty space between the status bar and the title |
| Title "Esplora i prodotti" | Poppins 600 25/30 (`h2`), horizontal padding 26 |
| Title → search field | 10 |
| Search field | 343x55, horizontal padding 16; its "Cerca" label is **hidden**, so the action button is icon-only |
| Toolbar row | height 58 = padding 8 + 42 + 8; a "18 prodotti" counter exists but is **hidden**; the two chips are trailing-aligned with a gap of 8 |
| Chip | height 32, fill `#F6F7FB`, radius 100, icon 20, label Poppins **600 11/16.5** |
| Grid | horizontal padding 16, two columns of 164, column gap 16, **no row gap** |
| Card image area | 164x195, radius 20, fill `#F6F7FB` |
| Card text block | 164x154, padding (top 12, right 8, **bottom 12**, left 8) |
| Name | Poppins 600 13/20 `#272727`, 2 lines |
| Store | Poppins 500 12/18 `#3A4045` |
| Price line | Poppins 500 12/18 `#8A8A8D` — "85,00€ or" |
| Instalments line | Poppins **600 14/21** `#5666F0`, wraps to 2 lines |
| Card total | 349 = 195 + 154 |

Checked against the built screen (task 7.2), rendered at 375x812 with the real Poppins metrics and the geometry measured rather than eyeballed. Every row above reproduces exactly — title at y=57 with 26 padding, search field 343x55 at 16, toolbar band 152→210 (58) with the chips 32 high and trailing-aligned to 359, grid columns 163.5 with a 16 gap and no row gap — with **one accepted divergence**:

- **Grid cell 364.4 instead of the card's 349.** The `spacing.s` cushion of Decision 9 adds ~15px per row at text scale 1.0, where it is pure slack; it earns its place at 1.5, where the bare figure overflows by ~15px. Rows therefore sit ~15px further apart than Figma. Accepted: the alternative is a layout that overflows for anyone who enlarges the system font.

Two further divergences are deliberate and recorded elsewhere rather than being layout errors: the sort sheet offers **two** options instead of Figma's four (Decision 3 — the service cannot order by name), and money is formatted by locale rather than copying Figma's inconsistent "85,00€" / "€23,33" pair (Decision 8). The hidden back arrow and the hidden product counter are reproduced as hidden, which is why the 57px slot exists and no counter is drawn.

Three of these disagree with what is built today: the chip label is `p4` (12/18 medium) instead of 11/16.5 semibold, the instalments line is `p3` (13/20) instead of 14/21, and the card has no bottom padding.

Sheet copy read from `0:4054` and `0:4205`: "Filtri" / "Fascia di prezzo" / "Minimo" / "Massimo" / "Cancella tutto" / "Mostra risultati", and "Ordina" / "Prezzo crescente" / "Prezzo decrescente" / "Nome A-Z" / "Nome Z-A".

### What the API actually does

Verified against the live service while writing this document:

- `catalog-api.dev-cat.scalapay.com` answers 200; `catalog-api.dev.scalapay.com` answers **401**, so only the first host is usable.
- The response is `{page, found, facet_counts, grouped_hits, merchantDetectedFromQuery}`; each entry of `grouped_hits` is `{hits: [{document: {...}}]}` with one hit per group in practice.
- A document carries `id`, `title`, `merchant`, `merchantId`, `brand`, `brandId`, `image`, `image_merchant`, `selling_price`, `list_price`, `discount_percentage`, `category`, `description`, `url`, `affiliate_url`, `tags`, `new_offer`, `has_image`.
- **`selling_price` and `list_price` arrive as `int` or `double`** depending on the product (13 vs 13.38).
- `minPrice` works alone, `maxPrice` works alone, and both work with any sort. An empty `q` returns `found: 0`.
- `sort_by` has exactly **three** distinguishable behaviours, measured by comparing the returned product ids:
  - `selling_price:asc` — genuinely reordered, ascending.
  - `selling_price:desc` — genuinely reordered, descending.
  - **everything else** — one single default order, byte-identical across `_text_match:desc`, `_text_match:asc`, `text_match:desc`, `text_match:asc`, `title:asc`, `title:desc`, `name:asc`, `brand:asc`, `garbage:asc`, `sort_by=` empty, and `sort_by` omitted entirely.

- **What "relevance" is.** `_text_match` is a score of a *document against the query text*, not a property of a product: it does not exist without `q`, and the same catalogue reorders completely for a different query. Measured properties: it is **deterministic** (the same query returns the same order on repeated calls) and **consistent across page sizes** (`per_page=60` page 1 equals `per_page=30` pages 1 and 2 concatenated). It is **opaque**: each hit contains only `document`, with no `text_match` or score field, so the app can neither inspect nor reproduce it. It is **not invertible**: `_text_match:asc` equals `_text_match:desc`, so "least relevant first" is unobtainable. It matches across several fields, not just the title — `q=air force` surfaces titles containing "Air Force 1", while `q=scarpe running` surfaces running shoes whose titles contain neither word (New Balance 9060, HOKA Clifton), so category and description participate. `merchantDetectedFromQuery` is a separate signal that fires only when the whole query is a known brand (`nike` yes, `nike air force` no); it feeds a merchant banner, not the ordering. For this app, therefore, relevance is best defined by provenance rather than by algorithm: **the order the service returns when we do not ask for a price sort**.

- **Pagination clamps instead of ending.** Pages are disjoint and ordered while they last, but past the last one the service returns **page 1 again**, byte-identical, rather than an empty page or an error. Measured at `per_page=30` on four unrelated queries (`nike`, `adidas`, `borraccia`, `profumo`): every one gives **exactly 10 distinct pages, and page 11 repeats page 1**. It is a clamp, not a modulo — pages 11, 12, 13, 14, 15, 40, 100 and 500 all return page 1, never page 2. A **partial page never occurs**: every page of every query returns exactly `per_page` items, including the last real one. The reachable window moves with the page size (10 pages at 30, 7 at 50, 4 at 100), so it is not a constant the client may hardcode.

  Together with `found` never being a total, the service therefore offers **no end-of-list signal whatsoever**: neither a short page, nor an empty page, nor a count, nor an error. A naive "load more" loop would cycle over the same 300 products forever. The client derives the end itself, from the products it has already seen — see Decision 15.

  Three consequences follow. An unsupported sort field is **accepted and ignored**, never rejected, so asking for a name sort would quietly return relevance order under a "Nome A-Z" label — this is why **there is no server-side name ordering**. The leading underscore is not significant: `text_match` is not a second spelling of relevance, it is simply another ignored field that lands in the default bucket. And the **direction is ignored on relevance too** (`_text_match:asc` equals `_text_match:desc`), so relevance has one form, not two. The app still sends `_text_match:desc` for relevance rather than omitting `sort_by`, because that is the spelling the assessment document prescribes and an explicit parameter is easier to read in a log than an absent one.

## Goals / Non-Goals

**Goals:**

- One catalog feature, layer-first, whose presentation never imports data.
- Only orderings the service performs across the whole result set, so the list stays correct as pages are appended.
- The end of the results derived where it is testable without a widget or a socket.
- A design system corrected against Figma in the same change that first consumes it, so the screen and the components cannot drift apart.
- Tests that never touch the network.

**Non-Goals (design level, beyond the proposal's):**

- A generic HTTP layer: one typed data source for one endpoint, no interceptor stack, no retry policy beyond the user-driven retry.
- A locale-switching UI: the language follows the device.
- Reading `found` for a product counter, or `facet_counts` for the price bounds — the Figma counter is hidden and the filter fields are free input.

## Decisions

**1. The catalog is one feature across the four layers, named `catalog`.**
`lib/src/{domain,data,presentation}/catalog/`. Alternative: split "search" and "filters" into separate features; rejected because they share one query object and one result list, so splitting them would only move the coupling into the DI graph.

**2. A sort is a sort type plus a direction, matching the API's own parameters.**
The assessment document describes ordering as `sort_by=${sortType}:${sortDirection}`, so the domain models it the same way: `ProductSort` is the pair `(ProductSortType type, SortDirection direction)` rather than a flat list of opaque names. The repository then builds `sort_by` mechanically as `'${type.field}:${direction.name}'` with no per-option branching, and the day the service makes another field sortable it is one enum entry, not a new case in a `switch`. Alternative: a flat `enum ProductSort { relevance, priceAsc, priceDesc }`; rejected because it hides the two API parameters inside names the mapping has to re-derive at every call site.

**3. Name ordering is not offered at all. This is the one deliberate functional divergence from Figma.**
`selling_price` is the only field the service actually orders by: `title`, `brand`, `merchant`, `list_price`, `discount_percentage`, `id`, `category`, `new_offer` and `has_image` all return the relevance order in both directions, and the multi-field form `title:asc,selling_price:asc` is parsed with the unknown field simply dropped. Ordering by name server-side is therefore impossible.

Doing it client-side is possible only without pagination, and pagination is now in scope (Decision 15). Sorting the current page reorders 30 of ~300 products: measured on `q=nike`, page 1 would run A→S and page 2 would restart at A, with **22 of page 2's 30 products belonging before the end of page 1**. That is not an imprecise ordering, it is two separate alphabetical lists shown one after the other, and a "Nome A-Z" label on it would be a lie the user cannot detect.

So the sort sheet offers two options, "Prezzo crescente" and "Prezzo decrescente", instead of Figma's four. Alternatives: keeping the two name options disabled with an explanation (rejected — it exposes a backend limitation in the product UI for no user benefit); loading one large page when a name sort is chosen and disabling infinite scroll (rejected — the same option would silently mean "the alphabetical order of an arbitrary subset", and the inconsistency between sort modes is harder to explain than a missing option); dropping pagination to keep the four options (rejected by the user, who chose pagination). The README records the divergence and why.

**4. Relevance is the default sort and is not offered in the sheet.**
`ProductSort.relevance` is `(relevance, desc)` and maps to `_text_match:desc` — the assessment's "GENERIC SORTING" example. The direction on relevance is inert (`_text_match:asc` equals `:desc`, measured) and is kept only so the pair stays uniform.

**Relevance is offered in the sheet**, first, and an earlier draft of this design was wrong to leave it out. That draft reasoned that Figma preselects nothing in the "results" frame, so the default had to be a value outside the sheet — which is true of the *initial* frame and false of everything after it. With only the two price options, choosing one made relevance unreachable: a one-way door out of the default ordering, with no reset anywhere on the screen. Figma shows four options and never shows the screen after a choice, so the mockup could not reveal this. The sheet therefore offers three: relevance, price ascending, price descending, with the current sort always preselected — including relevance, which removes the `selected: null` special case entirely.

**5. The language reaches the data layer through the cubit's state, not through a global.**
`CatalogState.languageCode` is set by `CatalogView.didChangeDependencies` from `context.locale.languageCode` and travels inside `ProductSearchParams`. Alternatives: a `ValueGetter<String>` registered in `get_it` and closed over `EasyLocalization` (hidden global, awkward to test), or hardcoding `it` (contradicts the localization spec). The chosen form keeps the data layer context-free and the language visible in every cubit test.

**6. Price bounds are an optional pair, validated in the cubit.**
`PriceRange(min: double?, max: double?)`; an unset bound is omitted from the query string rather than sent as `0` — verified that the service accepts one bound alone. The inverted-range check (`min > max`) happens in the cubit before any request, because the sheet is a content-only organism that does not validate. The sheet stays open and shows the error through its fields' error text.

**7. The instalment count is domain data, not a magic number in a widget.**
`Product.installmentCount = 3` and `Product.installmentAmount => sellingPrice / installmentCount`. Figma's own placeholder is inconsistent (85,00 € shown as 3 × 23,33), so the computed value is used, not the mockup's.

**8. Money keeps the locale-driven format already decided for the card.**
Figma renders the price as "85,00€" and the instalment as "€23,33" — two different conventions in the same card. The product-card change already decided, with the user, that `intl` and the app locale win over a fixed string; that decision stands, so Italian renders "85,00 €" in both places. This is a deliberate, documented divergence from the mockup.

**9. The grid sizes its cells from the design ratio and the text scale.**
`LayoutBuilder` + `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 220, crossAxisSpacing: 16, mainAxisSpacing: 0)` with an explicit `mainAxisExtent = cellWidth * 195 / 164 + textScaler.scale(154 + spacing.s)`. **The bare 154 undershoots**, measured during implementation: Figma's nominal text block does not survive real font metrics, and using it produced `RenderFlex overflowed` of about 1px at text scale 1.0 and about 15px at 1.5. A `spacing.s` cushion inside the scaled quantity — so it grows with the text, rather than added as a fixed tail — removes both. The figure in the measurement table above stays 154 because that is what Figma says; this is the implementation's correction to it. This gives two columns at 375 (163.5 each, matching Figma's 164), four at tablet width, and it grows the cell instead of clipping when the user enlarges the system font. Alternative: a fixed `childAspectRatio` of 164/349; rejected because it overflows as soon as the text scale rises above 1.0.

**10. The title, the search field and the toolbar are all fixed; only the results scroll.**
An earlier draft had the toolbar scroll away with the results, inferred from the Figma file's own grouping: the header frame is a sibling of the scrolling group, and the chips row is the first child of that group. The user overrode it, and the override is right — a control that changes what the results *are* should not require scrolling back to the top to reach, which is exactly what a long grid makes you do. The Figma grouping describes how the mockup was assembled, not a scroll behaviour it can demonstrate in a single static frame.
Implemented as a `Column` of `CatalogHeader` + `CatalogToolbar`, then an `Expanded` `CustomScrollView` holding only the result slivers.

**11. Design system: two new typography tokens rather than reusing `button`.**
`p2` (14/21 semibold) has the same metrics as the existing `button` token, but a price line is not a button; reusing it would make every future change to the button style leak into product cards. `p5Semibold` (11/16.5 semibold) sits beside `p5`. The chip's asymmetric Figma paddings (8/10 on "Filtri", 4/8 on "Ordina") and the 24px "Ordina" icon are **not** reproduced: both chips keep the symmetric 8 padding and the 20px icon, because the drawn glyphs measure ~13x16 and ~13x13 and read as the same size.

**12. Failures stay typed; the screen maps them to translated messages.**
`CatalogState.failure` holds the `Failure` and the view chooses the key from its type (`NetworkFailure`, `ServerFailure`, `SerializationFailure`, else generic). No message text crosses the data layer.

**13. Page, page size and language are call parameters, not baked-in constants.**
`page`, `perPage` and `languageCode` travel on `ProductSearchParams` and reach the data source as named arguments, with `kDefaultPage = 1`, `kDefaultPerPage = 30` and `kDefaultLanguageCode = 'it'` as defaults so no call site has to repeat them. Only the partner identity (`partnerId`, `source`, `country`) stays constant, because it identifies this app rather than a given search. Decision 15 builds the infinite scroll on top of exactly these parameters, without changing a signature. Alternative: constants in `CatalogApi` read directly by the data source; rejected because it hides two request parameters from every test and from the use case that would need to vary them.

**14. Use cases are named with the `UseCase` suffix.**
Every use case class ends in `UseCase` and lives in a file ending in `_use_case.dart`: `SearchProductsUseCase` in `search_products_use_case.dart`. The suffix makes a class's clean-architecture role readable from an import line or a file tree, which matters in a layer-first structure where `domain`, `data` and `presentation` hold similarly named types. This is a project-wide convention, not a choice local to this change, so it is also recorded in the `design` rules of `openspec/config.yaml` and, by task 7.4, in `CLAUDE.md` and the `flutter-domain` agent.

**15. Pagination ends when a page brings no new product id.**
The service gives no end-of-list signal of any kind: no total, no short page, no empty page, no error — past the last page it returns page 1 again (measured identically on `nike`, `adidas`, `borraccia` and `profumo`: exactly 10 pages at `per_page=30`, then page 11 repeats page 1). So the client decides.

`ProductPageAccumulator` is a pure domain value object holding the products so far, the set of ids already seen and the next page to ask for. `append` keeps only the products whose id is new; **if none is new, the catalogue is exhausted and nothing is appended**. Two further stops back it up: a page shorter than `perPage` (never observed today, but it is the standard contract and would work the day the service is fixed), and a hard `maxPages` of 50, far above the ~10 observed, so the loop terminates even against a service that returned fresh items forever.

Filtering on the id set rather than comparing the incoming page with page 1 is the point of the design. Comparing with page 1 is cheaper but strictly weaker: it would miss a partial overlap, and a partially overlapping page would render duplicate cards — which the user would read as a bug in the app, not in the service. Deduplication is what protects the UI, and the end signal falls out of it for free. The cost is a `Set<String>` of a few hundred ids.

The accumulator lives in the domain so the rule is a plain unit test that can replay the exact observed behaviour — ten distinct pages then page 1 again — and assert that loading stops at ~300 products with no duplicates, without HTTP, widgets or `bloc_test`. The cubit holds one in its state and replaces it with a fresh one on every change of query, sort or price filter. `LoadMoreStatus` is separate from `CatalogStatus` so that a failure while appending leaves the grid on screen and shows a retry in the footer, instead of replacing results the user is reading with an error page.

### Contracts

**`lib/src/domain/catalog/`**

```dart
// entities/product.dart
class Product extends Equatable {
  const Product({required this.id, required this.name, required this.store,
    required this.brand, required this.imageUrl, required this.sellingPrice,
    required this.listPrice});
  final String id, name, store, brand, imageUrl;
  final double sellingPrice, listPrice;
  static const installmentCount = 3;
  double get installmentAmount => sellingPrice / installmentCount;
}

// entities/product_search_result.dart
/// No total: the payload's `found` equals the number of items returned, so it
/// is read in the data layer and deliberately not carried into the domain.
class ProductSearchResult extends Equatable {
  const ProductSearchResult({required this.products, required this.page});
  final List<Product> products; final int page;
}

// entities/product_sort.dart
/// `field` is the value the service accepts in `sort_by`. Only these two are
/// honoured; every other field name is accepted and ignored by the service.
enum ProductSortType { relevance('_text_match'), sellingPrice('selling_price');
  const ProductSortType(this.field); final String field; }

enum SortDirection { asc, desc }

class ProductSort extends Equatable {
  const ProductSort({required this.type, required this.direction});
  static const relevance = ProductSort(type: ProductSortType.relevance, direction: SortDirection.desc);
  static const priceAsc  = ProductSort(type: ProductSortType.sellingPrice, direction: SortDirection.asc);
  static const priceDesc = ProductSort(type: ProductSortType.sellingPrice, direction: SortDirection.desc);
  /// The combinations the sort sheet offers, in order. Name ordering is absent
  /// on purpose: the service cannot do it — see Decision 3.
  static const sheetOptions = [priceAsc, priceDesc];
  final ProductSortType type; final SortDirection direction;
  String get queryValue => '${type.field}:${direction.name}';
}

// entities/product_page_accumulator.dart
/// Accumulates pages into one list and decides when the catalogue is
/// exhausted. Past its last page the service returns page 1 again instead of
/// an empty page, so "this page brought no new id" is the only end signal
/// available — see Decision 15.
class ProductPageAccumulator extends Equatable {
  const ProductPageAccumulator({this.products = const [], this.seenIds = const {},
    this.nextPage = kDefaultPage, this.hasReachedEnd = false});
  final List<Product> products; final Set<String> seenIds;
  final int nextPage; final bool hasReachedEnd;
  static const maxPages = 50; // hard stop, far above the ~10 observed
  ProductPageAccumulator append(List<Product> fetched, {required int perPage});
}

// entities/price_range.dart
class PriceRange extends Equatable {
  const PriceRange({this.min, this.max});
  static const none = PriceRange();
  final double? min, max;
  bool get isEmpty => min == null && max == null;
  bool get isInverted => min != null && max != null && min! > max!;
}

// usecases/product_search_params.dart
class ProductSearchParams extends Equatable {
  const ProductSearchParams({required this.query, this.sort = ProductSort.relevance,
    this.priceRange = PriceRange.none, this.languageCode = kDefaultLanguageCode,
    this.page = kDefaultPage, this.perPage = kDefaultPerPage});
  final String query; final ProductSort sort; final PriceRange priceRange;
  final String languageCode; final int page, perPage;
}

// repositories/i_product_repository.dart
abstract class IProductRepository {
  Future<Result<ProductSearchResult>> searchProducts(ProductSearchParams params);
}

// usecases/search_products_use_case.dart
class SearchProductsUseCase implements UseCase<Result<ProductSearchResult>, ProductSearchParams> {
  SearchProductsUseCase(this._repository);
  @override Future<Result<ProductSearchResult>> call({required ProductSearchParams params});
  // Pure delegation: every ordering the app offers is performed by the
  // service, so nothing is reordered here.
}
```

**`lib/src/data/catalog/`** — built on the generated client from `add-catalog-api-client`, not on hand-written models.

The transport, the DTOs and their JSON parsing all come from `package:catalog_api`, generated from `openapi/catalog-api.yaml`. This layer only translates and maps failures.

- `config/catalog_partner.dart` — the three values that identify this app and are not search parameters: `partnerId = 'scalapayappit'`, `source = 'trovaprezzi'`, `country = 'IT'`. The base address lives in the OpenAPI document's `servers`, and the query parameter names became typed arguments, so neither is repeated here. Named `CatalogPartner`, **not** `CatalogApi`: that name is taken by the generated root client.
- `mappers/product_mapper.dart` — `Product toEntity(ProductDocument)` and `ProductSearchResult toSearchResult(ProductSearchResponse)`. The latter flattens `groupedHits[i].hits[j].document` and **skips** any hit that cannot be mapped, so one bad document does not fail the search. `ProductDocument.title` → `Product.name`, `merchant` → `store`, `image` → `imageUrl`; `sellingPrice` and `listPrice` are already `double` because the document types them `number`.
- `repositories/product_repository_impl.dart` — depends on the generated `ProductsApi`, not on a hand-written data source; there is no `IProductRemoteDataSource`, because re-wrapping a generated class in an interface written only to be mocked adds nothing. It calls:

```dart
_api.searchProducts(
  q: params.query,
  page: params.page,
  perPage: params.perPage,
  sortBy: params.sort.queryValue,
  languageCode: params.languageCode,   // -> `language`
  minPrice: params.priceRange.min,     // omitted when null
  maxPrice: params.priceRange.max,
  partnerId: CatalogPartner.partnerId,
  source_: CatalogPartner.source,      // note the trailing underscore
  country: CatalogPartner.country,
)
```

  and maps exceptions to failures unchanged, because `dart-dio` throws `DioException`: `DioExceptionType.connectionTimeout|sendTimeout|receiveTimeout|connectionError` → `NetworkFailure`; a response with a status → `ServerFailure(code: status)`; `FormatException`/`TypeError`/`CheckedFromJsonException` → `SerializationFailure`; anything else → `UnknownFailure`.

**`lib/src/presentation/catalog/`**

```dart
/// State of the results area as a whole (the first page of a search).
enum CatalogStatus { initial, loading, success, empty, failure }

/// State of appending further pages, independent of [CatalogStatus] so that a
/// failure while loading more never blanks the grid already on screen.
enum LoadMoreStatus { idle, loading, failure, exhausted }

@CopyWith()
class CatalogState extends Equatable {
  const CatalogState({this.status = CatalogStatus.initial, this.query = '',
    this.pages = const ProductPageAccumulator(),
    this.loadMoreStatus = LoadMoreStatus.idle,
    this.sort = ProductSort.relevance, this.priceRange = PriceRange.none,
    this.failure, this.languageCode = kDefaultLanguageCode,
    this.perPage = kDefaultPerPage});
  final CatalogStatus status; final String query;
  final ProductPageAccumulator pages; final LoadMoreStatus loadMoreStatus;
  final ProductSort sort; final PriceRange priceRange; final Failure? failure;
  final String languageCode; final int perPage;
  List<Product> get products => pages.products;
  bool get canLoadMore => status == CatalogStatus.success &&
      loadMoreStatus == LoadMoreStatus.idle && !pages.hasReachedEnd;
}

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._searchProducts);
  void setLanguage(String languageCode);          // no request if unchanged
  Future<void> search(String query);              // ignores blank input; resets pages
  Future<void> changeSort(ProductSort sort);      // no-op if unchanged; resets pages
  Future<void> applyPriceRange(PriceRange range); // no request if range.isInverted; resets pages
  Future<void> loadMore();                        // no-op unless state.canLoadMore
  Future<void> retry();                           // retries whichever of the two failed
}
```

- `pages/catalog_page.dart` — `CatalogPage` (`StatelessWidget`, `BlocProvider(create: (_) => injector<CatalogCubit>())`) wrapping `CatalogView` (`StatefulWidget`, `didChangeDependencies` → `setLanguage`).
- **Opening the filters sheet cannot use `ScalapayFiltersBottomSheet.show`.** Its `onApply` wrapper pops the modal unconditionally right after calling the caller's callback, so there is no way to keep the sheet open on an invalid range — which is exactly what the inverted-range requirement needs. The presentation therefore drives the modal itself. To keep that from duplicating the organism's presentation (barrier colour and opacity, safe area, scroll control, rounded top), the design system exports its modal helper publicly and the screen composes with it.
- `widgets/` — `CatalogHeader` (title + `ScalapaySearchField`), `CatalogToolbar` (two `ScalapayFilterChip`s that open the organisms' `show` helpers), `CatalogProductGrid`, `CatalogProductTile` (`ScalapayProductCard` fed with `Image.network` plus `loadingBuilder`/`errorBuilder` placeholders), `CatalogMessage` (centered text with an optional `ScalapayButton`, used by initial/empty/failure), `CatalogLoading`, and `CatalogGridFooter` (the sliver below the grid: a centered spinner while `loadMoreStatus` is `loading`, a short message with a retry button while it is `failure`, and nothing at all when it is `idle` or `exhausted`).
- Safe areas. The page body is `SafeArea(bottom: false)`: the top inset keeps the header below the notch, while the bottom inset moves onto `CatalogGridFooter` — the sliver that actually ends the scroll view, since it follows the grid in every state and merely shrinks to nothing when idle — so products scroll under the translucent home indicator instead of stopping above it. Putting it on the grid instead would have held only while the footer was empty, which would cost 34px of viewport and show a hard edge mid-screen. The sheets are handled in the design system, in `BottomSheetFrame`, because `showModalBottomSheet(useSafeArea: true)` protects only the top and sides — measured, the filters sheet's apply button sat 17px under the gesture bar and the sort sheet cleared it by 4.
- Infinite scroll trigger: the `CustomScrollView` is wrapped in a `NotificationListener<ScrollUpdateNotification>` that calls `loadMore()` when the remaining extent drops below one viewport. The cubit, not the widget, decides whether anything happens (`state.canLoadMore`), so a burst of scroll notifications cannot start two requests.

**`lib/src/config` and `lib/src/core`**

- `AppRoutes.catalog = '/'`; `routes = [GoRoute(path: AppRoutes.catalog, builder: (_, __) => const CatalogPage())]`. No guards.
- `setupInjector`: `_registerCore` registers `Dio(BaseOptions(baseUrl: CatalogApi.basePath, connectTimeout: 15s, receiveTimeout: 15s))` as a lazy singleton. **The base address must be set here**, and an earlier draft of this design was wrong to say the generated client supplies it. The generated constructor is `this.dio = dio ?? Dio(BaseOptions(baseUrl: basePathOverride ?? basePath, ...))`: it applies `basePath` only in the branch where it builds its own client. Injecting one — the whole point of sharing the transport — skips that branch entirely, leaving `baseUrl` empty, and every request goes out as the bare path `/v1/products/search` with no host. Reading `CatalogApi.basePath` rather than repeating the URL keeps the single source of truth: that constant is generated from the OpenAPI document's `servers`. If a second backend on a different host is ever added, the shared `Dio` has to be split; today there is one. `_registerCatalog` registers `CatalogApi(dio: injector<Dio>())` and `injector<CatalogApi>().getProductsApi()` as lazy singletons, so the generated client shares the app's configured transport instead of building its own, then `IProductRepository` and `SearchProductsUseCase` as lazy singletons. `CatalogCubit` is deliberately **not** registered: it belongs to one page and has one dependency, so `CatalogPage` builds it in its `BlocProvider` as `CatalogCubit(injector<SearchProductsUseCase>())`. The page reaches the locator either way, so a registration would save no coupling and only hide which collaborator the cubit needs. The project DI rule was narrowed to match.

**Localization**

- `easy_localization: ^3.0.8` (its `intl` range is `>=0.17.0-0 <0.21.0`, compatible with the `intl ^0.20.3` already in `scalapay_ui`).
- `assets/translations/it.json` and `en.json`, declared under `flutter: assets:` in the root `pubspec.yaml`.
- `main.dart`: `WidgetsFlutterBinding.ensureInitialized()` → `EasyLocalization.ensureInitialized()` → `setupInjector()` → `runApp(EasyLocalization(supportedLocales: [Locale('it'), Locale('en')], path: 'assets/translations', fallbackLocale: Locale('it'), child: const ScalapayApp()))`, with `MaterialApp.router(theme: ScalapayTheme.light(), locale: context.locale, localizationsDelegates: context.localizationDelegates, supportedLocales: context.supportedLocales, routerConfig: createRouter())`.
- Key groups: `catalog.*` (title, search hint, filters, sort, initial, empty with `{query}`, errors, retry), `product.*` (instalment connector, currency symbol), `filters.*`, `sort.*`.

**Design system (`packages/scalapay_ui`)**

- `ScalapayTypography.p2` = Poppins 600, 14, height 21/14; `ScalapayTypography.p5Semibold` = Poppins 600, 11, height 1.5. Both added to `lerp` and `entries`.
- `ScalapayProductCard`: instalments line `p3` → `p2`; text padding `fromLTRB(xs, 12, xs, 0)` → `fromLTRB(xs, 12, xs, 12)`.
- `ScalapayFilterChip`: label `p4` → `p5Semibold`.
- The internal modal helper behind every organism's `show` becomes public API, so a caller that needs to drive the modal itself — to keep a sheet open while showing an error, for instance — reuses the design system's presentation instead of copying it.
- `ScalapayFiltersBottomSheet`: gains `String? priceError`, passed through by `show`, rendered once below the two price fields in `colors.error` with `typography.p5` — the same style `ScalapayTextField` uses for its own error text. One message rather than a per-field `errorText` because an inverted range is a property of the pair, and duplicating the same sentence under both fields reads as two problems instead of one. The organism still validates nothing: the caller decides when the message appears. Absent the message the layout is byte-identical, so no space is reserved.
- Goldens for the product card and the filter chip are regenerated; Widgetbook gains the two new typography entries.

## Risks / Trade-offs

- [The catalog API is a dev environment and can be down or slow] → No test touches it; every data test runs against a captured fixture and a mocked `Dio`. The screen's failure state with retry is the product-level answer.
- [Changing the chip label and the card's instalments style regenerates goldens, and a regenerated golden can hide a real regression] → The tasks regenerate goldens only for the two touched components and require the diff to be reviewed for exactly the expected text-metric change.
- [`easy_localization` in widget tests needs `ensureInitialized` and the translation assets in the test bundle] → One shared `pumpApp` helper in `test/helpers/` does the setup; every widget test goes through it rather than repeating the incantation.
- [The design's 57px gap above the title exists only to reserve a hidden back arrow] → Reproduced as a single named constant in `CatalogHeader` with a comment pointing at the Figma frame, so it is obviously a measurement and not an accident.
- [The grid's `mainAxisExtent` hardcodes Figma's 154px text block; a longer instalment wording in another language could need a third line] → The two shipped wordings both fit in two lines at scale 1.0, and the extent follows `textScaler`; a language that overflows changes one constant.
- [A single malformed product fails the whole page instead of being skipped] → Accepted, and it is a consequence of generating the client rather than a choice: the generated `ProductSearchResponse.fromJson` parses `grouped_hits` eagerly inside `$checkedConvert`, so one bad document raises `CheckedFromJsonException` for the entire response before any mapper runs. Salvaging the readable products would mean bypassing `ProductsApi.searchProducts` and hand-parsing the envelope from raw JSON, which is exactly the hand-written parsing the generated client removed. The mapper keeps a per-hit `try`/`catch` as zero-cost insurance against *mapping* errors, which are reachable, and the user gets the error state with retry rather than a silently short list.
- [The filters sheet gained a parameter mid-implementation, so its goldens and spec move in a change that is mostly about the app] → Kept as small as the gap requires: one optional parameter, no behaviour when it is absent, and the `design-organisms` delta records that the sheet still validates nothing.
- [`Image.network` has no cache, so scrolling re-fetches] → Accepted: caching is an explicit non-goal, and the placeholder/error builders keep the layout stable.

## Migration Plan

Additive for the app: nothing exists to migrate. The three design system edits are source-compatible — no parameter or widget is added, removed or renamed, only token values applied inside existing widgets — so no call site changes, and the only visible effect is the intended text-metric correction.

## Open Questions

- Whether the "Ordina" chip should show the active sort and the "Filtri" chip an active-filter marker. Figma shows neither, and the proposal lists it as a non-goal; it can be added later without touching the specs or the contracts.
