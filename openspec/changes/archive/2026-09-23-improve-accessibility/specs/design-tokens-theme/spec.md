# Spec Delta

## ADDED Requirements

### Requirement: Text contrast of color tokens is measured
The design system SHALL verify, with an automated test, the contrast ratio of every text color token against each background it is used on (background and surface, and the on-primary label on primary). A pair SHALL reach 4.5:1 unless it is listed as a known exception together with its measured ratio and the reason it is kept. The known exceptions SHALL be the secondary text color on background (3.44:1) and on surface (3.22:1), the error color on background (4.38:1) and the disabled text color, which WCAG exempts for inactive controls; all keep their Figma values until design changes them. Adding a text color token, or changing a value, SHALL make the test fail if the new pair is below 4.5:1 and not listed.

#### Scenario: Compliant pairs
- **WHEN** the contrast test runs with the current tokens
- **THEN** primary text, store name text, input text and primary on background all reach at least 4.5:1, and the on-primary label on primary reaches at least 4.5:1

#### Scenario: Documented exception
- **WHEN** the contrast test runs with the current tokens
- **THEN** the secondary text and error pairs are reported with their measured ratios as known exceptions and the test passes

#### Scenario: New regression is caught
- **WHEN** a text color token is changed so that it falls below 4.5:1 on background and is not a listed exception
- **THEN** the contrast test fails naming that pair and its ratio
