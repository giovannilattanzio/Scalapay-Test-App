# Spec Delta

## ADDED Requirements

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

## MODIFIED Requirements

### Requirement: Buttons
The design system SHALL provide a filled primary button (lilac background, white label) and a text button (lilac label, no background), each with enabled and disabled states and a tap callback. A button SHALL size itself to its content (minimum height 48) and SHALL NOT grow to fill the vertical space its parent offers.

#### Scenario: Enabled tap
- **WHEN** the user taps an enabled button
- **THEN** its callback is invoked once

#### Scenario: Disabled tap
- **WHEN** a button has no callback
- **THEN** it renders as disabled and tapping does nothing

#### Scenario: Height does not depend on available space
- **WHEN** a button is placed in a parent that allows an arbitrarily large height (for example a centered container as tall as the screen)
- **THEN** the button is 48 logical pixels tall
