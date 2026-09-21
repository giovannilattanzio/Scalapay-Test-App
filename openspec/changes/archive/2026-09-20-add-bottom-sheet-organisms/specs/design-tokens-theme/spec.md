# Spec Delta

## MODIFIED Requirements

### Requirement: Foundations are defined as named tokens
The design system SHALL expose color, typography, spacing and radius values as named tokens whose values match the Figma variables: primary lilac `#5666F0`, the grayscale ramp (`#FFFFFF`, `#F6F7FB`, `#EFF1F5`, `#9E9E9E`, `#8A8A8D`, `#3A4045`, `#272727`), spacing steps 8 and 16, and radii 10, 20 for image areas, 20 for cards and 20 for the top corners of bottom sheets. Tokens SHALL use semantic names (for example surface, border, text secondary) rather than the duplicated numeric grayscale names of the source file, the store name text color (`#3A4045`) SHALL have its own token, and the image radius, the card radius and the sheet radius SHALL be separate tokens even though they have the same value.

#### Scenario: Token matches design value
- **WHEN** a consumer reads the primary color token
- **THEN** it equals `#5666F0`

#### Scenario: Duplicate source names collapse
- **WHEN** two Figma variables share the same value (`#F6F7FB` as Grayscale/200 and /300)
- **THEN** the design system exposes a single token for that value

#### Scenario: Image radius token
- **WHEN** a consumer reads the image radius token
- **THEN** it equals 20

#### Scenario: Card radius token
- **WHEN** a consumer reads the card radius token
- **THEN** it equals 20 and is a token distinct from the image radius

#### Scenario: Sheet radius token
- **WHEN** a consumer reads the sheet radius token
- **THEN** it equals 20, is a token distinct from the card radius and from the image radius, and is used for the top corners of bottom sheets

#### Scenario: Store name color token
- **WHEN** a consumer reads the store name text color token
- **THEN** it equals `#3A4045`
