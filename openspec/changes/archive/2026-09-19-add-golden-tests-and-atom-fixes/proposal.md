# Proposal

## Why

The design system package (archived change `add-design-system-package`) shipped without visual regression tests, and three problems surfaced afterwards: buttons stretched to the full available height, Widgetbook previews failed because the theme was not applied to the use cases, and icon asset paths were repeated as strings. This change records that work, already implemented, so specs match the code.

## What Changes

- Golden tests for every atom, one image per visual state, rendered in Poppins.
- Icon asset paths exposed as constants (`ScalapayIcons`).
- Buttons keep their own height (48) regardless of the space available.
- Widgetbook applies the design system theme to previewed widgets, and a test opens every use case.
- The `flutter-design-system` agent gets a golden test step (tooling, no spec).

## Capabilities

### New Capabilities
<!-- None. -->

### Modified Capabilities
- `design-atoms`: adds golden coverage and icon asset constants; buttons gain an intrinsic-height requirement.
- `design-widgetbook`: use cases render with the design system theme, and every use case opens without errors.

### Non-goals
- Golden tests for molecules or screens (none exist yet).
- Cross-platform golden tolerance or CI setup.
- New atoms or token changes.

## Impact

- Code: `packages/scalapay_ui/lib/src/widgets/scalapay_button.dart`, `scalapay_text_button.dart`, `lib/src/assets/scalapay_icons.dart`, `scalapay_icon.dart`; `packages/scalapay_ui/widgetbook/lib/main.dart` and use cases.
- Tests: `packages/scalapay_ui/test/goldens/**` (16 images), `widgetbook/test/widgetbook_smoke_test.dart`.
- Tooling: `.claude/agents/flutter-design-system.md`.
- Goldens are generated on macOS; other platforms may differ by a few pixels.
