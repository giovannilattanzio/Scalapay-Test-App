# Tasks

## 1. Atoms: semantics and tap targets

- [x] 1.1 [design-system] Add `flutter_localizations` (SDK) as a dev dependency of `packages/scalapay_ui` and write failing semantics tests in `test/atoms_test.dart`: enabled button, enabled chip, unselected radio and search action expose `hasTapAction: true` with label and role, and performing `SemanticsAction.tap` (via `tester.semantics.tap` / `SemanticsOwner.performAction`) invokes the callback; disabled button and selected radio have no tap action. Verify: tests run and the failures match the audit (if tap actions already exist, record it and skip the fix in 1.2) — design-atoms "Interactive atoms are operable with assistive technology"
- [x] 1.2 [design-system] Pass `onTap` to the existing `Semantics` node of `ScalapayButton`, `ScalapayFilterChip`, `ScalapayRadio` (null when selected) and the search action (design D1). Verify: 1.1 tests pass, `flutter test` in `packages/scalapay_ui` green
- [x] 1.3 [design-system] Add optional `actionLabel` to `ScalapaySearchField`, defaulting to `MaterialLocalizations.of(context).searchFieldLabel` (D2); remove the hardcoded `'Search'`. Verify: tests for caller label and Italian locale default (`GlobalMaterialLocalizations` delegate, `Locale('it')`) pass — design-atoms "Search field"
- [x] 1.4 [design-system] Give `ScalapayFilterChip` a 44px minimum tap box with the 32px pill centered (D3). Verify: new test tapping 5px above the pill invokes the callback and the pill `Material` is still 32 tall; existing layout scenarios still pass; regenerate the chip golden with `flutter test --update-goldens test/goldens/filter_chip_golden_test.dart` and review the diff — design-atoms "Filter chip"
- [x] 1.5 [design-system] Add `meetsGuideline(labeledTapTargetGuideline)` and `meetsGuideline(iOSTapTargetGuideline)` tests for each enabled interactive atom. Verify: they pass — design-atoms "Interactive atoms meet the minimum tap target"

## 2. Molecules and organisms

- [x] 2.1 [design-system] Make `ScalapayProductCard` a single semantics container whose label is name, store, price line and installments line, built from the same formatted strings, with the image excluded (D4). Verify: test in `test/molecules/product_card_test.dart` with the Italian scenario finds one node with the label parts in order and no image node; product card golden unchanged — design-molecules "Product card is announced as one element"
- [x] 2.2 [design-system] Add optional `closeLabel` to `BottomSheetFrame`, both sheets and both `show` methods, defaulting to `MaterialLocalizations.of(context).closeButtonTooltip`, and give the close `Semantics` its label and `onTap` (D1, D2). Verify: tests for default Italian label, caller label and screen-reader tap invoking `onClose` once in `test/organisms/bottom_sheet_frame_test.dart` — design-organisms "Bottom sheets are usable with assistive technology"
- [x] 2.3 [design-system] Wrap the filters sheet price error in `Semantics(liveRegion: true)` (D5). Verify: test asserts `isLiveRegion: true` on the error node in `test/organisms/filters_bottom_sheet_test.dart`
- [x] 2.4 [design-system] Replace the fixed heights holding text (sort row 64, price title 24) with minimum heights (D6). Verify: tests pump both sheets with `TextScaler.linear(2)` and long labels, `tester.takeException()` is null and every option is found; bottom sheet goldens at scale 1 unchanged — product-catalog "Catalog screen supports large text"
- [x] 2.5 [design-system] Add guideline tests (`labeledTapTargetGuideline`, `iOSTapTargetGuideline`) for both sheets. Verify: they pass

## 3. Tokens

- [x] 3.1 [design-system] Add `test/contrast_test.dart` computing WCAG contrast for the token pairs with a known-exceptions map (textSecondary on background 3.44, on surface 3.22, error on background 4.38, textDisabled as inactive) that also fails if an exception becomes compliant (D7); document the exceptions in the `ScalapayColors` doc comment. Verify: test passes; temporarily lowering `textPrimary` to `#9E9E9E` makes it fail naming the pair — design-tokens-theme "Text contrast of color tokens is measured"

## 4. Catalog screen

- [x] 4.1 [presentation] Add `catalog.loading` to `assets/translations/it.json` ("Caricamento prodotti") and `en.json` ("Loading products"). Verify: `test/localization/translations_test.dart` (key parity) passes
- [x] 4.2 [presentation] Mark the `CatalogHeader` title as a header, label the spinners in `CatalogLoading` and `CatalogGridFooter` with `catalog.loading`, and make the `CatalogMessage` text and the load-more error text live regions (D5). Verify: widget tests assert `isHeader`, the loading label and `isLiveRegion` for initial, empty, failure and load-more failure — product-catalog "Catalog screen is usable with assistive technology"
- [x] 4.3 [presentation] Add `test/presentation/catalog/pages/catalog_page_a11y_test.dart`: page with results, empty, failure and load-more failure through `pumpApp`, each meeting `labeledTapTargetGuideline` and `iOSTapTargetGuideline`, and each product card exposed as one node in grid order. Verify: tests pass
- [x] 4.4 [presentation] Add large-text tests: catalog page with results at `textScaleFactor: 2.0` on 375×812 and 320×568, and the filters and sort sheets opened from the page at 2.0. Also run the results case with a non-linear text scaler reproducing Android 14+ (small font sizes scaled about 2x, large sizes much less), since `TextScaler.linear` hides bugs where a layout length is passed to `textScaler.scale` as if it were a font size (found in 7.2: cards overflowed by 92px on an Android API 37 emulator at font scale 2.0). Verify: no exception reported with either scaler; fix any overflow found in catalog widgets with minimum sizes, or with a scale factor derived from the font sizes actually rendered, never by scaling layout lengths — product-catalog "Catalog screen supports large text"

## 5. Widgetbook

- [x] 5.1 [design-system] Expose the new `actionLabel` and `closeLabel` as knobs in the search field and bottom sheet use cases. Verify: in `packages/scalapay_ui/widgetbook`, `dart run build_runner build --delete-conflicting-outputs` and `flutter analyze` are clean
- [x] 5.2 [design-system] Add `widgetbook/test/widgetbook_a11y_test.dart`: move the route discovery out of `widgetbook_smoke_test.dart` into a shared helper, open every use case with `?path=<route>&preview` and check `labeledTapTargetGuideline` and `iOSTapTargetGuideline`, one test per route (D9). Verify: all pass after groups 1–2; temporarily reverting the chip tap box to 32px makes the filter chip use cases fail by name; the smoke test is still green — design-widgetbook "Use cases meet accessibility guidelines"

## 6. Agent checklist

- [x] 6.1 [tooling] Add an "## Accessibility" section to `.claude/agents/flutter-design-system.md` with the design-system rules of D10, and an accessibility test step to its "Steps". Verify: the section is present, uses the same rule style as "Rules", and contradicts none of the existing rules (for example the Figma-measured sizes stay allowed for the visual box)
- [x] 6.2 [tooling] Add an "## Accessibility" section to `.claude/agents/flutter-presentation.md` with the presentation rules of D10. Verify: the section is present and consistent with "Constraints" and "Design Input"

## 7. Verification

- [x] 7.1 [tooling] Run `dart format lib test`, `flutter analyze` and `flutter test` in the app and in `packages/scalapay_ui`, plus `flutter test integration_test -d <simulator>`. Verify: all clean and green
- [x] 7.2 [tooling] Manual screen-reader pass on a real runtime: iOS simulator with VoiceOver (Accessibility Inspector) and an Android emulator with TalkBack. Check: search action and close button are read in Italian ("Cerca", "Chiudi"), chips/buttons/radios activate with double tap, each card reads as one item, an empty search and a network failure are announced, and the app at the largest system font shows no clipped text. Verify: short findings note added to the PR description; any defect found becomes a new task here
