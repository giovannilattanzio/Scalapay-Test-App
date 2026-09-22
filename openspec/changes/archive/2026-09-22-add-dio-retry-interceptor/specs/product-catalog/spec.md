## ADDED Requirements

### Requirement: Results of a superseded request are discarded
The catalog screen SHALL show only the results of the latest search, sort or price filter the user applied. When a request completes after a newer search, sort or filter has been started, its outcome, whether products or failure, SHALL be dropped without changing what the screen shows. A further page that completes after the results were restarted SHALL likewise be dropped.

#### Scenario: Slow search finishes after a newer one
- **WHEN** the user searches "a", then searches "b", and the request for "b" completes before the one for "a"
- **THEN** the screen shows the results of "b" and the late results of "a" are ignored

#### Scenario: Slow search fails after a newer one succeeded
- **WHEN** a superseded search fails after a newer search has succeeded
- **THEN** the screen keeps showing the newer results and no failure is shown

#### Scenario: Sort changed while a further page is loading
- **WHEN** the user changes the sort while a further page of the previous ordering is still loading
- **THEN** the late page is not added to the results of the new ordering

#### Scenario: Latest request still applies normally
- **WHEN** no newer request has been started
- **THEN** the outcome of the request is shown as usual
