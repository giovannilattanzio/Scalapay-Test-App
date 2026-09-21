# Tasks

Prefixes: `[design-system]` (packages/scalapay_ui and its Widgetbook) and `[tooling]` (agents, docs, config).

## 1. Foundations

- [x] 1.1 [design-system] Add `card = 20` and `sheet = 20` to `ScalapayRadius`, including `entries`, and test their values and that `card`, `sheet` and `image` are distinct tokens. (Card radius token; Sheet radius token)

## 2. Frame

- [x] 2.1 [design-system] Implement the internal `BottomSheetFrame` in `lib/src/organisms/internal/` (surface with the sheet radius on the top corners, handle, centered `p1` title, close button, content padded, bottom padding, height following content), not exported. (Bottom sheet frame)
- [x] 2.2 [design-system] Add frame tests: shows the title centered with the handle and close button; close callback once; height does not grow in a parent as tall as the screen; the frame is not exported by the barrel. (Bottom sheet frame; Frame is internal)

## 3. Filters sheet

- [x] 3.1 [design-system] Implement `ScalapayFiltersBottomSheet` in `lib/src/organisms/` with the contract in design.md (private price card, two `ScalapayTextField` with a numeric decimal keyboard, tertiary and primary `ScalapayButton` footer), and export it through `organisms/organisms.dart` and the barrel. (Filters bottom sheet; Organisms reuse existing components)
- [x] 3.2 [design-system] Add tests: only the given texts; typing updates each controller; preset and cleared values; works without controllers; no validation; footer callbacks once; a missing callback disables its button; equal field widths filling the card content. (Filters bottom sheet scenarios)

## 4. Sort sheet

- [x] 4.1 [design-system] Implement `ScalapaySortBottomSheet<T>` with `Map<T, String>` options, `ScalapayRadio` rows and dividers between rows only, and export it. (Sort bottom sheet)
- [x] 4.2 [design-system] Add tests: title and labels in the given order and nothing else; the selected option marked; choosing an option calls `onChanged` once with its value; dividers between rows and none after the last. (Sort bottom sheet scenarios)

## 5. Modal helpers

- [x] 5.1 [design-system] Implement `show` on both sheets with `showModalBottomSheet` (scroll controlled, safe area, transparent modal background, elevation 0, `overlay` barrier at half opacity, keyboard inset padding, scroll view), an `onClose` parameter called once after a dismissal (close button, backdrop tap, drag down), and the closing rules in design.md. (Opening a bottom sheet as a modal)
- [x] 5.2 [design-system] Add tests: the close button, a backdrop tap and a drag down each close the modal and call `onClose` exactly once; the sort modal returns the chosen value and closes without calling `onClose`, and returns null when dismissed; filters apply calls its callback and closes without `onClose`, clear calls its callback and stays open; content stays above a simulated keyboard inset; barrier color and no surface behind the corners. (Opening a bottom sheet as a modal scenarios)
- [x] 5.3 [design-system] Extend the hardcoded-colors test to `lib/src/organisms/` allowing only `Colors.transparent`. (Organisms reuse existing components)

## 6. Goldens

- [x] 6.1 [design-system] Add golden tests at 375px width: filters empty and filled, sort with the first option selected and with another selected, with fixed texts and no network assets, and check the images against the design.

## 7. Widgetbook

- [x] 7.1 [design-system] Add use cases under `widgetbook/lib/organisms/` (filters empty and filled, sort with a selected option, and one button per sheet that opens the modal), regenerate with `build_runner`, and add both sheets to the coverage test.

## 8. Agents and docs

- [x] 8.1 [tooling] Update `.claude/agents/flutter-design-system.md`: organisms are allowed in `lib/src/organisms/` (Widgetbook in `widgetbook/lib/organisms/`), composed from atoms, molecules and tokens with content injected by the caller, internal frames stay unexported.
- [x] 8.2 [tooling] Update the Design System Check in `.claude/skills/flutter-orchestrator/SKILL.md` so reusable organisms go to `flutter-design-system`.
- [x] 8.3 [tooling] Update `CLAUDE.md` and the `context` in `openspec/config.yaml` to mention organisms and their location.

## 9. Refinements after testing

- [x] 9.1 [design-system] Add `inputFormatters` to `ScalapayTextField` (null keeps today's behavior) and test that a rejecting formatter leaves the field unchanged and that without one any text is accepted. (Text field with floating label)
- [x] 9.2 [design-system] Add the internal `DecimalInputFormatter` and use it in both price fields of the filters sheet; test that letters, spaces, signs and a second separator are rejected, a comma becomes a period, valid and invalid pasted text, and that controllers hold the resulting text. (Filters bottom sheet: only numbers, one separator, comma becomes period, pasted text)
- [x] 9.3 [design-system] Make the sort `show` show the choice as selected and close after a 300 ms delay returning the value, restarting the delay on a new choice and cancelling it on dismissal; test with timed pumps: selected before closing, returned after the delay, last choice wins, dismissed during the delay returns null and calls `onClose` once. Update the existing sort modal test to wait for the delay. (Opening a bottom sheet as a modal)
