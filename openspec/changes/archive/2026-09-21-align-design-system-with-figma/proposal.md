# Proposal

## Why

Most of `scalapay_ui` was measured from screenshots while the Figma MCP server was rate limited. A full read of the file through the REST API (`bYMpO9qdni8sgc7L3LC4nX`: the catalog, filters and sort frames, 32 component instances, 32 styles) shows small but visible differences in five components. Fixing them now gives the most faithful match, before more screens reuse the components.

## What Changes

- **Tokens**: add the `p2Medium` text style (Mobile/P2/500, 14/22.4), the `primaryMuted` color (`#CACCF2`, UI/Buttons/Lightweight/Lillac/Hover) and the `textInput` color (`#3A4045`, Grayscale/850, the color of a field's value).
- **Button**: 16px horizontal padding in both variants (today 24 for primary, 8 for tertiary).
- **Filter chip**: layout per icon, as in Figma. Filter: 20px icon, 2px gap, padding 8/10. Order: 24px icon, no gap, padding 4/8. Today both use the filter layout.
- **Text field**: 56px tall (about 52 today), value text in `textInput`, floated label shown at 11px (Flutter scales it to 75%, about 8 today).
- **Radio**: 24px glyph box with a 10px gap before the label (20 and 12 today), unselected ring in `primaryMuted` (today primary at 25% opacity), label in `p2Medium` (13/19.5 today).
- **Bottom sheet frame**: handle at 40% opacity (50% today).
- **Filters sheet**: card top padding 14, title row 24, dash 10 (11 today), footer buttons 6 apart (8 today). The card becomes 126px, as in Figma.
- **Sort sheet**: 64px rows with the divider inside, card side padding 15. The card becomes 256px, as in Figma (259 today).

Already faithful: search field (node `0:4053`, closing the follow-up from `add-product-card-molecule`), card text block, sheet header, colors, radii, other text styles.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `design-tokens-theme`: new `p2Medium` style and `primaryMuted`, `textInput` colors.
- `design-atoms`: measurable geometry for the button, chip, text field and radio.
- `design-organisms`: frame handle opacity, filters card and footer metrics, sort row height.

### Non-goals
- Product card image padding: Figma images are placed by hand (7.5px and 0.5px insets), so there is no rule to copy. It stays at 8.
- App screens (catalog header, chip row) and hidden Figma variants (categories, checkboxes).
- Re-exporting the SVG icons.

## Impact

- `packages/scalapay_ui`: foundations, the four atoms, `BottomSheetFrame`, the filters and sort sheets, goldens (regenerated), Widgetbook token pages.
- App: buttons and chips in the catalog change size by a few pixels. No API change, no breaking change.
