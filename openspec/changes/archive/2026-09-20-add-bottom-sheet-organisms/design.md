# Design

## Context

Everything the two sheets need already exists in `scalapay_ui`: `ScalapayTextField` (label, controller, numeric keyboard), `ScalapayButton` with `primary` and `tertiary` variants (44px), `ScalapayRadio<T>`, `ScalapayDivider`, `ScalapayIcon` (close, 24 grid, rendered at 32), and the tokens `surface`, `background`, `overlay`, `textDisabled`, `p1`, `p3Medium`, spacing 8 and 16. Missing: a top-rounded frame and radius tokens for the cards and for the sheet (both 20, confirmed).

Read from Figma earlier (nodes `0:4201`, `0:4352`, and the sheet frame `0:4202`): a frame 375 wide, header 91px (handle 45x5 at 7px from the top; title block 296px wide, centered; close area 58x65 at the top right with a 32px icon), content padded 16 on the sides; filters card 343x126 with the price title and two fields about 26px apart around a short dash; footer 76px (two 44px buttons, 16px padding), 4px below the card, total 297px; sort card 343x256 with four rows about 64px and inset dividers, 16px below it, total 363px. Figma calls were rate limited, so these were measured from the screen and its screenshot.

Confirmed by the user: two separate public widgets, a `show` helper for each, the card radius of 20 as its own token, and a separate sheet radius token, also 20.

## Goals / Non-Goals

**Goals:**
- Two sheets that reproduce the Figma layouts by composing existing components, plus an opening helper.

**Non-Goals:**
- A public generic sheet, other filters, validation, custom modal behavior.

## Decisions

**1. Two public widgets over one internal frame.**
`ScalapayFiltersBottomSheet` and `ScalapaySortBottomSheet<T>` share `BottomSheetFrame` (surface with the sheet radius on the top corners, handle, centered title, close button, content, bottom padding), kept in `lib/src/organisms/internal/` and not exported. Alternative: a public `ScalapayBottomSheet`; rejected as more API than requested.

**2. Content-only widgets plus a static `show`.**
The widgets draw the sheet, so they are testable and previewable without a route. `show` opens them with `showModalBottomSheet` (scroll controlled, safe area, transparent modal background because the frame draws its own rounded surface, elevation 0, barrier `overlay` at half opacity). The sheet is wrapped in bottom padding equal to the keyboard inset and a `SingleChildScrollView`. Drag-to-dismiss and barrier taps are the modal defaults. On a phone in portrait (about 400 logical pixels) the sheet already spans the full width. Material 3 caps modal bottom sheets at 640 logical pixels and centers them, so on wider screens (tablets, desktop, web, a phone in landscape) side margins appear; this is accepted and the default cap is kept (`constraints: const BoxConstraints()` would remove it; it was tried and reverted at the user's request).

**3. Closing rules in `show`.**
Confirmed by the user: closing with the close button, a tap on the backdrop or a drag down calls `onClose`. Each of the three dismisses the modal, and `onClose` runs once, as soon as the route is popped, that is when the closing animation starts (measured: after one frame the callback has run and the sheet is still on screen). Assumptions: choosing a sort option pops the modal with the value, and filters apply calls `onApply` and pops, both without calling `onClose`; clear calls `onClear` and stays open. The widget itself never closes anything: it only calls its callbacks. Inside `show` the frame's close button pops the modal, so all three dismissals take the same path.

Implementation note: the dismissal is told apart from a result by the route's outcome. For the sort sheet, a `null` result means dismissed. For the filters sheet, a local flag set by the apply wrapper marks that the modal was closed by apply. `onClose` is called only when the modal was dismissed.

**4. Sort options as `Map<T, String>`, selected as `T?`.**
Insertion order is the display order, and no new option type is added. Alternative: a `SortOption<T>` class or record list; rejected to avoid a new type.

**5. Filters controllers and callbacks.**
`minController`, `maxController` (optional), `onClose`, `onClear`, `onApply` (a null button callback disables the button, like `ScalapayButton`). The price card is a private widget of the filters file; the standalone price filter was cancelled earlier.

**6. Layout from tokens.**
Frame: header 91 (measured constant), title `p1` in `textPrimary`, handle `textDisabled` at half opacity, close hit area 58x65 with the icon at 32; content padded `s`; bottom padding `s`. Filters card: `background`, radius `card`, padding `s`, title `p3Medium`, gap `s`, fields in a row around an 11px dash in `textDisabled` with `xs` on each side; then a `xs / 2` gap and the footer (padding `s`, two `Expanded` buttons with an `xs` gap). Sort card: `background`, radius `card`, horizontal padding `s`, each radio with `xs` vertical padding and a divider between rows (rows come to 64px, 259px in total against 256 in Figma). Measured constants without a token: header 91, handle 45x5, dash 11, close area 58x65.

**7. Two new radius tokens, `card` and `sheet`, both 20.**
`ScalapayRadius.card = 20` rounds the two white cards (price card and sort card); `ScalapayRadius.sheet = 20` rounds, in `BottomSheetFrame`, the two top corners of the sheet surface (`BorderRadius.vertical(top: Radius.circular(sheet))`). Both values are confirmed by the user (Figma radius 20). Separate tokens because the roles differ, as with the image radius, so each can change alone. Alternative: reuse `card` for the sheet; rejected by the user.

**8. Tests may allow `Colors.transparent`.**
The hardcoded-colors test now scans `lib/src/organisms/` too and lets `Colors.transparent` through (it is the absence of color, needed for the modal background); any other `Colors.*` or `Color(0x...)` still fails.

**9. Sort `show`: the choice stays visible for a short delay.**
`show` wraps the sort sheet in a private stateful widget that holds the selected value. Choosing an option sets it as selected (the radio updates at once) and starts a 300 ms timer; when it fires the modal pops with the value. A new choice replaces the value and restarts the timer (a debounce: the last choice wins); dismissing the modal cancels the timer, so no second pop happens and the dismissal path (`null`, `onClose`) is the normal one. No parameter is added: the delay is a private constant. The widget `ScalapaySortBottomSheet` itself is unchanged, because its caller already controls `selected`.

**10. Numeric-only price fields.**
`ScalapayTextField` gains `inputFormatters` (`List<TextInputFormatter>?`), the only way to restrict a field that hides its `TextField`; nothing changes when it is null. The filters sheet passes an internal `DecimalInputFormatter` (`lib/src/organisms/internal/`): the text may only match digits, then at most one separator (`.` or `,`), then digits; a comma is replaced by a period, so a field is always empty or valid for `double.tryParse`; text that breaks the pattern (letters, signs, spaces, a second separator, a pasted `1.2.3`) is rejected and the field keeps its previous text. Values set through a controller by the caller are not filtered. Alternative: keep the separator the user typed; rejected because the caller would have to normalize before parsing.

### Contracts

- `ScalapayFiltersBottomSheet({super.key, required String title, required String priceTitle, required String minLabel, required String maxLabel, required String clearLabel, required String applyLabel, TextEditingController? minController, TextEditingController? maxController, VoidCallback? onClose, VoidCallback? onClear, VoidCallback? onApply})` and `static Future<void> show(BuildContext context, {same parameters, including onClose})`, where `onClose` is called after a dismissal (close button, backdrop, drag).
- `ScalapaySortBottomSheet<T>({super.key, required String title, required Map<T, String> options, T? selected, ValueChanged<T>? onChanged, VoidCallback? onClose})` and `static Future<T?> show<T>(BuildContext context, {required String title, required Map<T, String> options, T? selected, VoidCallback? onClose})`, which returns the chosen value or null and calls `onClose` when dismissed.
- `ScalapayRadius.card -> double` (20) and `ScalapayRadius.sheet -> double` (20), both in `entries`.
- `ScalapayTextField({..., List<TextInputFormatter>? inputFormatters})` (new optional parameter).
- Internal: `DecimalInputFormatter extends TextInputFormatter` (digits, one `.` or `,`, comma converted to `.`).
- Internal: `BottomSheetFrame({required String title, required Widget child, VoidCallback? onClose})`, not in the barrel.
- Barrel: `organisms/organisms.dart` exports the two sheets only.
- Widgetbook (`widgetbook/lib/organisms/`): use cases for both sheets (filters empty and filled; sort with a selected option) and one use case per sheet that opens the modal from a button.

## Risks / Trade-offs

- [Layout values were measured from a screenshot, and the backdrop opacity (half) and the handle color (half-opacity `textDisabled`) are estimates] -> Re-read the nodes when Figma access returns and adjust values only.
- [The close button has no visible text, so it has no accessible name] -> No parameter is added now; a caller-supplied label is the follow-up if accessibility requires it.
- [On screens wider than 640 logical pixels the modal sheet is capped at 640 and centered, leaving side margins] -> Accepted by the user for phones in portrait; removing the cap is one line if a landscape or tablet layout needs it.
- [`onClose` runs when the closing animation starts, not when it ends] -> The caller sees exactly one call per dismissal; work that must wait for the sheet to disappear cannot rely on it.
- [Choosing an option (sort) and applying (filters) close the modal without `onClose`, an assumption] -> Written in the spec so it can be changed deliberately.
- [The comma the user types is shown as a period] -> The caller gets a string `double.tryParse` accepts; a locale-aware display would need the app's locale in the sheet.
- [Values set through a controller bypass the formatter] -> The caller is responsible for what it sets.
- [The 300 ms delay is a judgment] -> A private constant; changing it is a one-line edit, and it delays only the sort modal.
- [Sort rows come to 259px against 256 in Figma] -> Derived from existing spacing; the radio atom is unchanged.
- [`Colors.transparent` is allowed in the hardcoded-colors test] -> Only that constant; the rule for real colors stays.
- [The filters content is specific to the catalog] -> Accepted by the user; the frame stays internal so no generic API is created by accident.

## Migration Plan

Additive. No existing widget changes.
