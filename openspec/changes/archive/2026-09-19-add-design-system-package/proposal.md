# Proposal

## Why

The app has no shared visual foundation: colors, typography and spacing would otherwise be redefined in every feature. The Figma file ("Test - App Scalapay") already defines a consistent visual language (Poppins, lilac primary, grayscale, 8/16 gaps). A dedicated design system package gives features one tokenized source of truth and lets components be reviewed in isolation before any screen uses them.

## What Changes

- New package `packages/scalapay_ui` in a Dart workspace with the app.
- Foundations and theme: colors, typography (Poppins bundled as asset), spacing, radius, exposed through a `ThemeExtension` on `ThemeData`, with semantic names.
- Atomic widgets built on those tokens: button (filled), text button, filter chip, search field, text field with floating label, radio, divider, icon set.
- New Widgetbook project inside the package (`packages/scalapay_ui/widgetbook`) with use cases for every atom.
- New subagent `flutter-design-system` (atoms and Widgetbook stories); `flutter-presentation` and the orchestrator consume the package instead of the raw `Theme`.

## Capabilities

### New Capabilities
- `design-tokens-theme`: foundations (colors, typography, spacing, radius) and the app theme derived from the Figma variables.
- `design-atoms`: atomic widgets driven only by the tokens.
- `design-widgetbook`: Widgetbook project that previews every atom and its states.

### Modified Capabilities
<!-- None: no existing specs. -->

### Non-goals
- Molecules and organisms (product card, bottom sheets, header, navigation).
- Dark mode and multi-brand theming.
- Screens or features consuming the package.
- Publishing the package or a Figma-to-code sync pipeline.

## Impact

- New: `packages/scalapay_ui/` (lib, assets, widgetbook), root `pubspec.yaml` workspace entry and dependency on `scalapay_ui`.
- New dependencies: `flutter_svg`, `widgetbook`, `widgetbook_annotation`, `widgetbook_generator`.
- Docs/agents: `.claude/agents/flutter-design-system.md`, `.claude/agents/flutter-presentation.md`, orchestrator skill, `CLAUDE.md`, `openspec/config.yaml` context.
- Token source: Figma file `bYMpO9qdni8sgc7L3LC4nX` (duplicate of the original, read-only); variable list is partial because it was read from one screen.
