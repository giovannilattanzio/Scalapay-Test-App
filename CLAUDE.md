# scalapay_test_app

Single-package Flutter app following Clean Architecture, layer-first: `lib/src/<layer>/<feature>/`.

```
lib/src/
  core/          Result, Failure, UseCase, DI (`injector`)
  config/router/ go_router router
  domain/        entities, repository interfaces, use cases
  data/          models, data sources, repository implementations
  presentation/  cubit + state, pages, widgets
packages/scalapay_ui/  design system: tokens, theme, atoms (src/widgets), molecules (src/molecules), organisms (src/organisms); Widgetbook in widgetbook/
```

Presentation never imports data. Errors use `Result<T>`, never Either/dartz. Use case classes always carry the `UseCase` suffix and live in files ending `_use_case.dart` (`SearchProductsUseCase` in `search_products_use_case.dart`).

UI is built from `scalapay_ui` (`package:scalapay_ui/scalapay_ui.dart`): atoms, molecules and organisms plus `context.tokens` for colors, text styles, spacing, radius. Never hardcode those in features. Reuse an existing component before adding one (the search bar is `ScalapaySearchField`). Molecules take their content from the caller; those showing money (`ScalapayProductCard`) format it with `intl` using the surrounding app's locale, so the app must configure its locale. The bottom sheet organisms (`ScalapayFiltersBottomSheet`, `ScalapaySortBottomSheet<T>`) are content-only widgets with a static `show` that opens them as a modal and reports dismissals (close button, backdrop, drag) through `onClose`. The repo is a Dart workspace (root, `packages/scalapay_ui`, `packages/scalapay_ui/widgetbook`): one `flutter pub get` at the root.

## Workflow

1. `/opsx:explore` to think, `/opsx:propose "<idea>"` to create a change (proposal, specs, design, tasks)
2. `/opsx:apply` implements it: it delegates to the `flutter-orchestrator` skill, which delegates in order to the subagents `flutter-domain`, `flutter-data`, `flutter-presentation`, `flutter-infrastructure` and, for the design system package, `flutter-design-system` (`.claude/agents/`)
3. `/opsx:archive` when done

For code tasks outside OpenSpec, use the `flutter-orchestrator` skill directly. Never implement layer code without the matching agent.

## Commands

- Codegen: `dart run build_runner build --delete-conflicting-outputs`
- Format / analyze / test: `dart format lib test`, `flutter analyze`, `flutter test` (run in the app and in `packages/scalapay_ui`)
- Widgetbook: in `packages/scalapay_ui/widgetbook`, `dart run build_runner build --delete-conflicting-outputs` then `flutter run -d chrome` (or `-d macos`)
