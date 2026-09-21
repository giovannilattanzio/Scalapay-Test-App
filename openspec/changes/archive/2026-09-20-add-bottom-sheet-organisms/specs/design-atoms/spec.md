# Spec Delta

## MODIFIED Requirements

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
