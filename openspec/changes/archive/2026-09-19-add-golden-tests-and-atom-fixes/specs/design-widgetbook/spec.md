# Spec Delta

## ADDED Requirements

### Requirement: Use cases open without errors
Every Widgetbook use case SHALL open inside the Widgetbook project without throwing, and this SHALL be verified by an automated test that opens each use case.

#### Scenario: Automated check
- **WHEN** the Widgetbook tests run
- **THEN** every use case is opened inside the Widgetbook and none reports an exception

## MODIFIED Requirements

### Requirement: Widgetbook runs standalone
The design system package SHALL include a Widgetbook project that runs on its own and applies the design system theme to all previewed widgets, so that design system tokens are available to every use case.

#### Scenario: Launch
- **WHEN** the Widgetbook project is launched
- **THEN** it opens with a navigable list of components

#### Scenario: Previews receive the theme
- **WHEN** any use case is opened
- **THEN** the previewed widget can read the design system tokens from its build context and renders without a missing-theme error
