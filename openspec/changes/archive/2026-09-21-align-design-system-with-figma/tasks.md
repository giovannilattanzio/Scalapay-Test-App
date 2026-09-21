# Tasks

## 1. Tokens

- [x] 1.1 [design-system] Add `ScalapayColors.primaryMuted` (`#CACCF2`, UI/Buttons/Lightweight/Lillac/Hover) and `ScalapayColors.textInput` (`#3A4045`, Grayscale/850), and include them in `lerp` and `entries`. Verify: `tokens_theme_test.dart` asserts both values, and that `textInput` is a separate entry from `textStoreName`. (Foundations are defined as named tokens)
- [x] 1.2 [design-system] Add `ScalapayTypography.p2Medium` (Poppins 500, 14, height 22.4/14), include it in `lerp` and `entries`, and comment it as Mobile/P2/500. Verify: a test asserts size 14, line height 22.4 and weight 500, and the Widgetbook typography page lists it. (Typography uses Poppins from bundled assets)

## 2. Atoms

- [x] 2.1 [design-system] `ScalapayButton`: 16 (`spacing.s`) horizontal padding for both variants. Verify: a test in `atoms_test.dart` checks that the intrinsic width equals the label width + 32 for primary and tertiary, and the 44 height test still passes. (Buttons)
- [x] 2.2 [design-system] `ScalapayFilterChip`: add the per-icon layout (`order` → left 4, icon 24, gap 0, right 8; others → 8, 20, 2, 10) as named constants. Verify: tests check that the width is the label width + 40 with `filter` and + 36 with `order`, the icon size is 20 and 24, and the height is 32. (Filter chip)
- [x] 2.3 [design-system] `ScalapayTextField`: vertical content padding that makes the field 56 tall, and the value text in `textInput`. Verify: a test measures 56 for an empty field and for a filled one without an error, and checks the value color is `#3A4045`. The existing floating-label, error and formatter tests still pass. (Text field with floating label)
- [x] 2.4 [design-system] `ScalapayRadio`: 20px ring centered in a 24 box, 10 gap, label in `p2Medium`, unselected ring in `primaryMuted`. Verify: tests check that the label starts 34 from the left, the label style is `p2Medium`, and the unselected ring color is `#CACCF2`. The selection test still passes. (Radio)
- [x] 2.5 [design-system] `ScalapayTextField`: the floated label must appear at 11 (P5) on screen. Give `floatingLabelStyle` (both the normal and the error color) the `p5` font size divided by Flutter's 0.75 floating label scale, as a named constant. Verify: a test with a filled field measures the label's rendered font size (paragraph × transform scale) at 11 ± 0.1. The height 56, floating-label, error and formatter tests still pass. (Text field with floating label: Floated label size)

## 3. Organisms

- [x] 3.1 [design-system] `BottomSheetFrame`: handle alpha 0.4. Verify: `bottom_sheet_frame_test.dart` asserts the handle color is `textDisabled` at 0.4 opacity. (Bottom sheet frame)
- [x] 3.2 [design-system] `ScalapayFiltersBottomSheet`: card padding `fromLTRB(16, 14, 16, 16)`, 24-tall title row aligned center-left, dash 10, footer gap 6. Verify: tests check that the price card is 126 tall without an error and the buttons are 6 apart. The equal-width, controller and error-message tests still pass. (Filters bottom sheet)
- [x] 3.3 [design-system] `ScalapaySortBottomSheet`: rows `SizedBox(height: 64)` with the radio centered and a `ScalapayDivider` inside every row but the last, and card side padding 15. Verify: tests check that each row is 64 tall, a four-option card is 256 tall and there are exactly three dividers. The selection and close-delay tests still pass. (Sort bottom sheet)

## 4. Goldens and checks

- [x] 4.1 [design-system] Regenerate the goldens in `packages/scalapay_ui` with `flutter test --update-goldens`, open the changed images, and compare the button, chip, radio, text field and both sheets with the Figma frames `0:3908`, `0:4054` and `0:4205`. Verify: the diff shows only the intended changes, and `flutter test` in `packages/scalapay_ui` is green. (Golden tests cover every component state)
- [x] 4.2 [design-system] Run `dart format`, `flutter analyze` and `flutter test` in `packages/scalapay_ui`, in `packages/scalapay_ui/widgetbook` and at the app root. Verify: everything is clean and green, and no app code needed changes.
- [x] 4.3 [design-system] After 2.5, regenerate the goldens again. Only the text field goldens (filled, error) and the filters sheet goldens (empty, filled, error) should change. Then compare `filters_sheet_filled.png` with the Figma node `0:4202` for the label size, and rerun the checks from 4.2. Verify: the label matches Figma, no other golden changed, and everything is green. (Golden tests cover every component state)
