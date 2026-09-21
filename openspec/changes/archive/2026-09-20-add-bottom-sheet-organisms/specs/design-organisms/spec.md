# Spec Delta

## Purpose

Provides bottom sheet organisms assembled from design system atoms and tokens, with all their content supplied by the caller, and a way to open each one as a modal.

## ADDED Requirements

### Requirement: Bottom sheet frame
Every bottom sheet organism SHALL show, on the surface color with rounded top corners, a handle centered at the top, a title centered below it and a close button at the top right, followed by the sheet content. The title SHALL be supplied by the caller and the close button SHALL call the close callback. The frame SHALL take the full width its parent offers and its height SHALL follow its content.

#### Scenario: Frame content
- **WHEN** a bottom sheet is shown with a title
- **THEN** it shows the handle, that title centered, and the close button, on the surface color with rounded top corners

#### Scenario: Close button
- **WHEN** the user taps the close button
- **THEN** the close callback is invoked once

#### Scenario: Height follows content
- **WHEN** a bottom sheet is placed in a parent that allows an arbitrarily large height
- **THEN** its height does not grow with the available space

### Requirement: Filters bottom sheet
The design system SHALL provide a filters bottom sheet containing, in a white rounded card, a price title and two writable fields for the minimum and the maximum price separated by a dash, and below the card a footer with a tertiary button to clear and a primary button to apply. The sheet title, the price title, the labels of the two fields and the labels of the two buttons SHALL be supplied by the caller, and the sheet SHALL NOT generate or translate any text. The two fields SHALL be the design system's text field with a numeric keyboard that accepts decimals, of equal width, and SHALL accept only numbers: digits with at most one decimal separator typed as a period or a comma, a comma being converted to a period so that the text of a field is always empty or a valid decimal number. Text that would break this (letters, a second separator, signs, spaces) SHALL be rejected and leave the field unchanged. The values SHALL be readable, settable and clearable through a text controller for each field, and the sheet SHALL work without controllers. The sheet SHALL NOT validate, parse or format the entered values. A button without a callback SHALL be disabled.

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
- **THEN** the sheet accepts both values and shows no message

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
The design system SHALL provide a sort bottom sheet containing, in a white rounded card, one radio option per sort choice, in the order given by the caller and separated by dividers, with no footer. The sheet title and the option labels SHALL be supplied by the caller. The choice values SHALL be of a type chosen by the caller. The option whose value equals the selected value SHALL be shown as selected. Choosing another option SHALL invoke the change callback with that option's value.

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

### Requirement: Opening a bottom sheet as a modal
Each bottom sheet organism SHALL offer a way to open it as a modal bottom sheet from a build context. The modal SHALL appear from the bottom over a backdrop dimmed with the overlay color, SHALL show no surface behind the rounded top corners, SHALL scroll when it is taller than the available space and SHALL stay above the on-screen keyboard. The modal SHALL close when the user taps the close button, taps the backdrop or drags the sheet down, and in each of these three cases the close callback given by the caller SHALL be invoked once, as soon as the modal is dismissed (while it starts to close). For the sort sheet, choosing an option SHALL show it as selected and, after a short delay (about 300 ms) so that the user sees the choice, close the modal and return the chosen value without invoking the close callback; choosing another option during the delay SHALL replace the choice and restart the delay, and dismissing the modal during the delay SHALL return no value and invoke the close callback once. For the filters sheet, the apply button SHALL invoke its callback and then close the modal without invoking the close callback, and the clear button SHALL invoke its callback without closing it.

#### Scenario: Close button
- **WHEN** a bottom sheet is opened as a modal and the user taps the close button
- **THEN** the modal closes, returns no value, and the close callback is invoked once

#### Scenario: Backdrop tap
- **WHEN** the user taps the backdrop of a bottom sheet opened as a modal
- **THEN** the modal closes and the close callback is invoked once

#### Scenario: Drag down
- **WHEN** the user drags a bottom sheet opened as a modal down to dismiss it
- **THEN** the modal closes and the close callback is invoked once

#### Scenario: Sort shows the choice before closing
- **WHEN** the user chooses an option in a sort sheet opened as a modal
- **THEN** the option is shown as selected while the modal is still open

#### Scenario: Sort returns the choice
- **WHEN** the user has chosen an option in a sort sheet opened as a modal and the short delay has passed
- **THEN** the modal closes, returns that option's value, and the close callback is not invoked

#### Scenario: Choosing again during the delay
- **WHEN** the user chooses another option before the delay has passed
- **THEN** the modal stays open until the delay after the last choice has passed, and returns the last chosen value

#### Scenario: Dismissed during the delay
- **WHEN** the user dismisses the modal after choosing an option but before the delay has passed
- **THEN** the modal returns no value and the close callback is invoked once

#### Scenario: Filters apply
- **WHEN** the user taps apply in a filters sheet opened as a modal
- **THEN** the apply callback is invoked, the modal closes, and the close callback is not invoked

#### Scenario: Filters clear
- **WHEN** the user taps clear in a filters sheet opened as a modal
- **THEN** the clear callback is invoked and the modal stays open

#### Scenario: Keyboard
- **WHEN** the keyboard is shown while the user types in a price field of a filters sheet opened as a modal
- **THEN** the sheet content stays above the keyboard

#### Scenario: Backdrop color
- **WHEN** a bottom sheet is opened as a modal
- **THEN** the screen behind it is dimmed with the overlay color, and no surface shows behind the rounded corners

### Requirement: Organisms reuse existing components
An organism SHALL be composed from existing atoms, molecules and tokens. It SHALL NOT introduce a widget or a token that duplicates an existing one, and the frame shared by the bottom sheets SHALL NOT be part of the public API.

#### Scenario: Existing components
- **WHEN** a bottom sheet needs an input, a button, a radio option, a divider or an icon
- **THEN** it uses the design system's existing component for it

#### Scenario: Frame is internal
- **WHEN** a consumer imports the design system
- **THEN** no generic bottom sheet frame is available, only the filters and sort sheets
