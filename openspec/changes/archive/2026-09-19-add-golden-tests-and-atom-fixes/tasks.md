# Tasks

Retroactive: the implementation existed before this change was written, so all tasks are complete. Prefixes: `[design-system]` (packages/scalapay_ui) and `[tooling]`.

## 1. Atom fixes

- [x] 1.1 [design-system] Add `heightFactor: 1` to the `Center` in `ScalapayButton` and `ScalapayTextButton`. (Buttons: height does not depend on available space)
- [x] 1.2 [design-system] Add `ScalapayIcons` (paths, `package`, `all`), use it from `ScalapayIconData` and `ScalapayIcon`, export it from the barrel, and test that constants match files and the enum. (Icon assets are exposed as constants)

## 2. Golden tests

- [x] 2.1 [design-system] Create the golden helper (`loadPoppins`, `expectGolden`) with loose constraints and intrinsic sizing. (Golden tests cover every component state)
- [x] 2.2 [design-system] Add golden tests and images for button, text button, filter chip, search field, text field, radio, icon and divider (16 images), and check the images against the design. (Every atom has goldens; Goldens use the design font)

## 3. Widgetbook

- [x] 3.1 [design-system] Apply the theme with `MaterialThemeAddon` instead of `lightTheme`/`themeMode`. (Previews receive the theme)
- [x] 3.2 [design-system] Add `initialRoute` to `WidgetbookApp` and a smoke test that opens every use case. (Use cases open without errors)

## 4. Agent

- [x] 4.1 [tooling] Add the golden test step and rules to `.claude/agents/flutter-design-system.md`.
