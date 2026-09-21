# Proposal

## Why

The catalog screen opens two bottom sheets: one to filter by price and one to sort (Figma nodes `0:4201` and `0:4352`). They share a frame (handle, centered title, close button) and are built from existing components plus that frame. As design system organisms they keep the feature free of layout and styling.

## What Changes

- New organism: filters bottom sheet (title, white card with a price title and the minimum and maximum fields, footer with a tertiary "clear" and a primary "apply" button).
- New organism: sort bottom sheet (title, white card with one radio option per choice, separated by dividers).
- Both are separate public widgets. Each has a static `show` helper that opens it as a modal bottom sheet.
- All texts come from the caller. Values go through the two text controllers (filters) and the options map and selected value (sort).
- After testing: the price fields accept only numbers (text field gains `inputFormatters`), and the sort modal closes after a short delay so the chosen option is seen.
- Two new radius tokens, both 20 and confirmed: card (the two white cards) and sheet (the top corners of the sheet surface). Same value, separate tokens by role.
- The shared frame is internal. Agent, orchestrator, CLAUDE.md and config allow organisms in `lib/src/organisms/`.

## Capabilities

### New Capabilities
- `design-organisms`: bottom sheet organisms and their opening helper.

### Modified Capabilities
- `design-tokens-theme`: the foundations requirement gains the card and sheet radii.
- `design-atoms`: the text field can restrict its input.

### Non-goals
- A public generic bottom sheet widget.
- The "more than 5 filters" variant and any filter other than price.
- Validating price ranges (for example minimum greater than maximum).
- A footer or confirm button on the sort sheet.
- Custom drag, snap or barrier behavior beyond the modal defaults.

## Impact

- New: `packages/scalapay_ui/lib/src/organisms/` (two sheets and an internal frame), tests, goldens, Widgetbook use cases (`widgetbook/lib/organisms/`).
- Changed: `foundations/radius.dart`, `ScalapayTextField` (`inputFormatters`), barrel, the hardcoded-colors test, the design system agent, the orchestrator skill, `CLAUDE.md`, config context.
- Reused: `ScalapayButton`, `ScalapayRadio`, `ScalapayDivider`, `ScalapayIcon`, existing tokens.
- Source: Figma nodes `0:4201` (filters) and `0:4352` (sort). Figma calls were rate limited: measures come from the earlier screen read and its screenshot. Scope, separate widgets, the `show` helper and the radius of 20 were confirmed by the user.
