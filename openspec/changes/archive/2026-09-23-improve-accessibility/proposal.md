# Proposal

## Why

An audit of `scalapay_ui` and the catalog screen found gaps for screen reader and large-text users: the sheet close button is an unlabeled button, the search action is labeled with a hardcoded English "Search", enabled buttons, chips and radios likely expose no tap action, the filter chip is 32px tall, a product card reads as disconnected fragments, and state changes are never announced. No test checks accessibility, and nothing makes new widgets follow these rules.

## What Changes

- Interactive atoms expose label, state and tap action when enabled.
- Localizable search action and close button labels, defaulting to `MaterialLocalizations`.
- Filter chip: same 32px pill, 44px tall tap target.
- Product card announced as one element; image decorative.
- Catalog screen announces its state messages, labels progress indicators, marks the title as a header.
- Text scaling up to 200% without overflow on the catalog screen and sheets.
- Token contrast measured by a test; pairs below WCAG AA (`textSecondary` 3.44:1 and 3.22:1, `error` 4.38:1) documented as known exceptions, Figma values unchanged.
- Guideline tests (`labeledTapTargetGuideline`, `iOSTapTargetGuideline`) on atoms, organisms, the catalog page and every Widgetbook use case.
- An accessibility checklist in the `flutter-design-system` and `flutter-presentation` agent definitions.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `design-atoms`: semantics of interactive atoms, localizable search action label, chip tap target.
- `design-molecules`: product card as a single element.
- `design-organisms`: labeled close button, announced price error.
- `design-tokens-theme`: measured contrast with documented exceptions.
- `design-widgetbook`: every use case meets the accessibility guidelines.
- `product-catalog`: announced state changes, labeled progress, header title, 200% text scale.

### Non-goals
- Changing token colors away from Figma (to be raised with design).
- Dark mode, reduced motion, keyboard/switch navigation on desktop and web.
- A formal WCAG certification or external audit.
- Accessibility tooling inside the Widgetbook UI.

## Impact

- `packages/scalapay_ui`: atoms, product card, sheets (`actionLabel`, `closeLabel`), contrast test; chip golden may shift.
- `packages/scalapay_ui/widgetbook`: guideline test over all use cases, new knobs.
- App: catalog widgets, key `catalog.loading` in `assets/translations/{it,en}.json`, widget tests.
- `.claude/agents/flutter-design-system.md`, `.claude/agents/flutter-presentation.md`: accessibility checklist.
- No domain, data or DI changes; no breaking API changes.
