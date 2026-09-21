# Design

## Context

The app is a single Flutter package (`lib/src/<layer>/<feature>`) with no shared UI code. Tokens come from the Figma file `bYMpO9qdni8sgc7L3LC4nX`; the variable list was read from one screen only, so the token set is a floor, not the full system. Reference implementation: `nova_ui` + `nova_widgetbook` in `nova_corporate_app` (foundations folder, per-component widgets, Widgetbook as a separate app). See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- One package (`scalapay_ui`) exposing tokens, theme and atoms through a single barrel.
- Atoms depend only on tokens; the app and Widgetbook wire the same theme.
- Every atom has Widgetbook use cases.

**Non-Goals:**
- Molecules/organisms, dark mode, multi-brand themes, publishing.
- Changing the app's `lib/src` layers; the package sits beside them.

## Decisions

**1. Layout: Dart workspace with `packages/scalapay_ui` and `packages/scalapay_ui/widgetbook`.**
The root `pubspec.yaml` declares `workspace:` with both members; each member sets `resolution: workspace`; the app depends on `scalapay_ui` by path. Alternative: plain path dependencies. Workspace gives one resolution and one `pub get`, matching the reference project; Dart 3.13 supports it.

**2. Tokens via `ThemeExtension`.**
A `ScalapayTokens extends ThemeExtension<ScalapayTokens>` holds `colors`, `typography`, `spacing`, `radius`; `ScalapayTheme.light()` returns a `ThemeData` with the extension and Material component themes aligned to it; `context.tokens` (extension on `BuildContext`) reads it and asserts if missing. Alternative: custom `InheritedWidget` theme as in the reference; rejected because `ThemeExtension` composes with Material widgets, supports `lerp`, and needs no extra provider. Semantic names (`surface`, `border`, `textPrimary`, `textSecondary`, `primary`, `onPrimary`) replace numeric grayscale names.

**3. Poppins as bundled asset.**
Font files under `packages/scalapay_ui/assets/fonts/`, declared in the package `pubspec.yaml`, referenced with `package:` font family so consumers get it automatically. Alternative: `google_fonts`; rejected (network at first use, not deterministic in Widgetbook/tests).

**4. Icons as SVG.**
Exported from Figma (filter, order, search, close), rendered with `flutter_svg` through a single `ScalapayIcon` widget taking `size` and `color`. Alternative: icon font; rejected because the Figma source is SVG and only four icons are needed.

**5. Widgetbook inside the package.**
`widgetbook` + `widgetbook_annotation` + `widgetbook_generator`; one `*_wb.dart` per atom with `@UseCase`, plus entries for foundations. Alternative: a stories folder inside the app; rejected to keep the package self-contained.

**6. New `flutter-design-system` agent.**
Owns `packages/scalapay_ui/**` and Widgetbook stories. `flutter-presentation` must build screens from `scalapay_ui` widgets and tokens and never hardcode colors or text styles; the orchestrator gains a design-system step when a feature needs a missing atom.

### Contracts (public API of `scalapay_ui`)

Barrel `package:scalapay_ui/scalapay_ui.dart` exports:
- `ScalapayTheme.light() -> ThemeData`; `ScalapayTokens` (`colors`, `typography`, `spacing`, `radius`); `BuildContext.tokens`.
- `ScalapayColors`: `primary`, `onPrimary`, `background`, `surface`, `border`, `textPrimary`, `textSecondary`, `textDisabled`, `overlay`, `error`.
- `ScalapayTypography`: `h2`, `p1`, `p3`, `p3Medium`, `p4`, `p5`, `button`.
- `ScalapaySpacing`: `xs = 8`, `s = 16`. `ScalapayRadius`: `child = 10`.
- `ScalapayButton({required String label, VoidCallback? onPressed})`, `ScalapayTextButton({required String label, VoidCallback? onPressed})`.
- `ScalapayFilterChip({required String label, required ScalapayIconData icon, VoidCallback? onPressed})`.
- `ScalapaySearchField({ValueChanged<String>? onSubmitted, TextEditingController? controller, String? hint})`.
- `ScalapayTextField({required String label, TextEditingController? controller, String? errorText, TextInputType? keyboardType})`.
- `ScalapayRadio<T>({required T value, required T? groupValue, required String label, required ValueChanged<T> onChanged})`.
- `ScalapayDivider()`; `ScalapayIcon(ScalapayIconData icon, {double size = 24, Color? color})` with `ScalapayIconData { filter, order, search, close }`.

Values of `error` and `textDisabled` are not in the read Figma variables and are placeholders until confirmed.

## Risks / Trade-offs

- [Figma variables read from one screen only] -> Re-read variables on other frames before finalizing tokens; keep tokens in one file.
- [Placeholder tokens (`error`, `textDisabled`, disabled/pressed states) not in Figma] -> Mark them in code and in the Widgetbook, confirm with design.
- [`widgetbook_generator` / `analyzer` version conflicts with the pinned `copy_with_extension_gen`] -> Pin compatible versions with `flutter pub add`; if unresolved, write the Widgetbook directories file by hand.
- [Workspace changes how `pub get` and `build_runner` run] -> Run codegen per package; document commands in CLAUDE.md.

## Migration Plan

Additive only; the app has no screens using the package yet. Rollback is removing the workspace entry and the dependency.

## Open Questions

- Do the Figma states for disabled, pressed, focus and error exist in another file or page?
