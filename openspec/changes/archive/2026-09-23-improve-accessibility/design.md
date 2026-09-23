# Design

## Context

Audit findings (read-only pass over `packages/scalapay_ui/lib` and `lib/src/presentation/catalog`), see proposal.md for motivation:

| Where | Finding | Severity |
|---|---|---|
| `BottomSheetFrame` close button | `Semantics(button: true)` with no label: announced as "button" | high |
| `ScalapayButton`, `ScalapayFilterChip`, `ScalapayRadio`, search action | `Semantics(..., excludeSemantics: true)` wraps an `InkWell`; excluding descendants drops the `InkWell`'s tap action, so the node likely has no `SemanticsAction.tap`. Existing tests use `tester.tap` (hit testing) and `matchesSemantics` only on disabled/selected states, so nothing would catch it | high (to confirm with a failing test first) |
| `ScalapaySearchField` | action button label hardcoded `'Search'` | medium |
| `ScalapayFilterChip` | 32px tall, below 44 | medium |
| `ScalapayProductCard` | 4–5 separate text nodes per card plus the image node | medium |
| `CatalogMessage`, `CatalogGridFooter`, `CatalogLoading` | state changes not announced; spinners unlabeled | medium |
| `CatalogHeader` title | not a header | low |
| `ScalapaySortBottomSheet` rows | fixed `SizedBox(height: 64)`: a label wrapping to two lines at 2.0 text scale overflows | medium |
| `_PriceCard` title | fixed `SizedBox(height: 24)`: p3Medium at 2.0 is ~39 tall | medium |
| Tokens | `textSecondary` 3.44:1 / 3.22:1, `error` 4.38:1 | documented only (user decision) |

Already fine: button 44 tall, radio rows 48+, search action 45, close 58×65, sheet title is a header, radios announce checked/group, grid height scales with `textScaler`, `showModalBottomSheet` provides the localized barrier dismiss label, text fields are labeled by `labelText`.

## Goals / Non-Goals

**Goals:** fix every finding above except contrast; lock the result in with semantics and guideline tests so regressions fail CI.

**Non-Goals:** visual redesign; golden changes other than those forced by layout boxes (chip hit area); integration tests with a real screen reader.

## Decisions

### D1. Keep `excludeSemantics`, add the action on the `Semantics` node
Each interactive atom keeps one explicit `Semantics` node with `excludeSemantics: true` (the label stays exactly the caller's text, no duplicated inner `Text` node) and passes `onTap` to it: `onPressed` for button and chip, `_selected ? null : () => onChanged(value)` for radio, `_submit` for the search action, `onClose` for the close button.
Alternative: drop `excludeSemantics` and use `MergeSemantics`. Rejected: the merged label would also pick up icon/inner text nodes and the label becomes implementation-dependent.

### D2. Localized defaults from `MaterialLocalizations`
New optional params, non-breaking:
- `ScalapaySearchField({String? actionLabel})`, default `MaterialLocalizations.of(context).searchFieldLabel`.
- `BottomSheetFrame({String? closeLabel})`, and `closeLabel` added to `ScalapayFiltersBottomSheet`, `ScalapaySortBottomSheet` and both static `show` methods, default `MaterialLocalizations.of(context).closeButtonTooltip`.
The app's `easy_localization` delegates already include `GlobalMaterialLocalizations`, so it gets "Cerca"/"Chiudi" in Italian with no new keys. The design system keeps its rule of not owning translations. `scalapay_ui` gets `flutter_localizations` (SDK) as a **dev** dependency only, for the Italian-locale tests.
Alternative: required `String` params. Rejected: breaks every call site and Widgetbook for no gain.

### D3. Chip tap target: taller layout box, same pill
`ScalapayFilterChip` lays out in a box of `max(44, pill height)` with the 32px pill centered vertically; the `InkWell`/`Semantics` cover the whole box, the `Material` pill keeps `StadiumBorder` and 32 height. `CatalogToolbar` is 58 tall, so it fits. Private constant `_minTapTarget = 44.0` with a comment (no token). The chip golden grows by 12px of transparent space; regenerate it.
Why 44 and not Material's 48: the design is iOS-first (Figma 44px button), 44 is Apple HIG and WCAG 2.5.5, 2.5.8 AA only needs 24; tests use `iOSTapTargetGuideline`.

### D4. Product card semantics
Wrap the card in `Semantics(container: true, label: <name>\n<store>\n<priceLine>[\n<installmentsLine>], excludeSemantics: true)`. The label is built from the same strings the card renders (same `NumberFormat`), so it cannot drift. The image is excluded with it. The card is not tappable today, so no action.

### D5. Announcements
- `CatalogMessage` text: `Semantics(liveRegion: true)`.
- `CatalogGridFooter` failure text: `Semantics(liveRegion: true)`.
- `_PriceCard` error text: `Semantics(liveRegion: true)`.
- Spinners: `CircularProgressIndicator(semanticsLabel: 'catalog.loading'.tr())` in `CatalogLoading` and `CatalogGridFooter`. New key `catalog.loading`: it "Caricamento prodotti", en "Loading products".
- `CatalogHeader` title: `Semantics(header: true)`.
`liveRegion` rather than `SemanticsService.announce`: declarative, testable with `matchesSemantics(isLiveRegion: true)`, and Flutter maps it on both Android and iOS.

### D6. Large text
Replace fixed heights that hold text with minimums: sort row `SizedBox(height: 64)` → `ConstrainedBox(minHeight: 64)` (divider stays at the bottom), price title `SizedBox(height: 24)` → `ConstrainedBox(minHeight: 24)`. Sheets already scroll inside `showScalapayModalSheet`.
Catalog screen (decided during apply, after 2.0 tests found overflows): the product grid's `maxCrossAxisExtent` grows with the text scale, so at large scales a phone shows one wider column and the installments line stops wrapping, while `mainAxisExtent` keeps the cheap scaled estimate. Both are scaled by a factor read from the scaler at the card's own font sizes (`textScaler.scale(fontSize) / fontSize`, taking the largest across the card's text styles), never by passing a layout length to `textScaler.scale`: on Android 14+ the system scaler is non-linear, so scaling 170 or 220 as if they were font sizes barely enlarges them while 12-14px text doubles (the 7.2 manual pass found cards overflowing by 92px, two columns, on an API 37 emulator at font scale 2.0; iOS and the `TextScaler.linear` tests were fine). Rejected: measuring every product's text with `TextPainter` (a layout per product on every scroll frame, cells jumping when a page with longer texts arrives, and a copy of the card's internals in the app), and truncating price/installments in the card (hides the information). The toolbar's chips go in a `Wrap` aligned to the trailing edge with a minimum height of 58, so at 200% on a narrow screen "Ordina" moves to a second line and both stay visible; rejected: a horizontal scroll that hides "Filtri" off screen. Verified by widget tests at `textScaleFactor: 2.0` (app: `pumpApp`; package: `MediaQuery` with `TextScaler.linear(2)`), asserting `tester.takeException()` is null, plus a non-linear scaler reproducing Android 14+ for the catalog grid.

### D7. Contrast test
`packages/scalapay_ui/test/contrast_test.dart` computes WCAG relative luminance from the tokens (no dependency) for the pairs in the design-tokens-theme delta, with a `const _knownExceptions = {pairName: (ratio, reason)}` map. A pair below 4.5 not in the map fails with its name and ratio; an exception that becomes compliant also fails, so the list stays honest. Exceptions also documented in a doc comment on `ScalapayColors`.
Alternative: `textContrastGuideline` in widget tests. Rejected for tokens: it samples rendered pixels, flaky with anti-aliasing, and would fail on the known exceptions anyway.

### D8. Guideline tests
Package: one test per atom/organism with `expectLater(tester, meetsGuideline(labeledTapTargetGuideline))` and `meetsGuideline(iOSTapTargetGuideline)`, plus `matchesSemantics(hasTapAction: true, ...)` for enabled states. App: `test/presentation/catalog/pages/catalog_page_a11y_test.dart` with the page in success, empty, failure and load-more-failure states, via `pumpApp` and a mocked cubit state, as existing page tests do.

### D9. Guideline test over every Widgetbook use case
`packages/scalapay_ui/widgetbook/test/widgetbook_a11y_test.dart` reuses the route discovery of `widgetbook_smoke_test.dart` (move `_useCaseRoutes` to a shared `test/support/use_case_routes.dart`) and opens each use case with `?path=<route>&preview`. Widgetbook 3.25 (the locked version) renders only the use case in preview mode, without navigation, search or knob panels, so `meetsGuideline` evaluates the component and not Widgetbook's own UI, which is outside our control. Each use case is checked with `labeledTapTargetGuideline` and `iOSTapTargetGuideline`, with the test name set to the route so a failure names the use case. Use cases that open a modal are checked on their trigger button only (the sheets themselves are covered by task 2.5).
The smoke test selects `WidgetbookState` through the "Search" panel text, which does not exist in preview mode: the new test asserts selection through `WidgetbookState.of` on the use case's root instead.
Fallback if preview mode still shows Widgetbook chrome: a small helper that runs the same two checks only on semantics nodes under the use case's subtree.
Alternative: a hand-written list of components to check. Rejected: it has to be remembered for every new component, which is exactly the gap this test closes.

### D10. Accessibility checklist in the agent definitions
A "## Accessibility" section in `.claude/agents/flutter-design-system.md` and `.claude/agents/flutter-presentation.md`, written as rules in the same style as their existing "Rules"/"Constraints", derived from D1–D6 and D9. Design system: one `Semantics` node per interactive element with label, role, state and `onTap`; tap area of at least 44×44; minimum heights, never fixed heights, around text; labels from the caller or `MaterialLocalizations`, never hardcoded; `liveRegion` for messages; a semantics test and a 2.0 text scale test per component; the Widgetbook guideline test stays green. Presentation: screen titles as headers; progress indicators with a translated `semanticsLabel`; state messages as live regions; every announced text from the translations; a `meetsGuideline` test and a 2.0 text scale test per new page. The design-system agent's "Steps" gain an explicit accessibility test step.
The checklist makes correct code likely; the tests (D8, D9) are what enforce it, including for code not written through these agents.

## Contracts

No domain, data, DI or routing changes.

- `ScalapaySearchField({Key? key, TextEditingController? controller, String? hint, ValueChanged<String>? onSubmitted, String? actionLabel})`
- `ScalapayFiltersBottomSheet({..., String? closeLabel})`, `ScalapayFiltersBottomSheet.show(context, {..., String? closeLabel})`
- `ScalapaySortBottomSheet<T>({..., String? closeLabel})`, `ScalapaySortBottomSheet.show<T>(context, {..., String? closeLabel})`
- `BottomSheetFrame({..., String? closeLabel})` (internal)
- Translation key `catalog.loading` in `assets/translations/it.json` and `en.json`.
- The app passes no `actionLabel`/`closeLabel` (Material defaults are correct and localized).

## Risks / Trade-offs

- [D1 hypothesis wrong: the tap action already survives `excludeSemantics`] → first task writes the `hasTapAction: true` assertions; if they pass, the atom change is skipped and only tests are kept.
- [`liveRegion` announces on every rebuild that changes the label] → messages only change on state transitions; acceptable.
- [Chip golden and toolbar layout shift] → pill unchanged; regenerate only the chip golden and check the toolbar golden/widget test still centers chips in 58.
- [Semantics tests pass but real TalkBack/VoiceOver behaves differently] → manual pass on an iOS simulator (VoiceOver via Accessibility Inspector) and an Android emulator (TalkBack), task 7.2.
- [Widgetbook preview mode renders chrome in a future version, or a knob default produces an empty label] → D9 fallback helper; knob defaults are non-empty.
- [Contrast exceptions remain] → accepted by the user; the test and doc comment make them visible for design.

## Migration Plan

Non-breaking, ships in one PR. Rollback is a revert.
