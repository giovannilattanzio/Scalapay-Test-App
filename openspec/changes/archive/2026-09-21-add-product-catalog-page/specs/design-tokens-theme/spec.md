# Spec Delta

## MODIFIED Requirements

### Requirement: Typography uses Poppins from bundled assets
The design system SHALL provide the text styles found in the design (H2 25/30, P1 15, P2 14/21, P3 13, P4 12, P5 11, button 14) in Poppins SemiBold or Medium as specified, and SHALL render Poppins without network access. A size that the design uses in two weights SHALL have one token per weight, so that a consumer never re-weights a token at the call site.

#### Scenario: Offline rendering
- **WHEN** the app runs without network access
- **THEN** text styled with any design system text style renders in Poppins

#### Scenario: Style metrics
- **WHEN** a consumer reads the H2 style
- **THEN** it has size 25, line height 30 and weight 600

#### Scenario: P2 style
- **WHEN** a consumer reads the P2 style
- **THEN** it has size 14, line height 21 and weight 600

#### Scenario: P5 in two weights
- **WHEN** a consumer reads the two P5 styles
- **THEN** both have size 11 and line height 16.5, one has weight 500 and the other weight 600
