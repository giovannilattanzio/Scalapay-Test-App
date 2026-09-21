# Change history

One entry per archived change (`/opsx:archive`), oldest first: `- YYYY-MM-DD | <change-name> | <summary, max 2 lines>`

- 2026-09-19 | add-design-system-package | Created workspace package scalapay_ui (Poppins, ThemeExtension tokens, 8 atoms from Figma) with a Widgetbook app.
  Added flutter-design-system agent, updated presentation agent, orchestrator, CLAUDE.md and config; 18/18 tasks, analyze and tests green.
- 2026-09-19 | add-golden-tests-and-atom-fixes | Added golden tests for all atoms, ScalapayIcons path constants and a Widgetbook smoke test; fixed buttons stretching to full height and the missing Widgetbook theme.
  Synced design-atoms (9 requirements) and design-widgetbook (4 requirements).
- 2026-09-19 | add-button-variants | ScalapayButton now has primary and tertiary variants (enum, default primary) at 44px as in Figma; ScalapayTextButton removed (breaking, unused).
  Added tertiary goldens, tests and Widgetbook use cases; synced design-atoms Buttons.
- 2026-09-20 | add-product-card-molecule | Added the ScalapayProductCard molecule (image widget, price and installments formatted with intl and the app locale), the image radius and store name color tokens, goldens and Widgetbook use cases; molecules are now allowed in the design system agent.
  Search bar reused unchanged (comparison with Figma left open); synced design-molecules (new) and design-tokens-theme.
- 2026-09-20 | add-bottom-sheet-organisms | Added the ScalapayFiltersBottomSheet and ScalapaySortBottomSheet organisms, each with a show modal helper (onClose on dismissal, sort closes after 300 ms), and the card and sheet radius tokens.
  Price fields accept only numbers (ScalapayTextField gains inputFormatters); synced design-organisms (new), design-tokens-theme and design-atoms.
- 2026-09-20 | add-catalog-api-client | Reverse-engineered the catalog service into openapi/catalog-api.yaml and generated packages/catalog_api from it (dart-dio + json_serializable), committed and wired into the workspace, with a fixture test guarding the document against drift.
  Generation is an explicit command, not a build_runner builder, whose analyzer range is disjoint from json_serializable's; add-product-catalog-page was revised to consume the client and take over the app wiring.
- 2026-09-21 | add-product-catalog-page | Built the Figma catalog screen (title, search, fixed Filtri/Ordina chips, two-column grid with infinite scroll, five states) on the generated client, with Italian and English via easy_localization and 121 app tests.
  Diverges from the mockup where it had to: sort offers relevance plus the two price orderings (the service cannot order by name, and without relevance the default was unreachable); synced app-localization, product-catalog, product-search-api (new), design-organisms and design-tokens-theme.
- 2026-09-21 | align-design-system-with-figma | Aligned scalapay_ui with Figma read through the REST API: new tokens (primaryMuted, textInput, p2Medium); button, per-icon chip, 56px text field with its floated label at 11px, radio, sheet handle, filters card (126) and sort rows (64) now match the measured nodes.
  16 goldens regenerated, search field confirmed unchanged; synced design-tokens-theme, design-atoms and design-organisms.
