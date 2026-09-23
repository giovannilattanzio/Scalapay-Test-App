# Spec Delta

## ADDED Requirements

### Requirement: Bottom sheets are usable with assistive technology
The close button of every bottom sheet SHALL be announced as a button with a label and SHALL offer the tap action, invoking the same close callback as a touch. The label SHALL be supplied by the caller when given, and otherwise SHALL be the platform's localized word for "close" in the app's locale. The sheet title SHALL be announced as a header. When the filters sheet shows a price error, the error SHALL be announced to assistive technology as it appears, without the user having to move focus to it.

#### Scenario: Close button is labeled
- **WHEN** a sheet is shown without a close label in an app whose locale is Italian
- **THEN** its close button is exposed as a button with the Italian localized close label

#### Scenario: Caller-supplied close label
- **WHEN** a sheet is shown with the close label "Chiudi filtri"
- **THEN** its close button is exposed as a button labeled "Chiudi filtri"

#### Scenario: Close activated by a screen reader
- **WHEN** a screen reader performs the tap action on the close button
- **THEN** the close callback is invoked once

#### Scenario: Price error is announced
- **WHEN** the filters sheet is rebuilt with a price error message
- **THEN** that message is exposed as a live region

#### Scenario: Guidelines pass for both sheets
- **WHEN** the filters sheet and the sort sheet are shown
- **THEN** both meet the labeled tap target guideline and the 44 by 44 tap target guideline
