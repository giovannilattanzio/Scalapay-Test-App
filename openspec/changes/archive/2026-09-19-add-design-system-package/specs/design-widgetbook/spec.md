# Spec Delta

## Purpose

Provides a Widgetbook project so designers and developers can preview every design system atom and its states in isolation, without running the app.

## ADDED Requirements

### Requirement: Widgetbook runs standalone
The design system package SHALL include a Widgetbook project that runs on its own and applies the design system theme to all previews.

#### Scenario: Launch
- **WHEN** the Widgetbook project is launched
- **THEN** it opens with the design system theme and a navigable list of components

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
