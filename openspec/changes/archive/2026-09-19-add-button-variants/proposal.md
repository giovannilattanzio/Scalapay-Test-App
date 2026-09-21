# Proposal

## Why

The Figma file names the two buttons of the filters sheet "Primary" and "Tertiary". The design system had them as two unrelated components (a button and a text button), so a tertiary button was modeled as a separate widget and the spec described a "text button". Variants of one control belong in that control, and Figma sets both at 44px, not 48. This change records the implemented code so the spec matches it.

## What Changes

- The button component takes a variant: `primary` (default) or `tertiary`.
- **BREAKING**: the separate text button component is removed; its role is the tertiary variant. No feature used it yet.
- Button minimum height goes from 48 to 44 for both variants, as in Figma.
- Tertiary has no fill (transparent material), lilac label, and a disabled label color.
- Golden tests, Widgetbook use cases and behavior tests cover both variants.

## Capabilities

### New Capabilities
<!-- None. -->

### Modified Capabilities
- `design-atoms`: the `Buttons` requirement changes from "filled button and text button, minimum height 48" to one button with `primary` and `tertiary` variants, minimum height 44.

### Non-goals
- A secondary variant: it does not exist in the Figma file.
- Enlarging the tap area to Material's 48px without changing the look.
- Full-width or icon buttons.

## Impact

- Code: `packages/scalapay_ui/lib/src/widgets/scalapay_button.dart` (variant enum and parameter); removed `scalapay_text_button.dart` and its export.
- Tests: `test/atoms_test.dart`, `test/goldens/button_golden_test.dart`, golden images (`button_*`, `button_tertiary_*`; `text_button_*` deleted; primary images regenerated at 44px).
- Widgetbook: `widgetbook/lib/atoms/buttons_wb.dart` and the coverage test.
- Source: Figma node `0:4204` (Bottom-controls: Tertiary and Primary, both 44px high).
