# scalapay_test_app

Flutter app reproducing the Scalapay product catalog screen, backed by the
Scalapay catalog API: a text search, a price-range filter, ordering by price,
and a two-column product grid that appends further pages as you scroll.

## Running

```bash
flutter pub get      # once, at the repository root: it resolves every workspace member
flutter run
```

The repository is a Dart workspace. Its members are the app, the design system
`packages/scalapay_ui`, its Widgetbook, and the generated API client
`packages/catalog_api`. A single `flutter pub get` at the root resolves them all.

## Tests

```bash
flutter test                              # the app
cd packages/scalapay_ui && flutter test   # the design system, including goldens
```

No test performs network access. The API tests run against a response captured
from the live service, in `test/fixtures/`, and the widget tests read the real
`assets/translations/*.json` from disk rather than a copy, so changing a string
there makes the tests that assert it fail.

### Coverage

```bash
# the app: generated code and workspace packages are left out
flutter test --coverage
lcov --remove coverage/lcov.info '*.g.dart' 'packages/*' \
  -o coverage/lcov.filtered.info --ignore-errors unused
genhtml coverage/lcov.filtered.info -o coverage/html   # open coverage/html/index.html

# the design system
cd packages/scalapay_ui && flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

`lcov` and `genhtml` come from `brew install lcov`.

Line coverage from the unit and widget tests, measured on 2026-09-23. Generated
code (`*.g.dart`, `packages/catalog_api`) is left out:

| Area | Lines covered | Coverage |
| --- | ---: | ---: |
| App `lib/src/core` | 31 / 40 | 77.5% |
| App `lib/src/domain` | 41 / 51 | 80.4% |
| App `lib/src/data` | 115 / 123 | 93.5% |
| App `lib/src/presentation` | 319 / 325 | 98.2% |
| **App total** | **506 / 539** | **93.9%** |
| `scalapay_ui` foundations + theme | 99 / 101 | 98.0% |
| `scalapay_ui` atoms, molecules, organisms | 424 / 424 | 100% |
| **`scalapay_ui` total** | **523 / 525** | **99.6%** |

`lib/main.dart` and `lib/src/config/router/` do not appear in the report because
no unit or widget test imports them: the integration suite covers them instead.

### What each test covers

**App (`test/`)**

- `widget_test.dart`: boots `CatalogPage` with a mocked use case and checks
  the title and search field appear.
- `architecture/layer_boundaries_test.dart`: scans the imports under
  `domain/` and `presentation/` and fails if either one imports the generated API client.
- `localization/translations_test.dart`: flattens `it.json` and `en.json` into
  dotted keys, then checks both have the same keys and no empty values.
- `core/di/injector_test.dart`: runs `setupInjector` with an offline Dio
  adapter and checks what each type resolves to, the shared Dio and timeout mapping.
- `data/catalog/generated_contract_test.dart`: parses the captured fixture
  with the generated client, so API drift fails offline, not at runtime.
- `data/catalog/catalog_partner_test.dart`: checks the constant partner id
  (`scalapayappit`).
- `data/catalog/product_mapper_test.dart`: maps generated documents onto
  `Product` and `grouped_hits` onto a flat list, field by field.
- `data/catalog/product_repository_impl_test.dart`: stubs `ProductsApi` and
  checks the query arguments sent and how each Dio/parse error maps to a `Failure`.
- `data/network/retry_interceptor_test.dart`: drives the retry interceptor
  with a scripted adapter and fake delays: which errors retry, how many times, backoff.
- `domain/catalog/entities/*_test.dart`: pure unit tests of `PriceRange`, `Product`,
  `ProductSort` query values and `ProductPageAccumulator` dedup/end-of-list rules.
- `domain/catalog/usecases/search_products_use_case_test.dart`: with a mocked
  repository, checks params, product order and failures pass through unchanged.
- `presentation/catalog/catalog_cubit_test.dart`: `blocTest` on search, sort,
  filters, loadMore, retry and language with a mocked use case, including stale responses.
- `presentation/catalog/pages/catalog_view_test.dart`: pumps `CatalogView` on
  a mocked cubit and checks what each status renders and each failure's message.
- `presentation/catalog/pages/catalog_bottom_sheets_test.dart`: opens the sort
  and filter sheets from the chips and checks choose, apply, dismiss, invalid range.
- `presentation/catalog/pages/catalog_infinite_scroll_test.dart`: drags the
  grid to the end and checks one `loadMore` per page, the footer and scroll position.
- `presentation/catalog/pages/catalog_fixed_toolbar_test.dart`: scrolls to the
  end and checks the Filtri/Ordina chips stay visible and tappable.
- `presentation/catalog/pages/catalog_bottom_inset_test.dart`: on a notched
  device, checks the last row can scroll above the home indicator.
- `presentation/catalog/pages/catalog_large_text_test.dart`: at 200% text,
  including Android 14's non-linear scaler, checks grid, sheets and chips don't overflow.
- `presentation/catalog/pages/catalog_page_a11y_test.dart`: runs Flutter's
  tap-target guidelines on each status and checks each card is one semantics node.
- `presentation/catalog/widgets/*_test.dart`: tests header, toolbar, message,
  grid footer, product tile and grid one at a time: content, callbacks, columns, semantics.

**Integration (`integration_test/`, on a device)**

Each test runs the real app with only the repository faked (`support/`) and
drives one user flow: search, sort, filter, pagination, and error with retry.

**Design system (`packages/scalapay_ui/test/`)**

- `tokens_theme_test.dart`: checks colors, spacing, radii and text styles
  match Figma, and `context.tokens` fails clearly when no theme is set.
- `contrast_test.dart`: computes the WCAG contrast of each text color on its
  background from the tokens, requiring 4.5:1 unless it's a documented exception.
- `atoms_test.dart`: button, chip, search field, text field, radio, icon and
  divider: taps, disabled state, sizes from Figma, large text, semantics.
- `molecules/product_card_test.dart`: `ScalapayProductCard` content, money
  formatting per locale, installments line, two-line ellipsis, one semantics node.
- `organisms/*_test.dart`: sheet frame, sort sheet, filters sheet (numeric
  fields, errors) and `show` (every way to dismiss, keyboard, insets, 200% text).
- `goldens/*_golden_test.dart`: renders each component in Poppins and compares
  it pixel by pixel with the reference PNGs in `goldens/images/`.
- `widgetbook/test/`: opens every Widgetbook use case, checks each renders
  without errors and passes the tap-target guidelines.

## Deliberate divergences from the mockup

The screen reproduces Figma frame `0:3908`; the geometry was checked by
measuring the built screen at 375x812, not by eye. Four things differ on
purpose:

- **The sort sheet offers three options, not Figma's four.** Figma shows "Prezzo
  crescente", "Prezzo decrescente", "Nome A-Z" and "Nome Z-A". The two name
  options are **removed**: the catalog service can only order by selling price,
  so offering them would show relevance order under a name label, which the user
  could not detect — see "Known API behaviour" below. A "Rilevanza" option is
  **added** as the first entry, because it is the ordering the screen starts in
  and Figma provides no way back to it: with only the price options, choosing one
  is a one-way door out of the default. The mockup shows a single frame and never
  the screen after a choice, so it could not surface that.
- **Money follows the app locale.** Figma renders the price as "85,00€" and the
  instalment as "€23,33" — two conventions in one card. The app formats both
  with `intl` using the active locale, so Italian gives "85,00 €" and English
  "€85.00".
- **Rows sit about 15px further apart than Figma.** The grid derives its cell
  height from the design's 164x195 image ratio plus the text block, with a
  cushion that scales with the text. Figma's nominal text block overflows once
  real font metrics are laid out — by ~1px at the default text size and ~15px
  at 1.5x — so the cushion is what keeps the layout intact for anyone who
  enlarges the system font.
- **The Filtri and Ordina chips are fixed, not scrolling.** In Figma the chips
  row is grouped with the scrolling content, but a control that changes *what*
  the results are should stay reachable at any scroll position — otherwise a
  long grid makes you scroll back to the top to change a filter. A single static
  frame cannot express scroll behaviour, so the grouping was taken as layout,
  not as a scrolling rule.
- **No back arrow and no product counter.** Both exist in the Figma file but are
  marked hidden there, so both are reproduced as hidden. The back arrow's slot
  still occupies 57px above the title, which is why that gap looks arbitrary in
  the code and carries a comment saying so.

## Known API behaviour

Everything below was measured against the live service and re-confirmed on
2026-09-21. Each item gives the command, what comes back, and what the app had
to do about it. Reproduce any of them by substituting `sort_by`, `per_page` or
`page` into:

```bash
BASE=https://catalog-api.dev-cat.scalapay.com/v1/products/search
COMMON='partnerId=scalapayappit&source=trovaprezzi&language=it&country=IT&filter_by='
curl -s "$BASE?q=nike&per_page=30&page=1&$COMMON&sort_by=_text_match:desc" \
  | python3 -c 'import json,sys; d=json.load(sys.stdin); print([h["hits"][0]["document"]["id"] for h in d["grouped_hits"]])'
```

Comparing the returned id sequences is what makes these visible; comparing the
first few titles is not enough.

### Within the documented contract

**Only `selling_price` can be ordered by.** The assessment brief states that
`sortType` is `_text_match` or `selling_price`, and that holds. Measured:
`selling_price:asc` and `selling_price:desc` genuinely reorder; `title:asc`,
`brand:asc`, `list_price:asc`, `merchant`, `discount_percentage`, `id`,
`category`, `new_offer` and `has_image` all return the relevance order. A
comma-separated list such as `title:asc,selling_price:asc` is parsed with the
unknown field dropped. **Consequence:** ordering by product name is impossible,
which is why the sort sheet has two options rather than four. Doing it
client-side was rejected: with pagination it would sort only the current page,
and measured on `q=nike`, 22 of page 2's 30 products belong before the end of
page 1 — two alphabetical lists shown one after the other, not one.

### Questionable

**An unknown sort field is accepted, not rejected.** `garbage:asc` returns
exactly the relevance order, HTTP 200, no error. So does a typo like
`selling_prices:asc`. **Consequence:** the app's domain can only express the two
honoured fields, so a mistake cannot silently mislabel an ordering. A `400`
would have made this a development-time error instead of a trap.

Two related details: the leading underscore is not significant (`text_match` is
just another ignored field), and the direction is inert on relevance
(`_text_match:asc` equals `:desc`), so relevance has one form, not two.

**`found` is not a total.** It always equals the number of items returned:
`per_page=5` gives `found: 5`, `per_page=100` gives `found: 100`.
**Consequence:** no "x of y" progress can be shown, and the end of the results
cannot be computed from it. The hidden Figma counter could not have been filled
in even if it were visible.

**Pagination repeats instead of ending.** Past its last page the service returns
an earlier page again — byte-identical, HTTP 200, never short, never empty,
never an error. Measured at `q=nike`:

| `per_page` | distinct pages | then |
| --- | --- | --- |
| 30 | 10 (300 products) | page 11 repeats page **1** |
| 50 | 7 (350 products) | page 8 repeats page **7** |
| 100 | 4 (400 products) | page 5 repeats page **4** |

Note the repeated page is not always page 1 — at larger page sizes it is the
last valid page. **Consequence:** the app detects the end itself, in
`ProductPageAccumulator`, by recognising a page that contributes no product id
it has not already seen. That choice was made before this variation was
observed, and it is what makes the app survive it: a check of "is this page
equal to page 1" would have worked at `per_page=30` and looped forever at 50 or
100. The accumulator also stops on a short page and after a hard maximum, so the
sequence terminates whatever the service does.

Finally, the reachable window moves with the page size, so **the page count must
not be hardcoded** by any client.

## The backend client is generated

`packages/catalog_api` is **generated output, committed to the repository**. Do
not edit anything inside it except the files listed as hand-maintained below: a
regeneration would overwrite your changes. To change what the client does,
change `openapi/catalog-api.yaml` and regenerate.

### Regenerating

Two steps, and the first one needs a JDK:

```bash
# 1. Generate the Dart sources from the OpenAPI document.
dart run openapi_generator_cli:main generate \
  -i openapi/catalog-api.yaml -g dart-dio -o packages/catalog_api \
  --additional-properties=pubName=catalog_api,serializationLibrary=json_serializable

# 2. Emit the json_serializable .g.dart files inside the package.
cd packages/catalog_api && dart run build_runner build --delete-conflicting-outputs
```

The executable is reached as `:main`, not as `:openapi-generator`: the package
declares `executables: {openapi-generator: main}`, but `dart run <pkg>:<name>`
resolves `bin/<name>.dart` and ignores that mapping.

**Only regeneration needs Java.** Building and testing the app need Dart and
Flutter alone, because the package, including its `.g.dart`, is committed. That
required a single negated pattern in `.gitignore`, since the repository ignores
`*.g.dart` everywhere else; this package is vendored output, not part of a
developer's normal codegen loop. `openapi_generator_config.json` pins the
generator to 7.17.0 so regeneration is reproducible across machines.

The `build_runner` variant of this tool (the `openapi_generator` package, driven
by an `@Openapi` annotation) **cannot be used in this project**: it depends on
`analyzer >5.12.0 <9.0.0` while `json_serializable` depends on
`analyzer >=10.0.0`, and the ranges are disjoint.

### Hand-maintained inside the generated package

Listed in `packages/catalog_api/.openapi-generator-ignore`, so regeneration
leaves them alone:

| File | Why it is not generated |
| --- | --- |
| `pubspec.yaml` | The generator knows nothing about the Dart workspace, and suggests its own dependency ranges; ours declares `resolution: workspace` and pins the versions the app uses. |
| `analysis_options.yaml` | Generated sources are not held to the app's lint set. |
| `README.md`, `.gitignore` | Generator scaffolding this project does not use. |
| `test/**` | Eleven empty `// TODO` stubs. The real contract test is `test/data/catalog/generated_contract_test.dart`, in the app. |

## The API document is reverse-engineered

`openapi/catalog-api.yaml` is **not vendor-supplied.** The service publishes no
API description: every conventional path (`/openapi.json`, `/swagger.json`,
`/v3/api-docs`, `/swagger-ui.html`, ...) answers with API Gateway's generic
`403 {"message":"Missing Authentication Token"}`, its response to an unmatched
route. The document was written from the assessment brief plus direct probing of
the live service on **2026-09-20**, so it records observed behaviour.

`test/data/catalog/generated_contract_test.dart` parses a captured response
through the generated models, which is what catches the document drifting from
the service. It cannot catch a change made after the fixture was captured:
**refreshing `test/fixtures/product_search_nike.json` is a manual step.**

### Only one host is declared

The assessment brief names two hosts. Only `catalog-api.dev-cat.scalapay.com` is
in the document; it answers `200` with no credentials.

`catalog-api.dev.scalapay.com` is **deliberately omitted**. It answers `401` to
the identical request, with an application-level body rather than a gateway
rejection:

```json
{"httpStatusCode":401,"errors":[{"message":"Authorization header not found",
                                 "code":"AuthorizationNotFound"}]}
```

So it is the same API behind an `Authorization` header. What is missing is
everything needed to use it: the scheme is not stated, no `WWW-Authenticate`
header is returned to infer it from, no token ships with the assessment, and
nothing documents how to obtain one. Declaring a `securityScheme` would mean
guessing all three, and the generated client would carry an authentication path
nobody can exercise or test. Should a token and its scheme become available,
adding the host is one entry under `servers`, with no effect on the generated
code.
