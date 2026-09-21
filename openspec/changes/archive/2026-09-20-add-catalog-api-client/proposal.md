# Proposal

## Why

The catalog service publishes no API description: every documented path (`/openapi.json`, `/swagger.json`, `/v3/api-docs`, …) answers with API Gateway's generic `403 Missing Authentication Token`, so the only record of the contract is prose in the assessment document plus what this project measured by probing. That knowledge currently has nowhere to live except a design document, and the sibling change `add-product-catalog-page` would hand-write the models and the HTTP call from it. Writing the contract down as an OpenAPI document and generating the client from it makes the contract the artifact, removes the hand-written transport code, and gives the measured corner cases a permanent home.

## What Changes

- New `openapi/catalog-api.yaml` (OpenAPI 3.0.3) describing `GET /v1/products/search`: every query parameter, the full response shape (`grouped_hits`, `facet_counts`, `merchantDetectedFromQuery`), and the measured behaviour recorded as schema descriptions.
- New generated Dart package `packages/catalog_api`, produced by the OpenAPI Generator's `dart-dio` generator with `serializationLibrary: jsonSerializable`, so the client uses the `dio` and `json_serializable` already in this project rather than pulling in `built_value`. It is invoked as an explicit command through `openapi_generator_cli`, not as a `build_runner` builder: the builder's `analyzer` constraint is disjoint from `json_serializable`'s and cannot be installed here.
- The generated package joins the Dart workspace and is committed, so building and testing the app never requires Java; only regeneration does.
- A contract test parses the captured real response through the generated models, which is what catches the hand-written spec drifting from the live service.
- **BREAKING for the sibling change**: `add-product-catalog-page` currently plans `ProductModel`, `ProductSearchResponseModel` and `ProductRemoteDataSourceImpl` by hand. Those are replaced by the generated client plus a mapper from generated DTOs to domain entities. That change's design and tasks are updated as part of this one, and it also takes over the app-wiring work, which cannot run here because the app's domain and data layers do not exist yet. It has 0 of 26 tasks done, so nothing is thrown away.

## Capabilities

### New Capabilities

- `catalog-api-contract`: what the OpenAPI document must describe about the catalog service, so that it is the single record of the contract.
- `generated-api-client`: how the client package is produced and regenerated, what is hand-maintained inside it, and what the app may depend on.

### Modified Capabilities

None. `product-search-api` exists only as a delta inside the unarchived `add-product-catalog-page`, so it is revised there rather than through a delta here.

### Non-goals

- Changing any app behaviour: the screen, the states, the sorting and the pagination stay exactly as `add-product-catalog-page` specifies them.
- Describing endpoints the app does not call. Only `/v1/products/search` exists; every other path returns the gateway's 403.
- Publishing the package, a mock server, or generating clients for other languages.
- Automating regeneration in CI, or failing a build when the live service diverges from the document.

## Impact

- New: `openapi/catalog-api.yaml`, `test/fixtures/product_search_nike.json`, `packages/catalog_api/` (generated, committed) with its hand-maintained `pubspec.yaml`, `analysis_options.yaml` and `.openapi-generator-ignore`.
- Modified: root `pubspec.yaml` (adds the `catalog_api` path dependency, the `openapi_generator_cli` dev dependency and the new workspace member).
- Modified planning: `add-product-catalog-page` design and tasks, whose data layer becomes a mapper over the generated client, and which absorbs the DI and repository wiring.
- Tooling: regeneration requires Java (17 verified present) because the OpenAPI Generator is a Java program.
