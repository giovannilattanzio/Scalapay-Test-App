## Purpose

Defines when, how often and with what delay the shared HTTP client transparently repeats a request that failed for a transient reason, and when it must never do so, so a transient network or service failure resolves on its own without the caller or the user seeing it.

## ADDED Requirements

### Requirement: Transient failures are retried transparently
The shared HTTP client SHALL automatically repeat a request that failed for a transient reason, without the caller or the presentation layer being aware of it. A request SHALL be repeated only when it is idempotent (GET, HEAD, PUT, DELETE, OPTIONS) or when it explicitly opts in, and only when its failure is one of: connection timeout, send timeout, receive timeout, connection error, or an HTTP answer with status 408, 429, 502, 503 or 504. The client SHALL NOT repeat a request that was cancelled, that failed certificate validation, that received status 500 or any other 4xx status, or whose failure is anything else.

#### Scenario: Timeout on a search is retried
- **WHEN** a product search times out and the retry budget is not spent
- **THEN** the same request is sent again and its result is returned to the caller as if it were the first attempt

#### Scenario: Service unavailable is retried
- **WHEN** the service answers 503 to a GET request
- **THEN** the request is sent again

#### Scenario: Client error is not retried
- **WHEN** the service answers 400, 404 or 422
- **THEN** no retry happens and the failure is reported at once

#### Scenario: Internal server error is not retried
- **WHEN** the service answers 500
- **THEN** no retry happens and the failure is reported at once

#### Scenario: Non-idempotent method is not retried by default
- **WHEN** a POST request times out and did not opt in to retry
- **THEN** no retry happens

#### Scenario: Cancellation is never retried
- **WHEN** a request is cancelled, including while waiting to retry
- **THEN** no further attempt is sent and the cancellation is reported

### Requirement: Retries are bounded and spaced out
The client SHALL make at most 2 retries (3 attempts in total) unless a request overrides the count, except that a request that failed with a timeout (connection, send or receive) SHALL be retried at most once. Waits between attempts SHALL grow exponentially with random jitter, starting from 500 ms and never exceeding 4 s. When the answer carries a `Retry-After` value, that value SHALL be used instead, provided it does not exceed 10 s; if it exceeds 10 s the request SHALL NOT be retried.

#### Scenario: Budget exhausted
- **WHEN** a request fails with a non-timeout retryable error, such as 503, on every one of its 3 attempts
- **THEN** no fourth attempt is made and the last error is reported

#### Scenario: Timeouts are retried once
- **WHEN** a request times out on every attempt
- **THEN** it is sent twice in total and the timeout is reported

#### Scenario: Backoff grows
- **WHEN** consecutive attempts fail with a non-timeout retryable error
- **THEN** the maximum wait before the second retry is larger than before the first, and neither exceeds 4 s

#### Scenario: Retry-After is honoured
- **WHEN** the service answers 429 with `Retry-After: 2`
- **THEN** the next attempt is sent after 2 s, not after the computed backoff

#### Scenario: Retry-After is too long
- **WHEN** the service answers 503 with `Retry-After: 60`
- **THEN** no retry happens and the failure is reported at once

### Requirement: Retry behaviour can be set per request
A request SHALL be able to opt out of retry, opt in when it is non-idempotent, or change its maximum retries, through the options it is sent with, without changing the defaults of other requests.

#### Scenario: Opt out
- **WHEN** a GET request is sent with retry disabled and it times out
- **THEN** no retry happens

#### Scenario: Opt in
- **WHEN** a POST request is sent with retry enabled and it gets a 503
- **THEN** the request is sent again

### Requirement: Exhausted retries surface as the existing typed failures
When retries are exhausted or not applicable, the caller of the data layer SHALL receive the same typed failure it receives today for that error, and no retry-specific exception or state SHALL leak to the presentation layer.

#### Scenario: Persistent outage
- **WHEN** every attempt of a search times out
- **THEN** the search reports a network failure

#### Scenario: Persistent service error
- **WHEN** every attempt of a search gets 503
- **THEN** the search reports a server failure carrying status 503

#### Scenario: Recovery mid-way
- **WHEN** the first attempt of a search fails with a timeout and the second succeeds
- **THEN** the search returns its products and no failure is reported
