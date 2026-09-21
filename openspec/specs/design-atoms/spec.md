# design-atoms Specification

## Purpose

Provides the atomic UI widgets of the design (buttons, chip, inputs, radio, divider, icons), styled only from the design tokens, so screens are assembled from consistent, reusable building blocks.

## Requirements

### Requirement: Atoms take all visual values from tokens
Every atomic widget SHALL derive colors, text styles, spacing and radius from the design tokens and SHALL NOT hardcode visual values.

#### Scenario: Token change propagates
- **WHEN** a token value in the theme is changed
- **THEN** every atom using that token reflects the new value without code changes in the atom

### Requirement: Buttons
The design system SHALL provide a single button component with two variants: a primary variant (filled lilac background, white label) and a tertiary variant (lilac label, no background). The primary variant SHALL be the default, and both variants SHALL support enabled and disabled states and a tap callback. A variant of the button SHALL NOT be provided as a separate component. A button SHALL size itself to its content (minimum height 44) and SHALL NOT grow to fill the vertical space its parent offers.

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
The design system SHALL provide a text field whose label floats above the value once the field has content or focus, with an optional error message. The caller MAY restrict what the field accepts through input formatters, and text that a formatter rejects SHALL leave the field unchanged.

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

### Requirement: Golden tests cover every component state
Every UI component in the design system package SHALL have a golden test with one image per visual state it defines (for example enabled, disabled, error, selected, filled). Goldens SHALL render the component with the design system theme and the bundled Poppins font, at its intrinsic size.

#### Scenario: Every atom has goldens
- **WHEN** the design system tests run
- **THEN** each atom has at least one golden image, and each state defined for it has its own image

#### Scenario: Visual regression is detected
- **WHEN** a component's rendering changes without its golden being regenerated
- **THEN** the golden test fails

#### Scenario: Goldens use the design font
- **WHEN** a golden is rendered
- **THEN** its text is drawn in Poppins, not the test fallback font

### Requirement: Icon assets are exposed as constants
The design system SHALL expose the path of every icon asset as a named constant, together with the package that owns the assets and the list of all icon paths, so an icon can be loaded without repeating asset path strings.

#### Scenario: Constants match files
- **WHEN** an icon constant is read
- **THEN** it points to an existing asset file

#### Scenario: Constants match the icon set
- **WHEN** the list of all icon paths is read
- **THEN** it contains exactly the assets of the icon set, in the same order as the icon enumeration
