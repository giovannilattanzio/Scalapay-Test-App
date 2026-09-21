# Spec Delta

## MODIFIED Requirements

### Requirement: Buttons
The design system SHALL provide a single button component with two variants: a primary variant (filled lilac background, white label) and a tertiary variant (lilac label, no background). The primary variant SHALL be the default, and both variants SHALL support enabled and disabled states and a tap callback. A variant of the button SHALL NOT be provided as a separate component. A button SHALL size itself to its content (minimum height 44) and SHALL NOT grow to fill the vertical space its parent offers. Both variants SHALL pad their label by 16 logical pixels on each side, as the Figma button components do.

#### Scenario: Enabled tap
- **WHEN** the user taps an enabled button of either variant
- **THEN** its callback is invoked once

#### Scenario: Disabled tap
- **WHEN** a button has no callback
- **THEN** it renders as disabled and tapping does nothing

#### Scenario: Default variant
- **WHEN** a button is created without choosing a variant
- **THEN** it renders as the primary variant

#### Scenario: Tertiary has no fill
- **WHEN** a tertiary button is enabled
- **THEN** it has no background and its label uses the primary color

#### Scenario: Disabled tertiary label
- **WHEN** a tertiary button has no callback
- **THEN** its label uses the disabled text color and it still has no background

#### Scenario: Height does not depend on available space
- **WHEN** a button of either variant is placed in a parent that allows an arbitrarily large height (for example a centered container as tall as the screen)
- **THEN** the button is 44 logical pixels tall

#### Scenario: Horizontal padding
- **WHEN** a button of either variant is laid out at its intrinsic width
- **THEN** its width is the label width plus 32 logical pixels (unless the 48 minimum width applies)

### Requirement: Filter chip
The design system SHALL provide a chip with a leading icon and a label that reports taps. The chip SHALL be 32 logical pixels tall and SHALL lay out each icon as the Figma chips do: with the filter icon, a 20px icon, a 2px gap before the label and padding of 8 on the left and 10 on the right; with the order icon, a 24px icon, no gap and padding of 4 on the left and 8 on the right. Any other icon SHALL use the filter layout.

#### Scenario: Chip tap
- **WHEN** the user taps the chip
- **THEN** its callback is invoked

#### Scenario: Filter chip layout
- **WHEN** a chip is shown with the filter icon
- **THEN** its icon is 20px, 8px from the left edge, and its width is the label width plus 40 logical pixels

#### Scenario: Order chip layout
- **WHEN** a chip is shown with the order icon
- **THEN** its icon is 24px, 4px from the left edge, and its width is the label width plus 36 logical pixels

### Requirement: Text field with floating label
The design system SHALL provide a text field whose label floats above the value once the field has content or focus, with an optional error message. The field SHALL be 56 logical pixels tall (without the error message) and its value text SHALL use the field value color token. Once floated, the label SHALL appear on screen at the P5 size (11 logical pixels), as in Figma, whatever scaling the platform applies to floating labels. The caller MAY restrict what the field accepts through input formatters, and text that a formatter rejects SHALL leave the field unchanged.

#### Scenario: Label floats
- **WHEN** the field receives text
- **THEN** the label is shown in its floated position

#### Scenario: Error state
- **WHEN** an error message is provided
- **THEN** the message is shown and the field uses the error styling

#### Scenario: Restricted input
- **WHEN** a formatter that accepts only digits is given and the user types a letter
- **THEN** the field keeps its text unchanged

#### Scenario: Unrestricted by default
- **WHEN** no formatter is given
- **THEN** the field accepts any typed text

#### Scenario: Field height
- **WHEN** a field without an error message is laid out, empty or with a value
- **THEN** it is 56 logical pixels tall

#### Scenario: Value color
- **WHEN** the field shows a value
- **THEN** the value text uses the field value color (`#3A4045`)

#### Scenario: Floated label size
- **WHEN** the field has a value and its label is floated
- **THEN** the label is rendered 11 logical pixels tall in font size (P5), not smaller

### Requirement: Radio
The design system SHALL provide a radio option with a label that shows selected and unselected states and reports selection. The radio glyph SHALL be a 20px ring centered in a 24px box, followed by a 10px gap and the label in the P2 Medium style. The selected ring and its dot SHALL use the primary color; the unselected ring SHALL use the muted primary color.

#### Scenario: Select
- **WHEN** the user taps an unselected option
- **THEN** the selection callback is invoked with that option's value

#### Scenario: Unselected color
- **WHEN** an option is not selected
- **THEN** its ring uses the muted primary color (`#CACCF2`)

#### Scenario: Label position and style
- **WHEN** an option is laid out
- **THEN** its label starts 34 logical pixels from the option's left edge and uses the P2 Medium style
