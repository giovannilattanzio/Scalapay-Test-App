# Spec Delta

## Purpose

Provides the atomic UI widgets of the design (buttons, chip, inputs, radio, divider, icons), styled only from the design tokens, so screens are assembled from consistent, reusable building blocks.

## ADDED Requirements

### Requirement: Atoms take all visual values from tokens
Every atomic widget SHALL derive colors, text styles, spacing and radius from the design tokens and SHALL NOT hardcode visual values.

#### Scenario: Token change propagates
- **WHEN** a token value in the theme is changed
- **THEN** every atom using that token reflects the new value without code changes in the atom

### Requirement: Buttons
The design system SHALL provide a filled primary button (lilac background, white label) and a text button (lilac label, no background), each with enabled and disabled states and a tap callback.

#### Scenario: Enabled tap
- **WHEN** the user taps an enabled button
- **THEN** its callback is invoked once

#### Scenario: Disabled tap
- **WHEN** a button has no callback
- **THEN** it renders as disabled and tapping does nothing

### Requirement: Filter chip
The design system SHALL provide a chip with a leading icon and a label that reports taps.

#### Scenario: Chip tap
- **WHEN** the user taps the chip
- **THEN** its callback is invoked

### Requirement: Search field
The design system SHALL provide a search field with a text input and a round primary action button that submits the current text.

#### Scenario: Submit
- **WHEN** the user taps the action button with text "Nike"
- **THEN** the submit callback receives "Nike"

### Requirement: Text field with floating label
The design system SHALL provide a text field whose label floats above the value once the field has content or focus, with an optional error message.

#### Scenario: Label floats
- **WHEN** the field receives text
- **THEN** the label is shown in its floated position

#### Scenario: Error state
- **WHEN** an error message is provided
- **THEN** the message is shown and the field uses the error styling

### Requirement: Radio
The design system SHALL provide a radio option with a label that shows selected and unselected states and reports selection.

#### Scenario: Select
- **WHEN** the user taps an unselected option
- **THEN** the selection callback is invoked with that option's value

### Requirement: Divider and icons
The design system SHALL provide a divider using the border token and the icons used by the design (filter, order, search, close), rendered at a configurable size and color.

#### Scenario: Icon color
- **WHEN** an icon is given a color
- **THEN** it renders in that color
