# Spec Delta

## ADDED Requirements

### Requirement: Catalog screen is usable with assistive technology
The catalog screen title SHALL be announced as a header. Every progress indicator (first page and further pages) SHALL be announced with a localized label saying that products are loading. The prompt, no-results, error and load-more error messages SHALL be announced to assistive technology when they appear, without the user having to move focus to them. Each product in the grid SHALL be reachable as one element, in grid order. All announced texts SHALL come from the app's translations in Italian and English.

#### Scenario: Title is a header
- **WHEN** the catalog screen is shown
- **THEN** its title is exposed as a header

#### Scenario: Loading is labeled
- **WHEN** a request is in flight
- **THEN** the loading indicator is exposed with the localized loading label

#### Scenario: No results are announced
- **WHEN** a search for "zzzqqq" returns no products
- **THEN** the no-results message is exposed as a live region

#### Scenario: Load-more failure is announced
- **WHEN** fetching a further page fails
- **THEN** its error message is exposed as a live region and its retry button offers the tap action

#### Scenario: Guidelines pass
- **WHEN** the catalog screen shows results
- **THEN** it meets the labeled tap target guideline and the 44 by 44 tap target guideline

### Requirement: Catalog screen supports large text
With the system text scaled up to 200%, the catalog screen, the filters sheet and the sort sheet SHALL show every text and control without layout overflow, and no text of the header, toolbar, product cards, messages or sheet options SHALL be cut off vertically.

#### Scenario: Results at 200%
- **WHEN** the catalog screen shows results with the text scale at 2.0 on a 375 wide screen
- **THEN** no layout overflow is reported

#### Scenario: Sheets at 200%
- **WHEN** the filters sheet and the sort sheet are open with the text scale at 2.0
- **THEN** no layout overflow is reported and every option and button is visible, scrolling if needed
