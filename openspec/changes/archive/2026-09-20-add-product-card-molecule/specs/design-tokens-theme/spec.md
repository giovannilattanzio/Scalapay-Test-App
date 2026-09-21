# Spec Delta

## MODIFIED Requirements

### Requirement: Foundations are defined as named tokens
The design system SHALL expose color, typography, spacing and radius values as named tokens whose values match the Figma variables: primary lilac `#5666F0`, the grayscale ramp (`#FFFFFF`, `#F6F7FB`, `#EFF1F5`, `#9E9E9E`, `#8A8A8D`, `#3A4045`, `#272727`), spacing steps 8 and 16, and radii 10 and 20 (the image radius). Tokens SHALL use semantic names (for example surface, border, text secondary) rather than the duplicated numeric grayscale names of the source file, and the store name text color (`#3A4045`) SHALL have its own token.

#### Scenario: Token matches design value
- **WHEN** a consumer reads the primary color token
- **THEN** it equals `#5666F0`

#### Scenario: Duplicate source names collapse
- **WHEN** two Figma variables share the same value (`#F6F7FB` as Grayscale/200 and /300)
- **THEN** the design system exposes a single token for that value

#### Scenario: Image radius token
- **WHEN** a consumer reads the image radius token
- **THEN** it equals 20

#### Scenario: Store name color token
- **WHEN** a consumer reads the store name text color token
- **THEN** it equals `#3A4045`
