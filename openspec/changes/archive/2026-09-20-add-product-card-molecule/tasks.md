# Tasks

Prefixes: `[design-system]` (packages/scalapay_ui and its Widgetbook) and `[tooling]` (agents, docs, config).

## 1. Foundations and dependency

- [x] 1.1 [design-system] Add `image = 20` to `ScalapayRadius` (including `entries`) and `textStoreName = #3A4045` to `ScalapayColors` (including `lerp` and `entries`), and test both values. (Image radius token; Store name color token)
- [x] 1.2 [design-system] Add `intl` to `packages/scalapay_ui/pubspec.yaml` and resolve the workspace with `flutter pub get`. (Product card: money formatting)

## 2. Product card

- [x] 2.1 [design-system] Implement `ScalapayProductCard` in `lib/src/molecules/` with the contract in design.md (image widget, name, store, `double` price, optional currency, price connector and the three installment values with their assertions), formatting money with `intl` and the surrounding locale, using only tokens, clipping the image to the area, and export it through `molecules/molecules.dart` and the barrel. (Product card; Molecules reuse atoms and foundations)
- [x] 2.2 [design-system] Add widget tests: shows the given texts and image; money formatting under an Italian and an English locale; currency on price and installment; no currency; installments line order (count, wording, amount); no line, connector and gap without installments; a lone installment value and a missing wording fail the assertions; connector shown only with installments; long name cut at two lines; installments wrap; image area proportion at different widths; fills its column in a two-column row. (Product card scenarios)
- [x] 2.3 [design-system] Extend the "no hardcoded colors" test to `lib/src/molecules/`. (Molecules reuse atoms and foundations)
- [x] 2.4 [design-system] Add golden tests: default card (with installments and connector), long-texts card and card without installments, in a fixed locale and with a placeholder widget as image (no network), and check the images against the design.
- [x] 2.5 [design-system] Add Widgetbook use cases (default with knobs, long texts, no installments, two-column grid, Italian locale) under `widgetbook/lib/molecules/`, regenerate with `build_runner`, and add `ScalapayProductCard` to the coverage test.

## 3. Search bar

- [ ] 3.1 [design-system] Compare `ScalapaySearchField` with Figma node `0:4053` (55px height, 45px button, 17px left padding, hint from the caller) when Figma access is available; change nothing unless it differs, and list any difference as a follow-up. (Search bar is not duplicated)

## 4. Agents and docs

- [x] 4.1 [tooling] Update `.claude/agents/flutter-design-system.md`: molecules are allowed in `lib/src/molecules/` (Widgetbook in `widgetbook/lib/molecules/`), built only from atoms and tokens, with values injected by the caller; reuse existing components, tokens and parameters before adding new ones.
- [x] 4.2 [tooling] Update the Design System Check in `.claude/skills/flutter-orchestrator/SKILL.md`: reusable, content-agnostic molecules go to `flutter-design-system`; screen sections tied to one feature stay in presentation.
- [x] 4.3 [tooling] Update `CLAUDE.md` and the `context` in `openspec/config.yaml` to mention molecules, their location and the `intl` dependency.
