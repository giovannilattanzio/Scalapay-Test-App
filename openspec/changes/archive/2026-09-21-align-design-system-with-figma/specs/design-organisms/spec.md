# Spec Delta

## MODIFIED Requirements

### Requirement: Bottom sheet frame
Every bottom sheet organism SHALL show, on the surface color with rounded top corners, a handle centered at the top, a title centered below it and a close button at the top right, followed by the sheet content. The handle SHALL use the disabled text color at 40% opacity, as in Figma. The title SHALL be supplied by the caller and the close button SHALL call the close callback. The frame SHALL take the full width its parent offers and its height SHALL follow its content.

The frame SHALL also keep its content clear of the system inset at the bottom of the screen, adding that inset below the content. A modal bottom sheet extends to the physical bottom edge even when presented with the platform's safe-area option, which protects only the top and sides, so without this a sheet's last row — a footer button, the final option — sits under the home indicator. Where there is no bottom inset the frame SHALL lay out exactly as before.

#### Scenario: Frame content
- **WHEN** a bottom sheet is shown with a title
- **THEN** it shows the handle, that title centered, and the close button, on the surface color with rounded top corners

#### Scenario: Handle opacity
- **WHEN** a bottom sheet is shown
- **THEN** its handle is the disabled text color at 40% opacity

#### Scenario: Close button
- **WHEN** the user taps the close button
- **THEN** the close callback is invoked once

#### Scenario: Height follows content
- **WHEN** a bottom sheet is placed in a parent that allows an arbitrarily large height
- **THEN** its height does not grow with the available space

#### Scenario: Content clears the bottom system inset
- **WHEN** a sheet is shown on a screen with a bottom system inset
- **THEN** its last row ends above that inset rather than under it

#### Scenario: No inset, no change
- **WHEN** a sheet is shown on a screen with no bottom system inset
- **THEN** its layout is the same as before the inset was handled

### Requirement: Filters bottom sheet
The design system SHALL provide a filters bottom sheet containing, in a white rounded card, a price title and two writable fields for the minimum and the maximum price separated by a dash, and below the card a footer with a tertiary button to clear and a primary button to apply. The sheet title, the price title, the labels of the two fields and the labels of the two buttons SHALL be supplied by the caller, and the sheet SHALL NOT generate or translate any text. The two fields SHALL be the design system's text field with a numeric keyboard that accepts decimals, of equal width, and SHALL accept only numbers: digits with at most one decimal separator typed as a period or a comma, a comma being converted to a period so that the text of a field is always empty or a valid decimal number. Text that would break this (letters, a second separator, signs, spaces) SHALL be rejected and leave the field unchanged. The values SHALL be readable, settable and clearable through a text controller for each field, and the sheet SHALL work without controllers. The sheet SHALL NOT validate, parse or format the entered values. A button without a callback SHALL be disabled.

The card SHALL match the Figma measurements: 14 logical pixels of top padding and 16 at the bottom and sides, a 24px title row, 16 between the title row and the fields, and a 10px dash with 8 on each side. Without an error message the card SHALL be 126 logical pixels tall. The footer buttons SHALL be 6 logical pixels apart.

The sheet SHALL also accept an optional error message from the caller and, when one is given, show it once below the two price fields in the error style, because the error of a price range belongs to the pair rather than to either field. Supplying that message SHALL NOT make the sheet validate anything: the caller decides when the message appears and what it says, exactly as with every other text the sheet shows. Without a message the sheet SHALL reserve no space for one.

#### Scenario: Content comes from the caller
- **WHEN** a filters sheet is created with a title, a price title, two field labels and two button labels
- **THEN** it shows exactly those texts and no other text

#### Scenario: Typing updates the controllers
- **WHEN** the user types a value in each field and controllers were given
- **THEN** each controller holds the text of its own field

#### Scenario: Preset and cleared values
- **WHEN** a controller has a value before the sheet is shown, or is cleared afterwards
- **THEN** its field shows that value with the label floated, or becomes empty

#### Scenario: Works without controllers
- **WHEN** a filters sheet is created without controllers
- **THEN** both fields still accept typed text

#### Scenario: Only numbers
- **WHEN** the user types letters, spaces or a minus sign in a price field
- **THEN** the field ignores them and keeps its text

#### Scenario: One decimal separator
- **WHEN** the user types a second decimal separator in a price field that already has one
- **THEN** the field ignores it and keeps its text

#### Scenario: Comma becomes period
- **WHEN** the user types "12,5" in a price field
- **THEN** the field and its controller hold "12.5"

#### Scenario: Pasted text
- **WHEN** the user pastes "1500" or "12,5" into a price field, or pastes "abc" or "1.2.3"
- **THEN** the valid numbers are accepted (the comma becoming a period) and the invalid text is rejected, leaving the field unchanged

#### Scenario: No validation
- **WHEN** the user enters a minimum greater than the maximum
- **THEN** the sheet accepts both values and shows no message of its own

#### Scenario: Caller-supplied error message
- **WHEN** the sheet is given an error message
- **THEN** it shows that message once, below the two price fields, in the error style

#### Scenario: No message, no space
- **WHEN** the sheet is given no error message
- **THEN** it shows no message and reserves no space for one

#### Scenario: Card height
- **WHEN** a filters sheet is shown without an error message
- **THEN** its price card is 126 logical pixels tall

#### Scenario: Footer gap
- **WHEN** a filters sheet is shown
- **THEN** its two footer buttons are 6 logical pixels apart

#### Scenario: Footer actions
- **WHEN** the user taps the clear button or the apply button
- **THEN** the matching callback is invoked once

#### Scenario: Missing callback
- **WHEN** a button has no callback
- **THEN** it renders as disabled and tapping does nothing

#### Scenario: Equal fields
- **WHEN** a filters sheet is shown at any width
- **THEN** the two fields have the same width and together with the dash fill the card content width

### Requirement: Sort bottom sheet
The design system SHALL provide a sort bottom sheet containing, in a white rounded card, one radio option per sort choice, in the order given by the caller and separated by dividers, with no footer. The sheet title and the option labels SHALL be supplied by the caller. The choice values SHALL be of a type chosen by the caller. The option whose value equals the selected value SHALL be shown as selected. Choosing another option SHALL invoke the change callback with that option's value. The card SHALL be padded 15 logical pixels on the sides, each option row SHALL be 64 logical pixels tall with its divider drawn inside the row, so that a card of four options is 256 logical pixels tall as in Figma.

#### Scenario: Content comes from the caller
- **WHEN** a sort sheet is created with a title and four options
- **THEN** it shows the title and the four labels in the given order, and no other text

#### Scenario: Selected option
- **WHEN** the selected value equals the value of one option
- **THEN** that option is shown as selected and the others as unselected

#### Scenario: Choosing an option
- **WHEN** the user taps an unselected option
- **THEN** the change callback is invoked once with that option's value

#### Scenario: Dividers between options
- **WHEN** a sort sheet has several options
- **THEN** a divider separates each option from the next, and none is shown after the last

#### Scenario: Row height
- **WHEN** a sort sheet is shown with four options
- **THEN** each option row is 64 logical pixels tall and the card is 256 logical pixels tall
