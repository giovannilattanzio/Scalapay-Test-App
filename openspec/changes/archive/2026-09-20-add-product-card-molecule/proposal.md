# Proposal

## Why

Screens will be built from the design system, but the catalog screen needs two pieces above the atoms: a product card and a search bar. The search bar already exists in the package; the product card does not, and the agent and orchestrator rules currently forbid building molecules in the package.

## What Changes

- New molecule: product card (image area, name, store, price and, optionally, installments). The image and all values come from the caller, and the card formats the money.
- Price and installment amount are numbers (`double`); an optional currency symbol from the caller applies to both. Amounts are formatted with the locale of the surrounding app (via `intl`).
- Installments are three optional values: the number, the amount of one installment and the wording between them (external string). The number and the amount come together, and the wording is required when both are given.
- An optional external string connects the price to the installments (the "or" of the design) and is shown only when installments are shown.
- Search bar (Figma node `0:4053`): no new widget. It is the existing search field, reused unchanged.
- Two new tokens: image radius 20 and a text color for the store name (`#3A4045`).
- `flutter-design-system` agent, orchestrator, CLAUDE.md and config allow molecules in the package, under `lib/src/molecules/`.

## Capabilities

### New Capabilities
- `design-molecules`: composite widgets built from atoms and tokens, starting with the product card.

### Modified Capabilities
- `design-tokens-theme`: the foundations requirement gains the image radius and the store name color.

### Non-goals
- A second search widget or any new parameter on the search field.
- Tap handling, favorites or badges on the card.
- Network image loading, caching or asset bundling.
- Currency conversion or rounding rules beyond two decimals.
- Other molecules (bottom sheets, header).

## Impact

- New: `packages/scalapay_ui/lib/src/molecules/scalapay_product_card.dart`, its tests, one golden set, Widgetbook use cases (`widgetbook/lib/molecules/`); new dependency `intl` in `scalapay_ui`.
- Changed: `foundations/radius.dart`, `foundations/colors.dart`, barrel, `.claude/agents/flutter-design-system.md`, `.claude/skills/flutter-orchestrator/SKILL.md`, `CLAUDE.md`, `openspec/config.yaml` context.
- Source: Figma nodes `0:3926` (card, 164x349) and `0:4053` (search bar, 343x55). Figma calls were rate limited, so text styles come from the earlier read of the screen; the paddings, the radius, the store color and the parameter shapes were confirmed by the user.
