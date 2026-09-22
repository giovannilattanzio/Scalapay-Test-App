/// Tunable numbers behind `RetryInterceptor`, and the `Options.extra` keys a
/// caller uses to override them for a single request.
///
/// Values match `openspec/changes/add-dio-retry-interceptor/design.md`
/// decisions 3 and 4: idempotent methods and the listed transient errors are
/// retried with exponential backoff and full jitter, capped, with a shorter
/// budget for timeouts (already expensive) than for other transient errors.
/// A plain `RetryPolicy()` carries the production defaults; tests build one
/// with narrower numbers instead of reaching for the extra keys below.
class RetryPolicy {
  const RetryPolicy({
    this.maxRetries = 2,
    this.timeoutMaxRetries = 1,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 4),
    this.maxRetryAfter = const Duration(seconds: 10),
    this.idempotentMethods = const {'GET', 'HEAD', 'PUT', 'DELETE', 'OPTIONS'},
    this.retryableStatuses = const {408, 429, 502, 503, 504},
  });

  /// Retry budget for a non-timeout retryable error (connection error, or
  /// status 408/429/502/503/504): up to 2 retries, 3 attempts in total.
  final int maxRetries;

  /// Retry budget for a timeout (connection, send or receive): up to 1
  /// retry, 2 attempts in total, because each attempt already costs the full
  /// configured timeout.
  final int timeoutMaxRetries;

  /// Starting point of the exponential backoff, before jitter.
  final Duration baseDelay;

  /// Upper bound on the computed backoff delay, regardless of attempt count.
  final Duration maxDelay;

  /// Upper bound on a server-provided `Retry-After` value. A larger value
  /// means the request is not retried at all rather than waiting that long.
  final Duration maxRetryAfter;

  /// HTTP methods safe to repeat without risking a duplicated side effect.
  /// `RequestOptions.method` is always upper-case.
  final Set<String> idempotentMethods;

  /// `badResponse` statuses treated as transient. 500 is deliberately
  /// excluded (design.md decision 3): it is usually a deterministic server
  /// bug that repeating would only hide.
  final Set<int> retryableStatuses;

  /// `Options.extra` key: `bool`. `false` opts an otherwise-idempotent
  /// request out of retry; `true` opts a non-idempotent request in.
  static const retryExtraKey = 'retry';

  /// `Options.extra` key: `int`. Overrides the applicable retry budget
  /// (`maxRetries` or `timeoutMaxRetries`) for this one request.
  static const maxRetriesExtraKey = 'maxRetries';

  /// `Options.extra` key: `int`. Internal bookkeeping used only by
  /// `RetryInterceptor` to track how many retries a request has already
  /// spent; callers do not set this.
  static const retryCountExtraKey = 'retryCount';
}
