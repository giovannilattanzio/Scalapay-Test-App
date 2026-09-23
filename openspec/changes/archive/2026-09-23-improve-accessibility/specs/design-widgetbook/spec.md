# Spec Delta

## ADDED Requirements

### Requirement: Use cases meet accessibility guidelines
Every Widgetbook use case SHALL, when opened on its own without the Widgetbook panels, meet the labeled tap target guideline and the 44 by 44 tap target guideline, and this SHALL be verified by an automated test that opens each use case. A new component is covered as soon as it has a use case, without a test of its own for this check.

#### Scenario: Every use case passes
- **WHEN** the Widgetbook tests run
- **THEN** every use case is opened on its own and meets both guidelines

#### Scenario: A new component is checked automatically
- **WHEN** a component with a tap target smaller than 44 by 44, or without a label, is added with a use case
- **THEN** the Widgetbook tests fail naming that use case
