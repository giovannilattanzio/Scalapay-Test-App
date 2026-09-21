# Design

## Context

See proposal.md — Why. What constrains the approach:

- **No published spec.** Probed `/openapi.json`, `/swagger.json`, `/v1/openapi.json`, `/v1/swagger.json`, `/api-docs`, `/v1/api-docs`, `/v3/api-docs`, `/openapi.yaml`, `/swagger-ui.html`, `/docs`, `/v1/docs` and `/.well-known/openapi.json`: all return `403 {"message":"Missing Authentication Token"}`, which is AWS API Gateway's answer for an unmatched route. The document must be written from observed behaviour.
- **The observed contract is well established.** The sibling change `add-product-catalog-page` measured it in detail; design.md there holds the field list, the int/double price mix, the three real orderings, `found` not being a total and the page-11-returns-page-1 clamp. This change turns those findings into a machine-readable artifact.
- **Toolchain present.** Java 17.0.11, Flutter 3.47.5, Dart 3.13. `openapi_generator` 7.0.0 runs the upstream Java generator, so Java is a regeneration-time requirement.
- **The repository is a Dart workspace** (`scalapay_test_app`, `packages/scalapay_ui`, `packages/scalapay_ui/widgetbook`), each member declaring `resolution: workspace`, resolved by one `flutter pub get` at the root.
- **`dio` 5.11.1 and `json_serializable` 6.13.2 are already dependencies**, and `add-product-catalog-page` already registers a configured `Dio` singleton.

## Goals / Non-Goals

**Goals:**

- One artifact that is the contract, from which the transport code follows, instead of transport code that implies a contract.
- A generated package that is inert: committed, never hand-edited, and invisible above the data layer.
- The measured quirks written where the next reader will meet them — in the document, on the fields they affect.

**Non-Goals (design level, beyond the proposal's):**

- A shared client for other Scalapay services, or a spec split across files.
- Regenerating during the normal build. Generation is an explicit, occasional command.
- Replacing the repository's `Result`/`Failure` handling with the generator's exception types.

## Decisions

**1. The document is hand-written, from measurements, and lives at `openapi/catalog-api.yaml`.**
Top level of the repository, not inside `lib/` or the generated package, because it is an input to the build and is read by humans more often than by tools. A single file: one operation does not justify `$ref` splitting. Alternative: generating the document from captured traffic with a tool; rejected because the interesting parts — which sort fields are honoured, that `found` is not a total — cannot be inferred from a sample, only from the probes already run.

**2. `dart-dio` with `serializationLibrary: jsonSerializable`, not `built_value`.**
`openapi_generator_annotations` 7.0.0 exposes `DioSerializationLibrary { builtValue, jsonSerializable }`; `built_value` is the generator's default. Choosing `jsonSerializable` keeps the package on `dio` and `json_serializable`, both already in this project, instead of adding `built_value`, `built_collection` and their builders for one endpoint. It also means the generated models read like the rest of the codebase. Alternative: the plain `dart` generator, which uses `http`; rejected because the app configures a `Dio` instance and the repository's failure mapping is written against `DioException`.

**3. Numbers are `type: number`, which is what makes the int/double mix a non-issue.**
The service sends `selling_price` as `13` for one product and `13.38` for another. Typed as `number`/`format: double`, `json_serializable` emits `(json['selling_price'] as num).toDouble()`, so both parse. The hand-written plan needed a custom converter for exactly this; the generated client gets it from the type.

**4. Generation is an explicit command, not a `build_runner` builder.**
The Dart `openapi_generator` package — the `source_gen` builder driven by an `@Openapi` annotation — **cannot be installed in this project**. It depends on `analyzer >5.12.0 <9.0.0`, while `json_serializable` 6.13.2 depends on `analyzer >=10.0.0 <14.0.0`. The ranges are disjoint, 7.0.0 is the latest release, and `pub get` fails outright:

```
Because openapi_generator >=7.0.0 depends on analyzer >5.12.0 <9.0.0 and
json_serializable 6.13.2 depends on analyzer >=10.0.0 <14.0.0,
openapi_generator >=7.0.0 is incompatible with json_serializable 6.13.2.
```

Relaxing `copy_with_extension_gen`, which pins `analyzer ^10.0.0`, does not help: `json_serializable` is the binding constraint and it is not negotiable here.

So the upstream generator is invoked directly instead, through `openapi_generator_cli` as a dev dependency — a thin Dart wrapper that fetches and runs the same Java jar, and whose own dependencies are `http`, `path`, `args` and `cli_launcher`, with **no analyzer**, hence no conflict:

```
dart run openapi_generator_cli:main generate \
  -i openapi/catalog-api.yaml -g dart-dio -o packages/catalog_api \
  --additional-properties=pubName=catalog_api,serializationLibrary=json_serializable
```

The executable is reached as `:main`, not as `:openapi-generator`: the package declares `executables: {openapi-generator: main}`, but `dart run <pkg>:<name>` resolves `bin/<name>.dart` and ignores that mapping, so the declared name fails with "Could not find `bin/openapi-generator.dart`". The jar it fetches is OpenAPI Generator **7.17.0**, recorded in `packages/catalog_api/.openapi-generator/VERSION`.

This is not a downgrade but a correction: the builder would have re-run the generator on every `dart run build_runner build` in the app, which contradicts this design's own non-goal of not regenerating during the normal build. An explicit command is what was wanted all along. Alternative: `npx @openapitools/openapi-generator-cli`, which is how this route was verified; rejected for the project because it adds a Node requirement and pins no version in the repository.

Consequence: there is no `lib/openapi_config.dart` and no annotation, and `openapi_generator_annotations` is not a dependency.

**5. `.openapi-generator-ignore` protects the package manifest.**
The generator writes a `pubspec.yaml` that knows nothing about `resolution: workspace`, so every regeneration would drop the package out of the workspace. The upstream generator's own ignore file is the intended mechanism. It writes a default `.openapi-generator-ignore` on first generation; that file is then taken over and extended to list `pubspec.yaml` and `analysis_options.yaml`, which become hand-maintained. The generator does not wipe the output directory, so nothing else is needed to preserve them. Alternatives: a post-generation patch script (another moving part that can silently stop running) or keeping the package outside the workspace with a plain path dependency (a second resolution, defeating the one-`pub get` property); both rejected.

**6. The generated package is committed, including its `.g.dart`.**
So a clean checkout builds and tests with Dart and Flutter alone. Only regeneration needs Java. Alternative: generating in CI; rejected as it makes every build depend on a Java toolchain and on the generator's network fetch, for an endpoint that changes rarely.

This needed a `.gitignore` exception that was not anticipated. The repository ignores `*.g.dart` project-wide (line 681), which silently excluded the package's ten serialization files; measured without them, a clean checkout fails with 30 analyzer errors until `build_runner` is run inside the package. The rule is right for hand-written code, whose `.g.dart` a developer regenerates in their normal loop, but this package is **vendored output**, not part of that loop, so its generated files are part of the artifact. A single negated pattern, `!packages/catalog_api/lib/**/*.g.dart`, exempts it; the rule still applies everywhere else, which was verified.

**7. The app's own constants class is renamed to avoid a collision.**
`pubName: catalog_api` makes the generated root client class `CatalogApi`, which is the name `add-product-catalog-page` gave its constants holder. The generated name wins; the app's becomes `CatalogPartner` and shrinks to what the document does not carry: the `partnerId`, `source` and `country` values. The base address moves into the document's `servers`, and the parameter names disappear into typed method arguments.

**8. The data layer keeps its shape; only its insides change — and it is built in the sibling change.**
The app's domain and data layers do not exist yet: `lib/src/domain/` and `lib/src/data/` hold only their barrels, and `Product`, `ProductSearchResult`, the repository and the DI registrations all come from `add-product-catalog-page`. Wiring therefore cannot happen here; this change delivers the contract, the package and the proof that it parses real data, and the wiring below is specified here but **implemented in that change**, which is revised to do it.

`IProductRemoteDataSource` and `ProductRemoteDataSourceImpl` disappear: the generated `ProductsApi` is the remote data source, and re-wrapping it would add an interface that exists only to be mocked. `ProductRepositoryImpl` depends on `ProductsApi` directly, calls `searchProducts(...)`, maps the returned DTOs to domain entities through a mapper, and keeps its existing `DioException` → `Failure` mapping unchanged, because `dart-dio` throws `DioException`. The repository interface, the use case, the cubit and every widget are untouched.

**9. The fixture is the guard against spec drift.**
A hand-written document can drift from the service silently. The captured real response (`test/fixtures/product_search_nike.json`, already planned by the sibling change) is parsed through the generated models in a test. If a field the document declares required stops arriving, or changes type, the test fails offline — no network, no dev-environment flakiness. This does not catch the service adding fields, which is harmless, nor a change made after the fixture was captured; refreshing the fixture is a manual step named in the README.

**10. `servers` declares one host, and the other one is documented as unused.**
The assessment document offers two hosts. `catalog-api.dev-cat.scalapay.com` answers 200 with no credentials and is the one the app uses. `catalog-api.dev.scalapay.com` answers **401** to the identical request, with an application-level body — not a gateway rejection — that names what is missing:

```json
{"httpStatusCode":401,"errors":[{"message":"Authorization header not found","code":"AuthorizationNotFound"}]}
```

So it is the same API behind an `Authorization` header. What the response does not say is the **scheme** (bearer, basic, an API key?), and there is no `WWW-Authenticate` header to infer it from, no token supplied with the assessment, and nothing in the assessment document about obtaining one. Declaring a `securityScheme` would mean guessing all three, and the generated client would then carry an authentication path nobody can exercise or test. The host is therefore left out of `servers` rather than described speculatively.

It is not left out silently: the README records that the host exists, that it was tried, the exact error it returns, and that it was skipped because an `Authorization` header is required but its scheme and how to obtain a token are undocumented. That way the next reader knows the omission was a decision, not an oversight, and knows exactly what would need to arrive for the host to be added — one entry under `servers`, with no effect on the generated code.

### Contracts

**`openapi/catalog-api.yaml`** — OpenAPI 3.0.3.

- `servers`: exactly one entry, `https://catalog-api.dev-cat.scalapay.com`. The assessment document's second host is deliberately absent — see Decision 10.
- One path, `/v1/products/search`, `get`, `operationId: searchProducts`, `tags: [Products]` → generated `ProductsApi.searchProducts(...)`.
- Query parameters: `q` (string, required), `page` (integer, default 1), `per_page` (integer, default 30), `sort_by` (string), `filter_by` (string, allows empty), `minPrice` (number, optional), `maxPrice` (number, optional), `partnerId` (string, required), `source` (string, required), `language` (string, required), `country` (string, required).
- Schemas:
  - `ProductSearchResponse` — `page` (integer), `found` (integer), `grouped_hits` (array of `GroupedHit`), `facet_counts` (array of `FacetCount`), `merchantDetectedFromQuery` (`DetectedMerchant`, nullable).
  - `GroupedHit` — `hits` (array of `Hit`); `Hit` — `document` (`ProductDocument`).
  - `ProductDocument` — `id`, `title`, `merchant`, `merchantId`, `brand`, `brandId`, `image`, `image_merchant`, `category`, `category_1`, `category_2`, `description`, `url`, `affiliate_url` (strings); `selling_price`, `list_price`, `discount_percentage` (numbers); `tags` (array of string); `new_offer` (boolean); `has_image` (integer, 0 or 1, not a boolean as the service sends it). Required: `id`, `title`, `merchant`, `brand`, `image`, `selling_price`, `list_price`.
  - `FacetCount` — `field_name` (string), `counts` (array of `FacetValue`), `stats` (`FacetStats`); `FacetValue` — `count` (integer), `highlighted` (string), `value` (string); `FacetStats` — `min`, `max` (numbers, both optional).
  - `DetectedMerchant` — `id`, `name`, `logo`, `merchantToken` (strings).
- Descriptions carrying the measured behaviour: on `sort_by` (only `_text_match` and `selling_price` honoured; any other field accepted and ignored; direction inert on relevance), on `page` (past the last page the first page is returned again, so the client must detect the end from items already received), on `found` (equals the number of items returned; not a total), on `per_page` (the reachable window moves with it: 10 pages at 30, 7 at 50, 4 at 100).

**`packages/catalog_api/`** — generated, committed. Generated with OpenAPI Generator 7.17.0 via `openapi_generator_cli` 7.0.0.

Generated API surface:

```dart
class CatalogApi { CatalogApi({Dio? dio, ...}); final Dio dio; ProductsApi getProductsApi(); }

Future<Response<ProductSearchResponse>> ProductsApi.searchProducts({
  required String q, required String partnerId, required String source_,
  required String language, required String country,
  int? page = 1, int? perPage = 30,
  String? sortBy = '_text_match:desc', String? filterBy = '',
  double? minPrice, double? maxPrice,
  CancelToken? cancelToken, Map<String, dynamic>? headers, ... });
```

Three things the generator decided, not us. The `source` parameter becomes **`source_`** with a trailing underscore. The models carry `@CopyWith()` from `copy_with_extension` as well as `@JsonSerializable(checked: true)`, so the package depends on both. And the output ships `.dart` sources only: a `build_runner` pass **inside the package** emits the `.g.dart` files, making generation two steps.

- Hand-maintained, listed in `.openapi-generator-ignore` (the generator writes a default one, which is then taken over): `pubspec.yaml`, `analysis_options.yaml`, and `README.md`/`.gitignore`/`test/**`, which are generator scaffolding this project does not use. The eleven generated `test/` files are empty `// TODO` stubs; they are deleted and ignored rather than kept and linted around, because the real contract test lives in the app.
- `pubspec.yaml` pins the app's own versions rather than the generator's suggestions (`dio: ^5.11.1`, `json_annotation: 4.11.0`, `copy_with_extension: 12.1.0`, dev `json_serializable: ^6.13.2`, `copy_with_extension_gen: 12.1.0`, `build_runner: ^2.15.1`), plus `publish_to: none` and `resolution: workspace`. Verified: the generated sources build and analyze under exactly these pins, against the generator's own suggestion of `copy_with_extension ^7.1.0`.
- `analysis_options.yaml` relaxes lints for generated sources; one real warning needs it (`unused_import` of `error_response.dart` in `products_api.dart`). With that and the removed stubs, `dart analyze` inside the package reports no issues.
- Everything else is generated output and is never edited.

**`openapi_generator_config.json`** (repository root) — written by `openapi_generator_cli` on first run and kept. It pins `openapiGeneratorVersion: 7.17.0`, which is what makes regeneration reproducible across machines: without it the wrapper is free to fetch a different jar and produce a diff that has nothing to do with the document. Committed for that reason.

**Root `pubspec.yaml`**

- `workspace:` gains `packages/catalog_api`.
- `dependencies:` gains `catalog_api: {path: packages/catalog_api}`.
- `dev_dependencies:` gains `openapi_generator_cli: ^7.0.0`. Nothing else: there is no annotation package and no builder — see Decision 4.

**`lib/src/data/catalog/`** — specified here, **implemented in `add-product-catalog-page`** (see Decision 8), which this change revises to do it

- Removed before being written: `models/product_model.dart`, `models/product_search_response_model.dart`, `datasources/product_remote_data_source.dart`.
- Added: `mappers/product_mapper.dart` — `Product toEntity(ProductDocument)` and `ProductSearchResult toSearchResult(ProductSearchResponse)`, the latter flattening `grouped_hits` and skipping any hit whose document cannot be mapped.
- Changed: `repositories/product_repository_impl.dart` takes `ProductsApi` instead of `IProductRemoteDataSource`, calls `searchProducts(q:, page:, perPage:, sortBy:, minPrice:, maxPrice:, partnerId:, source:, language:, country:)`, and keeps its failure mapping.
- Changed: `config/catalog_api.dart` → `config/catalog_partner.dart`, holding `partnerId`, `source`, `country` only.

**DI** — `_registerCore` keeps the configured `Dio`; `_registerCatalog` registers `CatalogApi(dio: injector<Dio>())` and `injector<CatalogApi>().getProductsApi()` as lazy singletons, then the repository and the use case as before.

## Risks / Trade-offs

- [The document is our reading of the service, not the service's own description] → The fixture test catches drift in what we already observe; the README states the document is reverse-engineered and dated, so no reader mistakes it for vendor-supplied.
- [Regeneration needs Java and the generator fetches its jar on first run] → The package is committed, so this affects only whoever regenerates; the README names the requirement and the command.
- [`.openapi-generator-ignore` is easy to forget when adding a hand-maintained file] → The package's own README lists the protected files, and a task verifies that a regeneration leaves the working tree clean, which fails loudly the day the list is wrong.
- [Dropping `IProductRemoteDataSource` removes the seam most repository tests mock] → `ProductsApi` is a concrete generated class, but its methods are instance methods and mock cleanly with `mocktail`; the repository tests mock it directly instead of an interface written only to be mocked.
- [The generated package's lints differ from the app's] → `analysis_options.yaml` is hand-maintained inside the package and excludes the generated sources from the app's stricter set, so `flutter analyze` stays clean without weakening it elsewhere.
- [Two changes now touch the same files, and this one revises the other's plan] → This change's tasks update `add-product-catalog-page` explicitly and before its implementation starts; it has 0 of 26 tasks done, so there is no written code to migrate.
- [The generated client's method signature is decided by the generator, not by us] → The document's `operationId` and `tags` pin the class and method names; the task list verifies the generated signature before the repository is written against it.

## Migration Plan

No runtime migration: nothing in this change is deployed on its own, and no app behaviour changes. The ordering matters, though: this change is implemented **before** `add-product-catalog-page`, and its last group revises that change's design and tasks — including handing it the app-wiring work, which cannot run here because the domain and data layers do not exist yet.

Two requirements of `generated-api-client` are therefore stated here but satisfied there: "The app depends on the client only through the data layer" and "The client shares the application's configured transport". The revision task makes the sibling change's tasks cite them explicitly, so neither is lost between the two changes. If the generation route is abandoned, reverting means deleting `openapi/`, `packages/catalog_api`, `lib/openapi_config.dart` and the three pubspec additions, and restoring the sibling change's data-layer tasks from git.

