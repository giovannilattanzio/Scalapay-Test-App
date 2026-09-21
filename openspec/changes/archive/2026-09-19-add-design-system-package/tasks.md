# Tasks

Layer prefix for this change is `[design-system]` (package work) and `[tooling]` (workspace, agents, docs). It replaces the domain/data/presentation/infrastructure prefixes, which do not apply to a UI package.

## 1. Workspace and package scaffold

- [x] 1.1 [tooling] Add `workspace:` to the root `pubspec.yaml`, create `packages/scalapay_ui` (`resolution: workspace`, `flutter_svg`, `flutter_test`) and add it as a dependency of the app; run `flutter pub get`. (design-tokens-theme)
- [x] 1.2 [tooling] Create `packages/scalapay_ui/widgetbook` as a Flutter app (`resolution: workspace`, `widgetbook`, `widgetbook_annotation`, `widgetbook_generator`, `build_runner`); verify `flutter pub get` resolves. (design-widgetbook)

## 2. Foundations and theme

- [x] 2.1 [design-system] Add Poppins SemiBold/Medium files under `assets/fonts/` and declare them in the package `pubspec.yaml`. (Typography uses Poppins from bundled assets)
- [x] 2.2 [design-system] Implement `ScalapayColors`, `ScalapayTypography`, `ScalapaySpacing`, `ScalapayRadius` with the values from the Figma variables and semantic names. (Foundations are defined as named tokens)
- [x] 2.3 [design-system] Implement `ScalapayTokens` (`ThemeExtension`), `ScalapayTheme.light()` and `BuildContext.tokens` with an assert when missing. (Theme exposes tokens through the app theme)
- [x] 2.4 [design-system] Unit-test token values and `context.tokens`, including the missing-theme case. (design-tokens-theme scenarios)

## 3. Atoms

- [x] 3.1 [design-system] Export the four SVG icons from Figma and implement `ScalapayIcon` / `ScalapayIconData`; add `ScalapayDivider`. (Divider and icons)
- [x] 3.2 [design-system] Implement `ScalapayButton` and `ScalapayTextButton` with enabled/disabled states. (Buttons)
- [x] 3.3 [design-system] Implement `ScalapayFilterChip` and `ScalapayRadio<T>`. (Filter chip, Radio)
- [x] 3.4 [design-system] Implement `ScalapayTextField` (floating label, error state) and `ScalapaySearchField`. (Text field, Search field)
- [x] 3.5 [design-system] Widget-test each atom for its scenarios and that no atom hardcodes visual values. (design-atoms scenarios)
- [x] 3.6 [design-system] Export everything through `scalapay_ui.dart`; run `flutter analyze` on the package.

## 4. Widgetbook

- [x] 4.1 [design-system] Set up `main.dart` with the design system theme and generated directories. (Widgetbook runs standalone)
- [x] 4.2 [design-system] Add foundation entries: colors (name + hex), text scale, spacing, radius. (Foundations are browsable)
- [x] 4.3 [design-system] Add use cases for every atom and each of its states; run `build_runner` and launch Widgetbook. (Every atom has use cases)

## 5. Agents and docs

- [x] 5.1 [tooling] Create `.claude/agents/flutter-design-system.md` (owns `packages/scalapay_ui/**`, atoms, Widgetbook stories, tokens-only rule).
- [x] 5.2 [tooling] Update `flutter-presentation.md` and the orchestrator to build from `scalapay_ui` widgets/tokens and to delegate missing atoms to `flutter-design-system`.
- [x] 5.3 [tooling] Update `CLAUDE.md` and `openspec/config.yaml` (context and the `tasks` layer-prefix rule) with the package, workspace and commands.
