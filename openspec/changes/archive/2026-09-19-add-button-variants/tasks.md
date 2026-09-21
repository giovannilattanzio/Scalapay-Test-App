# Tasks

Retroactive: the implementation existed before this change was written, so all tasks are complete. Prefix: `[design-system]`.

## 1. Button variants

- [x] 1.1 [design-system] Add `ScalapayButtonVariant` and the `variant` parameter (default primary) to `ScalapayButton`, with per-variant fill, label color and padding, and a transparent Material for tertiary. (Buttons: default variant, tertiary has no fill)
- [x] 1.2 [design-system] Set the minimum height to 44 for both variants. (Buttons: height does not depend on available space)
- [x] 1.3 [design-system] Remove `ScalapayTextButton`, its export and its tests. (Buttons: a variant is not a separate component)

## 2. Tests and previews

- [x] 2.1 [design-system] Add behavior tests for tertiary (tap, no fill and primary label, disabled label) and a height test for both variants. (Buttons scenarios)
- [x] 2.2 [design-system] Add tertiary golden tests, regenerate the primary goldens at 44px, delete the `text_button_*` images, and check them against the design.
- [x] 2.3 [design-system] Replace the text button Widgetbook use cases with primary and tertiary use cases (enabled, disabled) and a bottom-controls pair, regenerate the Widgetbook, and update its coverage test.
