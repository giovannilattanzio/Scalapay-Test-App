# Scalapay Test App

Flutter app reproducing the Scalapay product catalog screen from Figma, backed by
the Scalapay catalog API: a text search, a price-range filter, ordering by
relevance or price, and a two-column product grid that appends further pages as
you scroll. Italian and English.

It was written for the *Flutter UI Reproduction* assessment (Mobile
Engineer/Lead). The brief asks for a faithful UI, API integration with loading
and error states, tests, clean code and "any additional notes or considerations".
This README is those notes. It explains how the work was planned, what was
measured, and which decisions were made on purpose.

## At a glance

- **Built from specs.** Twelve changes were planned in
  [OpenSpec](#how-the-work-was-planned-spec-driven-with-openspec) (proposal,
  specs, design, tasks), implemented, then archived. `openspec/specs/` holds 12
  capabilities and 71 requirements, and they describe the code as it is now.
- **The API was measured, not assumed.** The service publishes no API
  description, so its contract was reverse-engineered by probing it and written
  down as an OpenAPI document (`openapi/catalog-api.yaml`). The client is
  generated from that document. Three probed behaviours shaped the design: past
  the last page the service returns an earlier page again, `found` is not a
  total, and any sort field other than price is silently ignored.
- **The Figma file was measured, not eyeballed.** Every node was read through
  the Figma REST API, and the built screen was checked at 375x812 against those
  numbers. Where the app differs from the mockup, it is on purpose, and each
  difference is [listed with its reason](#deliberate-divergences-from-the-mockup).
- **A design system package.** `packages/scalapay_ui` holds the tokens, atoms,
  molecules and organisms, with a Widgetbook app, golden tests and a WCAG
  contrast test. The app never hardcodes a color, text style or spacing.
- **436 automated tests plus 6 integration tests, all offline.** Line coverage
  is 93.9% for the app and 99.6% for the design system. The tests include
  an architecture rule (the generated client stays inside the data layer) and accessibility guideline tests on
  every Widgetbook use case.
- **Fails safely.** Retries use backoff and jitter, results from superseded
  requests are dropped, the app detects the end of the list itself, and a failed
  page load keeps the grid on screen.

## Contents

1. [Getting started](#getting-started)
2. [How the brief was met](#how-the-brief-was-met)
3. [How the work was planned: spec-driven with OpenSpec](#how-the-work-was-planned-spec-driven-with-openspec)
4. [How the decisions were reached](#how-the-decisions-were-reached)
5. [History of the main changes](#history-of-the-main-changes)
6. [Technical choices: used and deliberately not used](#technical-choices-used-and-deliberately-not-used)
7. [Deliberate divergences from the mockup](#deliberate-divergences-from-the-mockup)
8. [Known API behaviour](#known-api-behaviour)
9. [Tests](#tests)
10. [The backend client is generated](#the-backend-client-is-generated)
11. [Known limitations and next steps](#known-limitations-and-next-steps)

## Getting started

### Requirements

| Tool | Version used | Needed for |
| --- | --- | --- |
| Flutter / Dart | 3.47.5 stable / Dart 3.13 (`sdk: ^3.13.4`) | everything |
| Xcode + iOS Simulator | Xcode 26.1, iOS deployment target 15.0 | running on iOS |
| Android Studio / SDK, JDK 17 | Gradle 8.14, AGP 8.11.1, Kotlin 2.2.20 | running on Android |
| JDK 17 | — | **only** to regenerate the API client |
| `lcov` (`brew install lcov`) | 2.5 | only for the HTML coverage report |

The app targets **iOS and Android**. It has no macOS desktop or web target. Widgetbook runs
on Chrome or macOS.

### From a fresh clone

```bash
git clone <repo-url> && cd scalapay_test_app
git config core.hooksPath .githooks        # once per clone: enforces Conventional Commits

flutter pub get                            # once, at the root: resolves every workspace member

# Generated sources that are not committed (*.g.dart is gitignored project-wide)
dart run build_runner build --delete-conflicting-outputs                     # app: CatalogState.copyWith
(cd packages/scalapay_ui/widgetbook && \
  dart run build_runner build --delete-conflicting-outputs)                  # Widgetbook use case tree

flutter devices                            # pick a simulator or device
flutter run -d <device-id>
```

The two `build_runner` steps are required: without them `flutter analyze` reports
17 errors from the missing `.g.dart` files. This sequence was checked on a fresh
clone; after it, `flutter analyze` is clean and every test suite passes. The
generated API client (`packages/catalog_api`) is the exception: its `.g.dart`
files are committed, so building never needs Java (see
[below](#the-backend-client-is-generated)).

The repository is a **Dart workspace**. Its members are the app, the design
system `packages/scalapay_ui`, its Widgetbook app `packages/scalapay_ui/widgetbook`,
and the generated client `packages/catalog_api`. They share one `pubspec.lock`
and one `pub get`.

### Widgetbook (the design system catalog)

```bash
cd packages/scalapay_ui/widgetbook
flutter run -d chrome        # or -d macos
```

### Everyday commands

```bash
dart format lib test && flutter analyze   # in the app and in packages/scalapay_ui
flutter test                              # app unit and widget tests
cd packages/scalapay_ui && flutter test   # design system, including goldens
cd packages/scalapay_ui/widgetbook && flutter test
flutter test integration_test -d <device> # integration suite, on a simulator or device
```

## How the brief was met

| Brief asks for | Where it is met |
| --- | --- |
| Reproduce the Figma UI, visually accurate | Figma nodes read through the REST API, measured values in the tokens, the built screen checked at 375x812, 24 goldens. Divergences are [listed with reasons](#deliberate-divergences-from-the-mockup) |
| Responsive across screen sizes | The grid derives its column count from the width (2 at 375, 4 on tablets). Cells grow with the text scale. Tested at 320, 375 and 900 wide and at 200% text, including Android 14+ non-linear scaling |
| Use the catalog API, show the data | A client generated from a [reverse-engineered OpenAPI document](#the-api-document-is-reverse-engineered), a mapper to domain entities, and infinite scroll |
| Loading and error states | Five explicit screen states (initial, loading, results, no results, failure with retry). A failed page load has its own state, so the grid stays on screen. Typed `Failure`s are mapped to translated messages |
| Unit tests for UI and API logic, adequate coverage | 436 tests plus 6 integration tests; [93.9% / 99.6% line coverage](#coverage) |
| Clean, maintainable code | Clean Architecture, with a test that keeps the generated client inside the data layer, a design system package, specs kept in sync with the code |
| Comments on complex logic | Comments explain *why* a line exists, not what it does. Examples: the pagination accumulator, the retry policy, the 57px hidden back-arrow slot, the grid cell-height formula |
| How to run and test | [Getting started](#getting-started), [Tests](#tests) |
| Additional notes | This README, `openspec/` and the commit messages |

## How the work was planned: spec-driven with OpenSpec

The project was developed with **[OpenSpec](https://github.com/Fission-AI/OpenSpec)**
and **Claude Code** as the implementation assistant. The point was to decide on
paper first, where a decision is cheap to change, and to leave a review record a
reader can follow.

### The cycle

Every piece of work went through the same four steps:

1. **Explore** (`/opsx:explore`): think through the problem, read Figma, probe
   the API, and compare alternatives. No code is written in this step.
2. **Propose** (`/opsx:propose`) creates `openspec/changes/<name>/` with four artifacts:
   - `proposal.md`: why, what changes, the capabilities it touches, and
     **non-goals**, which are mandatory and keep scope honest;
   - `specs/<capability>/spec.md`: *delta* requirements (ADDED / MODIFIED /
     REMOVED), each with testable `WHEN / THEN` scenarios;
   - `design.md`: context, **numbered decisions with the rejected alternatives**,
     contracts (entities, repository signatures, use cases, cubit state), risks;
   - `tasks.md`: small tasks, each prefixed with its layer (`[domain]`,
     `[data]`, `[presentation]`, `[infrastructure]`, `[design-system]`,
     `[tooling]`) and linked to the requirement it satisfies.
3. **Apply** (`/opsx:apply`) implements the tasks. A task is ticked only after
   `flutter analyze` is clean.
4. **Archive** (`/opsx:archive`) merges the delta specs into `openspec/specs/`,
   moves the change to `openspec/changes/archive/` and adds an entry to
   `openspec/HISTORY.md`.

So `openspec/specs/` is always the **current** behaviour of the system (12
capabilities, 71 requirements), and `openspec/changes/archive/` is the reasoning
behind it, one folder per change. To see why something is the way it is,
`grep` the archive.

### Rules that make the specs useful

`openspec/config.yaml` gives every artifact the project context (stack,
architecture, conventions) and rules. Several of those rules were added after a
concrete problem:

- **Contracts are defined in `design.md` before any code.** Entities with their
  fields, repository signatures, use case names and params, the cubit state
  shape and its status enum. Each layer is then implemented against a contract
  that was already reviewed.
- **Values that vary per call are parameters with defaults, not constants.**
  Page, page size and language travel on `ProductSearchParams`. Infinite scroll
  was later built on these parameters without changing a single signature.
- **Every change that touches an external service includes a task that makes
  one real end-to-end call.** This rule came from a real failure. The catalog
  screen once passed 118 green tests, a clean analyzer and three reviews, and
  still broke every search in the running app: the shared `Dio` had no
  `baseUrl`. Mocked tests verify how objects are wired together. They never
  verify that the wiring reaches the outside world.
- **Use cases carry the `UseCase` suffix** and live in `*_use_case.dart`, so a
  class's architectural role is readable from a file tree.

### Layer agents

Implementation is split by layer, the same way the code is. A
`flutter-orchestrator` skill (`.claude/skills/`) receives the contracts and the
task batch from `apply`. It delegates to one agent per layer, defined in
`.claude/agents/`: `flutter-domain`, `flutter-data`, `flutter-presentation`,
`flutter-infrastructure` and `flutter-design-system`. Each agent's definition
lists what it may and may not touch. For example, presentation never imports
data, and features never hardcode tokens. Two agents carry an accessibility
checklist. This keeps each step small and reviewable, and it keeps the
architecture from eroding one convenient import at a time.

`CLAUDE.md` holds the short project rules every session starts from. Commits
follow Conventional Commits, enforced by `.githooks/commit-msg`.

## How the decisions were reached

### 1. Reading the brief

The assessment PDF gives two hosts, the query template
`sort_by=${sortType}:${sortDirection}`, `sortType` ∈ {`_text_match`,
`selling_price`}, and `minPrice`/`maxPrice`. It does not say what happens at
the end of the results, whether both hosts work, or which fields can actually be
ordered by. The Figma sort sheet offers "Nome A-Z" and "Nome Z-A", which the
brief's sort types cannot produce. These open questions became the first things
to measure.

### 2. Probing the API before designing against it

Every open question was answered with `curl` against the live service, by
comparing the **id sequences** returned. Comparing the first few titles was not
enough. The findings are in [Known API behaviour](#known-api-behaviour). They
changed the design in concrete ways:

- only `catalog-api.dev-cat` is usable (`dev` answers 401 with an undocumented
  auth scheme), so only that host is declared;
- name ordering is impossible, so the name options were dropped instead of
  shipping a label that would lie;
- the service never signals the end of the list, so the client detects it with
  `ProductPageAccumulator`;
- `selling_price` arrives as `13` or `13.38`, so it is typed as `number` in the
  OpenAPI document and the generated code parses both.

Since the service publishes no API description, these findings were written as
an **OpenAPI document**, and the client is **generated** from it. That made the
contract a reviewable file instead of prose, removed the hand-written transport
code, and gave the probed edge cases a permanent home. The change that
introduced this (`add-catalog-api-client`) also **revised the sibling change**
`add-product-catalog-page` while it still had 0 of 26 tasks done. Its planned
hand-written models and data source were replaced by a mapper over the generated
DTOs, so no work was thrown away.

### 3. Figma: from screenshots to measured nodes

The design system was started while the Figma MCP server was capped by the
Figma plan (roughly one call per session), so the first atoms were measured from
screenshots and the values were confirmed one by one. When the whole file was
later downloaded through the **Figma REST API** (`GET /v1/files/<key>`, every
node, style and component instance), the numbers showed small but visible
differences in five components. The change `align-design-system-with-figma`
fixed all of them before more screens could reuse the wrong values:

- 16px button padding, and a separate layout for each chip icon;
- a 56px text field whose floated label renders at 11px. Flutter always scales
  the floated label to 75%, so the style compensates for it;
- 64px sort rows, a 126px filters card, and the handle at 40% opacity;
- three new tokens (`primaryMuted`, `textInput`, `p2Medium`).

Sixteen goldens were regenerated. The app's 121 tests at the time passed
without changes, because no public API moved.

The built screen was then **measured** at 375x812 against the Figma table in
the design. Title position, paddings, search field size, toolbar band, chip
height and column widths all match. The one geometric difference (rows about
15px further apart) is explained [below](#deliberate-divergences-from-the-mockup).

### 4. Refining changes when the first answer was wrong

Several decisions changed during review. Each change is recorded in the
archived design with the reason for it:

- **Relevance back in the sort sheet.** An early draft left relevance out,
  because Figma preselects nothing. That is true of the initial frame and false
  of everything after it: with only the price options, choosing one was a
  one-way door out of the default ordering. The sheet now offers relevance,
  price ascending and price descending, with the current sort preselected.
- **Fixed toolbar.** A draft had the Filtri/Ordina chips scroll away with the
  results, based on how the Figma layers are grouped. This was overridden during
  review: a control that changes *what* the results are must stay reachable
  without scrolling back up. A static frame cannot express scroll behaviour.
- **Pagination by id set, not by "equals page 1".** Comparing each page with
  page 1 would have worked at `per_page=30`. Measured later, at 50 and 100 the
  service repeats the *last* page instead, so that approach would have looped
  forever. Deduplicating by product id survives both, and it also prevents
  duplicate cards on a page that partly overlaps an earlier one.
- **A custom retry interceptor rather than `dio_smart_retry`.** The package was
  checked against each requirement. It retries HTTP 500 by default, retries POST
  unless told not to, uses a fixed list of delays instead of backoff with
  jitter, ignores `Retry-After`, and checks cancellation only after the wait. It
  would have saved about 20 lines of wiring while every rule still had to be
  written by hand, so it was not used.
- **Superseded requests are dropped in the cubit, not cancelled in the
  transport.** A `CancelToken` cannot pass through the domain without putting a
  Dio type there. A generation counter in `CatalogCubit` drops stale results
  instead.
- **Image memory: measured first, then kept as a safeguard.** The API's photos
  are 300×300 (360 KB decoded), so Flutter's 100 MB `ImageCache` holds about 290
  of them, almost 10 pages. Measured on a simulator, decoding at the card's
  physical width changed nothing today: 48.6 MB for 135 images before and after.
  It was kept anyway because a 1000×1000 photo would take 4 MB, and only about
  25 would fit, fewer than one page. So the design records it as a safeguard,
  not as an optimisation. It is one `LayoutBuilder` with `cacheWidth`; the
  alternatives were rejected: `cached_network_image` (native dependencies), and
  a fixed width (blurry on tablets, wasteful on small phones).

### 5. Verifying in the running app, not only in the suite

Three defects were found by **running the app**, not by the test suite. Each is
now covered by a test that was seen to fail without its fix:

- the shared `Dio` had no `baseUrl`;
- the bottom sheets put their last row under the home indicator (the platform's
  safe-area option protects only the top and sides);
- the grid stopped above the indicator instead of scrolling under it.

The first of these led to the "real end-to-end call" rule above.

## History of the main changes

One row per archived OpenSpec change. The full entries are in `openspec/HISTORY.md`.

| Date | Change | What it delivered |
| --- | --- | --- |
| 09-19 | `add-design-system-package` | Workspace package `scalapay_ui`: Poppins, `ThemeExtension` tokens, 8 atoms from Figma, Widgetbook app, the `flutter-design-system` agent |
| 09-19 | `add-golden-tests-and-atom-fixes` | Goldens for every atom, `ScalapayIcons` constants, a Widgetbook smoke test; fixed buttons stretching and the missing Widgetbook theme |
| 09-19 | `add-button-variants` | One `ScalapayButton` with `primary`/`tertiary` variants at 44px, as Figma names them; the separate text button was removed (breaking, unused) |
| 09-20 | `add-product-card-molecule` | `ScalapayProductCard`: money formatted with `intl` in the app locale, optional instalments line, new radius and color tokens |
| 09-20 | `add-bottom-sheet-organisms` | Filters and sort sheets as content-only organisms with a static `show` that reports every way of dismissing the sheet; numeric-only price fields |
| 09-20 | `add-catalog-api-client` | Reverse-engineered `openapi/catalog-api.yaml`, the generated `packages/catalog_api` (dart-dio + json_serializable), a contract test on a captured response |
| 09-21 | `add-product-catalog-page` | The catalog screen on the generated client across the four layers: five states, infinite scroll, sort, price filter, it/en with `easy_localization` |
| 09-21 | `align-design-system-with-figma` | Components aligned with the Figma nodes read through the REST API; three new tokens; 16 goldens regenerated |
| 09-22 | `add-dio-retry-interceptor` | Custom retry interceptor (backoff with full jitter, `Retry-After`, idempotent requests only); stale-result guard in the cubit |
| 09-22 | `add-catalog-integration-tests` | `integration_test` suite on the real app shell, cubit and DI graph, with only the repository faked |
| 09-23 | `improve-accessibility` | Screen reader semantics, 44px tap targets, announced state messages, 200% text, contrast test, guideline tests on every Widgetbook use case |
| 09-23 | `add-image-decode-cache` | Product images decoded at no more than the card's physical width (`cacheWidth`). No effect on today's 300×300 photos, measured; kept as a safeguard against larger ones |

Git history follows the same sequence. The work from 09-19 to 09-21 (the
boilerplate, design system, card, sheets, API client and catalog screen) was
squashed into `7326fcc`, whose message keeps the original commits. Since then,
one commit per change, in the Conventional Commits format (see `git log`).

## Technical choices: used and deliberately not used

### Used

| Concern | Choice | Why |
| --- | --- | --- |
| Architecture | Clean Architecture, layer-first (`lib/src/<layer>/<feature>/`) | The catalog is one feature, so feature-first would add folders without adding isolation. The rule *presentation → domain ← data* is set in each layer agent's definition; a test keeps the generated client inside `data` |
| State | `flutter_bloc` Cubit + `Equatable` + `copy_with_extension` | One screen with explicit states. A Cubit keeps transitions testable with `bloc_test` and needs no event classes |
| DI | `get_it` (global `injector`) | Simple and explicit. A cubit is registered only if it is shared or has several dependencies; otherwise its `BlocProvider` builds it |
| Errors | Own `Result<T>` / typed `Failure` subclasses | No library needed. The view picks the message from the `Failure` type, so no text crosses the data layer |
| HTTP | `dio`, one shared instance | Interceptors (retry), timeouts, and the generated client reuses it |
| API client | OpenAPI Generator `dart-dio` + `json_serializable`, run as an explicit command | Makes the contract a file. `json_serializable` was already in the stack, which avoids adding `built_value` for one endpoint |
| Navigation | `go_router` | One route today, but it is the standard for deep links and guards |
| Localization | `easy_localization`, `it` + `en` JSON | Runtime locale switching, and the locale also drives money formatting. A test keeps the two files' keys in sync |
| Money | `intl` `NumberFormat` in the app locale | Fixes Figma's two inconsistent formats in one card |
| Design system | Own package + Widgetbook | Components reviewed in isolation, one token source, goldens per state |
| Tests | `flutter_test`, `bloc_test`, `mocktail`, goldens, `integration_test` | `mocktail` needs no codegen. Goldens use the real Poppins font |
| Tooling | Dart workspace, OpenSpec, Conventional Commits hook | One `pub get`; plans and decisions reviewable in the repo; a readable history |

### Deliberately not used

| Not used | Why not |
| --- | --- |
| `dartz` / `fpdart` (`Either`) | A local `Result<T>` covers the need with no dependency and reads as plain Dart |
| `freezed` | `Equatable` + `copy_with_extension` cover the state classes with far less generated code |
| `built_value` | The OpenAPI generator's default serializer. `json_serializable` was already in the project |
| The `openapi_generator` build_runner builder | Cannot be installed: its `analyzer <9` constraint does not overlap `json_serializable`'s `>=10`. It would also regenerate on every build, which was never wanted |
| `dio_smart_retry` | Its defaults conflict with the retry rules (retries 500 and POST, fixed delays, no `Retry-After`, cancellation checked late) |
| `http` package | The failure mapping and interceptors are written against Dio |
| `catalog-api.dev.scalapay.com` | Answers 401 with an undocumented auth scheme and no token was provided; adding it later is one `servers` entry |
| Client-side name sort | With pagination it would sort each page separately. Measured: 22 of page 2's 30 products belong before the end of page 1 |
| A hardcoded page count or `found` as a total | Both were measured to be wrong: the reachable window changes with `per_page`, and `found` equals the page size |
| Retrying HTTP 500 | Usually a deterministic server bug; repeating the request hides it |
| Request cancellation through the domain | Would put a Dio type in the domain. Stale results are dropped by a generation counter instead |
| `cached_network_image` | Considered for the image change and rejected: it adds native dependencies and would force changes to about ten tests. Flutter's in-memory `ImageCache` plus `cacheWidth` already bounds memory; a disk cache was not a goal |
| Dark mode, extra brands | Not in the design |
| Changing Figma colors below WCAG AA | Recorded as documented exceptions in the contrast test, to raise with design instead of overriding it silently |

## Deliberate divergences from the mockup

The screen reproduces Figma frame `0:3908`. Its geometry was checked by
measuring the built screen at 375x812, not by eye. Five things differ on
purpose:

- **The sort sheet offers three options, not Figma's four.** Figma shows "Prezzo
  crescente", "Prezzo decrescente", "Nome A-Z" and "Nome Z-A". The two name
  options are **removed**: the catalog service can only order by selling price,
  so offering them would show relevance order under a name label, which the user
  could not detect (see [Known API behaviour](#known-api-behaviour)). A
  "Rilevanza" option is **added** as the first entry, because it is the ordering
  the screen starts in and Figma provides no way back to it: with only the price
  options, choosing one is a one-way door out of the default. The mockup shows a
  single frame and never the screen after a choice, so it could not surface
  that.
- **Money follows the app locale.** Figma renders the price as "85,00€" and the
  instalment as "€23,33", two conventions in one card. The app formats both
  with `intl` using the active locale, so Italian gives "85,00 €" and English
  "€85.00".
- **Rows sit about 15px further apart than Figma.** The grid derives its cell
  height from the design's 164x195 image ratio plus the text block, with a
  cushion that scales with the text. Figma's nominal text block overflows once
  real font metrics are laid out, by ~1px at the default text size and ~15px
  at 1.5x, so the cushion is what keeps the layout intact for anyone who
  enlarges the system font.
- **The Filtri and Ordina chips are fixed, not scrolling.** In Figma the chips
  row is grouped with the scrolling content, but a control that changes *what*
  the results are should stay reachable at any scroll position. Otherwise a
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
which is why the sort sheet drops Figma's two name options. Doing it
client-side was rejected: with pagination it would sort only the current page,
and measured on `q=nike`, 22 of page 2's 30 products belong before the end of
page 1. The result would be two alphabetical lists shown one after the other,
not one.

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
an earlier page again: byte-identical, HTTP 200, never short, never empty,
never an error. Measured at `q=nike`:

| `per_page` | distinct pages | then |
| --- | --- | --- |
| 30 | 10 (300 products) | page 11 repeats page **1** |
| 50 | 7 (350 products) | page 8 repeats page **7** |
| 100 | 4 (400 products) | page 5 repeats page **4** |

Note the repeated page is not always page 1: at larger page sizes it is the
last valid page. **Consequence:** the app detects the end itself, in
`ProductPageAccumulator`, by recognising a page that contributes no product id
it has not already seen. That choice was made before this variation was
observed, and it is what makes the app survive it: a check of "is this page
equal to page 1" would have worked at `per_page=30` and looped forever at 50 or
100. The accumulator also stops on a short page and after a hard maximum, so the
sequence terminates whatever the service does.

Finally, the reachable window moves with the page size, so **the page count must
not be hardcoded** by any client.

## Tests

```bash
flutter test                                        # the app: 172 tests
cd packages/scalapay_ui && flutter test             # the design system, including goldens: 193 tests
cd packages/scalapay_ui/widgetbook && flutter test  # every Widgetbook use case: 71 tests
flutter test integration_test -d <device>           # 6 end-to-end journeys, on a simulator or device
```

No test performs network access. The API tests run against a response captured
from the live service, in `test/fixtures/`, and the widget tests read the real
`assets/translations/*.json` from disk rather than a copy, so changing a string
there makes the tests that assert it fail. Goldens were generated on macOS;
other platforms may differ by a few pixels.

The integration suite needs a simulator or device (`flutter devices`): the app
has no macOS desktop or web target.

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
- `presentation/catalog/widgets/catalog_product_tile_test.dart`: also renders the tile at 3x pixel density
  and checks the image is decoded at the image area's physical width (`ResizeImage`).

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

### The API document is reverse-engineered

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

## Known limitations and next steps

- **No CI.** The commands above are the checks a pipeline would run (format,
  analyze, three test suites, coverage threshold). Goldens would need a pinned
  platform, since they were generated on macOS.
- **Contrast exceptions.** `textSecondary` (3.44:1 and 3.22:1) and `error`
  (4.38:1) are below WCAG AA. They are kept as in Figma and recorded in the
  contrast test, to raise with design.
- **Manual fixture refresh.** The contract test cannot notice a change in the
  live service made after the fixture was captured.
- **No request cancellation.** Stale results are dropped but still downloaded.
  Cancellation needs a domain-level abstraction first.
- **No disk cache for images.** Images live in Flutter's in-memory `ImageCache`
  (about 290 of today's photos fit), each decoded at no more than its display
  size, but they are downloaded again on every launch.
- **Out of scope by design:** product detail, tapping a card, favourites, dark
  mode, the hidden Figma counter (the API has no total to fill it with).
