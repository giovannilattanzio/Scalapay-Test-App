## MODIFIED Requirements

### Requirement: The client shares the application's configured transport
The generated client SHALL be constructed with the HTTP client the application already configures, rather than creating its own, so that the address, the timeouts, the retry behaviour of `http-retry` and any future shared behaviour apply to it. Transport errors raised by the generated client SHALL be translated into the application's typed failures before leaving the data layer.

#### Scenario: One transport instance
- **WHEN** the dependency graph is resolved
- **THEN** the generated client uses the same configured HTTP client instance as the rest of the application

#### Scenario: Timeouts apply
- **WHEN** a request through the generated client exceeds the configured timeout on every attempt
- **THEN** the data layer reports a network failure

#### Scenario: Retry applies to the generated client
- **WHEN** a request made through the generated client fails with a retryable error
- **THEN** it is retried according to `http-retry` without any change to the generated code

#### Scenario: No transport type escapes
- **WHEN** the generated client raises a transport error
- **THEN** the caller of the data layer receives a typed failure and no generator or transport exception propagates
