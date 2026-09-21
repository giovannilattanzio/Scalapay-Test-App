# Design

## Context

Only `packages/scalapay_ui` changes. The values below were read on 2026-09-21 through the Figma REST API from file `bYMpO9qdni8sgc7L3LC4nX` (last modified 2026-09-19). The MCP server stops after one call on the Starter plan. Nodes read:
- catalog frame `0:3908`: search bar `0:4053`, chips `0:3916`/`0:3920`, cards `0:3926`/`0:3938`
- filters sheet `0:4202`: header, price card `107:14869`, hidden footer `107:23218`
- sort sheet `0:4352`: rows `0:4355`..`0:4358`
- style values resolved from the nodes that use them

The Figma variables endpoint requires an Enterprise plan, so the tokens come from styles and node properties. See proposal.md for motivation.

Measured differences (Figma → code today):

| Where | Figma | Code |
|---|---|---|
| Button, horizontal padding | 16 (both variants) | 24 primary, 8 tertiary |
| Chip with the filter icon | pad 8/10, icon 20, gap 2 (64 wide with "Filtri") | pad 8/8, icon 20, gap 2 |
| Chip with the order icon | pad 4/8, icon 24, gap 0 (75 wide with "Ordina") | pad 8/8, icon 20, gap 2 |
| Text field | 56 tall, value color `#3A4045` | ~52 tall, `#272727` |
| Text field, floated label | P5, 11 on screen | 11 × 0.75 ≈ 8.25 on screen (found while reviewing the goldens) |
| Radio | glyph box 24, gap 10, label P2/500 14/22.4, off ring `#CACCF2` | 20, 12, P3/500 13/19.5, primary @ 25% |
| Sheet handle | `#9E9E9E` @ 40% | @ 50% |
| Filters card | pad top 14, title row 24, dash 9.8 | 16, 19.5, 11 |
| Filters footer gap | 6 | 8 |
| Sort card | side pad 15, rows 64 with the divider inside (256 total) | 16, 64 + 1px dividers (259) |

Matches already (no change): search field (55 tall, 16 + 1 border on the left, 45 button, 24 icon), card text block (8/12 paddings, 4 and 8 gaps, P3/600, P4/500, Buttons/Medium for installments), sheet header (91, handle 45x5 at 7, title 296 at 26, close 58x65 with a 32 icon), radii, colors and the remaining text styles.

## Goals / Non-Goals

**Goals:**
- Every measured difference in the table is closed, and each is guarded by a test or a golden.
- Public constructors keep their parameters: no call site in the app changes.

**Non-Goals:**
- A Figma sync script, or storing the REST dump in the repo.
- The faint `#F6F7FB` top stroke of the last sort row in Figma: it sits on the previous row's divider and is a component artifact.

## Decisions

### Tokens
- `ScalapayColors.primaryMuted = #CACCF2` (UI/Buttons/Lightweight/Lillac/Hover). Rejected: primary at an opacity. No opacity of `#5666F0` on white gives `#CACCF2`; 25% gives about `#D5D9FB`.
- `ScalapayColors.textInput = #3A4045` (Grayscale/850). Rejected: reusing `textStoreName`. Same value, different role, which is the rule the radii already follow.
- `ScalapayTypography.p2Medium`: Poppins 500, 14, height 22.4/14 (1.6).

Each is added to `lerp` and `entries`. `entries` feeds the Widgetbook token pages, so those pages need no code change.

### Button
Horizontal padding is `t.spacing.s` for both variants, which removes the per-variant padding from the switch. The 44 minimum height and the 48 minimum width stay.

### Filter chip layout per icon
A private `switch` on `ScalapayIconData` inside `ScalapayFilterChip` returns a record `(left, iconSize, gap, right)`:
- `order` → `(4, 24, 0, 8)`
- every other icon → `(8, 20, 2, 10)`

Figma draws the order glyph on a 24px grid and the filter glyph on a 20px one, which explains why the two differ. Rejected alternatives:
- Parameters on the chip: callers would hardcode pixels, against the "no hardcoded values in features" rule.
- Metrics on the `ScalapayIconData` enum: this mixes chip layout into the icon.

The values are named constants in the chip, like the other measured constants in the package: 2, 4 and 10 have no token, 8 is `xs`.

### Text field height
The vertical `contentPadding` is set so the outlined field is 56 tall with a P3/500 value: `(56 - 19.5) / 2 = 18.25`. The label floats onto the border, so it adds no height to an outlined field. A widget test asserts 56 (empty and filled). If the decorator adds height, the padding is tuned until the test passes. Rejected: a fixed `SizedBox(height: 56)`, which would clip the error message. The value style becomes `p3Medium` in `textInput`, and the hint and label styles do not change. The implemented padding is 18: with 18.25 the decorator measured 56.5.

### Floated label size
Flutter's `InputDecorator` always scales the floated label by `_kFinalLabelScale = 0.75`, so `floatingLabelStyle: p5` shows at about 8.25. The fix is to set `floatingLabelStyle` to `p5` with `fontSize: p5.fontSize! / 0.75`, and the same for the error variant. The 0.75 is a private framework constant, so it gets a named constant with a comment pointing to `input_decorator.dart`. The line height stays proportional because `height` is a multiplier. Rejected alternative: a custom label widget outside the decorator, which would lose the notch that Material cuts in the outline for the label. A widget test pins the result: it reads the label's rendered size (its `RenderParagraph` size combined with the transform) and expects about 11, so it fails if the framework ever changes the scale.

### Radio
The ring stays at 20 with a 2px border and a 10px dot, now centered in a `SizedBox(24)`. The gap before the label is 10 and the label uses `p2Medium`. The ring uses `primary` when selected and `primaryMuted` when not. The 48 minimum tap height stays.

### Sort sheet rows
Each option is a `SizedBox(height: 64)` holding a `Column`: an `Expanded` with the radio centered vertically, then a `ScalapayDivider` for every row except the last. The divider now sits inside the row instead of between rows, and the component is reused as the organisms spec requires. The vertical `xs` padding around the radio goes away and the card's horizontal padding becomes 15. The value 15 has no token, so it is a named constant next to the others in the sheet.

### Filters card and footer
- Card padding: `fromLTRB(s, 14, s, s)`.
- The price title sits in a 24-tall box, aligned center-left.
- Dash width: 10, down from 11 (Figma is 9.8, rounded).
- Footer: the gap between the buttons becomes 6. The 4px gap above the footer and the 16 footer padding stay.

The new values are named constants, like `_dashWidth` today.

### Frame handle
The alpha changes from 0.5 to 0.4 in `BottomSheetFrame`.

## Risks / Trade-offs

- [Material's `InputDecorator` may add internal height, so 18.25 might not give exactly 56] → The size test drives the padding value. The field is not given a fixed height.
- [The chip layout depends on which icon is passed] → Covered by a test per icon. Unknown icons get the filter layout, which is the Figma default component.
- [Every golden that shows a button, chip, radio, field or sheet changes] → Regenerate them with `flutter test --update-goldens` in `packages/scalapay_ui` and review the diff images before committing. The app has no goldens.
- [Buttons in the catalog (retry, empty state) become 16px narrower] → Intended, it matches Figma. The app tests do not assert button widths.

## Migration Plan

None. There is no API change, and rollback is a revert of the package commit.
