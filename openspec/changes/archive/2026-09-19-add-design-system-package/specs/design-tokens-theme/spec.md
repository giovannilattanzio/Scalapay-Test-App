# Spec Delta

## Purpose

Defines the visual foundations (colors, typography, spacing, radius) and the app theme derived from them, so every widget reads visual values from one tokenized source instead of hardcoding them.

## ADDED Requirements

### Requirement: Foundations are defined as named tokens
The design system SHALL expose color, typography, spacing and radius values as named tokens whose values match the Figma variables: primary lilac `#5666F0`, the grayscale ramp (`#FFFFFF`, `#F6F7FB`, `#EFF1F5`, `#9E9E9E`, `#8A8A8D`, `#3A4045`, `#272727`), spacing steps 8 and 16, and radius 10. Tokens SHALL use semantic names (for example surface, border, text secondary) rather than the duplicated numeric grayscale names of the source file.

#### Scenario: Token matches design value
- **WHEN** a consumer reads the primary color token
- **THEN** it equals `#5666F0`

#### Scenario: Duplicate source names collapse
- **WHEN** two Figma variables share the same value (`#F6F7FB` as Grayscale/200 and /300)
- **THEN** the design system exposes a single token for that value

### Requirement: Typography uses Poppins from bundled assets
The design system SHALL provide the text styles found in the design (H2 25/30, P1 15, P3 13, P4 12, P5 11, button 14) in Poppins SemiBold or Medium as specified, and SHALL render Poppins without network access.

#### Scenario: Offline rendering
- **WHEN** the app runs without network access
- **THEN** text styled with any design system text style renders in Poppins

#### Scenario: Style metrics
- **WHEN** a consumer reads the H2 style
- **THEN** it has size 25, line height 30 and weight 600

### Requirement: Theme exposes tokens through the app theme
The design system SHALL provide a theme that applies the tokens to the Material theme and makes them retrievable from any widget's build context.

#### Scenario: Tokens available in context
- **WHEN** an app is built with the design system theme
- **THEN** a widget can read every foundation token from its build context

#### Scenario: Missing theme
- **WHEN** a design system widget is built without the design system theme in scope
- **THEN** the failure is explicit (an assertion or clear error), not a silent fallback to arbitrary values
