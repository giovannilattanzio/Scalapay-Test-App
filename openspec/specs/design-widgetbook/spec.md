# design-widgetbook Specification

## Purpose

Provides a Widgetbook project so designers and developers can preview every design system atom and its states in isolation, without running the app.

## Requirements

### Requirement: Widgetbook runs standalone
The design system package SHALL include a Widgetbook project that runs on its own and applies the design system theme to all previewed widgets, so that design system tokens are available to every use case.

#### Scenario: Launch
- **WHEN** the Widgetbook project is launched
- **THEN** it opens with a navigable list of components

#### Scenario: Previews receive the theme
- **WHEN** any use case is opened
- **THEN** the previewed widget can read the design system tokens from its build context and renders without a missing-theme error

### Requirement: Every atom has use cases
Every atom SHALL have at least one Widgetbook use case, with additional use cases for each state it defines (for example enabled, disabled, error, selected).

#### Scenario: Coverage
- **WHEN** an atom is added to the design system
- **THEN** a Widgetbook use case for it exists before the atom is considered complete

### Requirement: Foundations are browsable
The Widgetbook project SHALL show the foundation tokens (color swatches with names and values, the text style scale, spacing and radius) as their own entries.

#### Scenario: Colors listed
- **WHEN** the colors entry is opened
- **THEN** each color token is shown with its name and hex value

### Requirement: Use cases open without errors
Every Widgetbook use case SHALL open inside the Widgetbook project without throwing, and this SHALL be verified by an automated test that opens each use case.

#### Scenario: Automated check
- **WHEN** the Widgetbook tests run
- **THEN** every use case is opened inside the Widgetbook and none reports an exception
