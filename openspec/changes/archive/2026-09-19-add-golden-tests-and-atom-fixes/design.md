# Design

## Context

Retroactive design: the work was done before this change was written. It records the causes and choices so they are not rediscovered. Builds on `add-design-system-package` (archived).

## Goals / Non-Goals

**Goals:**
- Catch visual regressions of atoms with golden tests that reflect the real design font.
- Remove the causes of the three defects found after the first delivery.

**Non-Goals:**
- Multi-platform golden tolerance, CI wiring, tests for molecules.

## Decisions

**1. Golden harness in `test/goldens/golden_utils.dart`.**
`loadPoppins()` loads the bundled fonts with `FontLoader('packages/scalapay_ui/Poppins')`; `expectGolden()` renders on the background color under `ScalapayTheme.light()` at devicePixelRatio 2. The component sits in `Align(centerLeft, heightFactor: 1)` inside a fixed-width box so loose constraints show its intrinsic size. Alternative: a tight `SizedBox`, rejected because it stretched chips and buttons and misrepresented them.

**2. One golden per state, one file per component.**
Names `<component>_<state>.png` under `test/goldens/images/`; the set mirrors the Widgetbook use cases. Images are checked by eye when generated, never regenerated to silence a failure.

**3. Buttons: `Center(widthFactor: 1, heightFactor: 1)`.**
A `Center` without `heightFactor` takes all the height a parent offers, so buttons inside a bounded parent (Widgetbook, `Center` in a `Scaffold`) filled the screen. Only inside unbounded parents (`Column`, `ListView`) it hid. Applied to `ScalapayButton` and `ScalapayTextButton`.

**4. Icon path constants (`ScalapayIcons`).**
`abstract final class` with `filter`, `order`, `search`, `close`, `package` and `all`; `ScalapayIconData` and `ScalapayIcon` read them. Alternative: keep paths only in the enum; rejected because consumers outside `ScalapayIcon` (for example raw `SvgPicture.asset`) would repeat strings.

**5. Widgetbook theme through `MaterialThemeAddon`.**
In Widgetbook 3, `lightTheme`/`darkTheme` on `Widgetbook.material` style only Widgetbook's own UI. The previewed widgets get their theme from `MaterialThemeAddon` with `ScalapayTheme.light()`. A smoke test opens every use case via `initialRoute` (`/?path=<use case path>`), which failed on 21 of 22 use cases before the fix. Alternative considered: a helper to read tokens below the theme; removed because the use case context is already under the addon's theme.

### Contracts

- `ScalapayIcons.package -> 'scalapay_ui'`; `ScalapayIcons.filter | order | search | close -> String` (`assets/icons/<name>.svg`); `ScalapayIcons.all -> List<String>` in enum order.
- `WidgetbookApp({String initialRoute = '/'})`.
- Test helpers: `loadPoppins()`, `expectGolden(WidgetTester, Widget, String name, {double width = 343})`.

## Risks / Trade-offs

- [Goldens generated on macOS] -> Other platforms may differ by a few pixels; generate on the CI platform or add a tolerance when a CI exists.
- [Goldens depend on font metrics] -> Poppins is bundled, so metrics are stable across machines.

## Migration Plan

Additive; no API removed. `ScalapayIconData.asset` values are unchanged.
