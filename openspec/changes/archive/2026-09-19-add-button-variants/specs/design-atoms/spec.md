# Spec Delta

## MODIFIED Requirements

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
