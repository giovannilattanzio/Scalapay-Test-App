import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';

import 'retry_policy.dart';

Future<void> _defaultDelay(Duration duration) => Future.delayed(duration);

const _timeoutTypes = {
  DioExceptionType.connectionTimeout,
  DioExceptionType.sendTimeout,
  DioExceptionType.receiveTimeout,
};

/// Dio [Interceptor] that transparently repeats a request that failed for a
/// transient reason, with exponential backoff and full jitter, up to a
/// bounded number of retries.
///
/// See `openspec/changes/add-dio-retry-interceptor/design.md` (decisions
/// 3-7) for the eligibility rules, the backoff formula and the `Retry-After`
/// and cancellation handling this class implements. Once the retry budget is
/// exhausted, or a failure is not eligible at all, the original
/// [DioException] is forwarded unchanged (`handler.next`), so
/// `ProductRepositoryImpl._mapDioException` (and any future caller of the
/// data layer) sees exactly the failure it would see without this
/// interceptor.
///
/// [dio] is re-used to re-dispatch a retried request (`dio.fetch`), which
/// runs it back through this same interceptor, so a further failure re-enters
/// [onError] and the incremented retry count in `extra` decides whether it
/// retries again. [delay] and [random] are injectable so tests can run fully
/// offline and deterministically, without a real sleep.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this.dio, {
    this.policy = const RetryPolicy(),
    this.delay = _defaultDelay,
    Random? random,
  }) : random = random ?? Random();

  final Dio dio;
  final RetryPolicy policy;
  final Future<void> Function(Duration duration) delay;
  final Random random;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_isEligible(err)) {
      handler.next(err);
      return;
    }

    final retryDelay = _computeDelay(err);
    if (retryDelay == null) {
      // A Retry-After above the cap means "do not retry at all" (design.md
      // decision 4), not "retry after the cap".
      handler.next(err);
      return;
    }

    final cancellation = await _waitUnlessCancelled(
      retryDelay,
      err.requestOptions.cancelToken,
    );
    if (cancellation != null) {
      handler.next(cancellation);
      return;
    }

    final retryCount = _retryCountOf(err.requestOptions);
    final newExtra = Map<String, dynamic>.of(err.requestOptions.extra)
      ..[RetryPolicy.retryCountExtraKey] = retryCount + 1;
    final newOptions = err.requestOptions.copyWith(extra: newExtra);

    developer.log(
      'Retrying ${newOptions.method} ${newOptions.path} '
      '(attempt ${retryCount + 2}) after $retryDelay; '
      'reason: ${_reasonOf(err)}',
      name: 'RetryInterceptor',
    );

    // If this throws, the new DioException has already been through
    // onError again (dio.fetch re-runs the full interceptor chain on the
    // shared `dio`), so it is either resolved or has itself been rejected
    // with the right (possibly further-incremented) retry count. Letting it
    // propagate here, instead of catching it, is what makes dio surface that
    // final DioException to the caller: an uncaught error from an `onError`
    // override is turned into `handler.reject` by dio itself.
    final response = await dio.fetch<dynamic>(newOptions);
    handler.resolve(response);
  }

  bool _isEligible(DioException err) {
    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    final extra = err.requestOptions.extra;
    final explicitRetry = extra[RetryPolicy.retryExtraKey];
    if (explicitRetry == false) {
      return false;
    }
    final isIdempotent = policy.idempotentMethods.contains(
      err.requestOptions.method.toUpperCase(),
    );
    if (!isIdempotent && explicitRetry != true) {
      return false;
    }

    if (!_isRetryableError(err)) {
      return false;
    }

    final applicableMax = _applicableMaxRetries(err);
    return _retryCountOf(err.requestOptions) < applicableMax;
  }

  bool _isRetryableError(DioException err) {
    if (_timeoutTypes.contains(err.type) ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }
    if (err.type == DioExceptionType.badResponse) {
      final status = err.response?.statusCode;
      return status != null && policy.retryableStatuses.contains(status);
    }
    return false;
  }

  int _applicableMaxRetries(DioException err) {
    final override = err.requestOptions.extra[RetryPolicy.maxRetriesExtraKey];
    if (override is int) {
      return override;
    }
    return _timeoutTypes.contains(err.type)
        ? policy.timeoutMaxRetries
        : policy.maxRetries;
  }

  int _retryCountOf(RequestOptions options) {
    final value = options.extra[RetryPolicy.retryCountExtraKey];
    return value is int ? value : 0;
  }

  /// Full-jitter exponential backoff, or the response's `Retry-After` for a
  /// 429/503 that carries one. Returns `null` when a `Retry-After` exceeds
  /// [RetryPolicy.maxRetryAfter], meaning the request must not be retried.
  Duration? _computeDelay(DioException err) {
    final status = err.response?.statusCode;
    if (status == 429 || status == 503) {
      final retryAfter = _parseRetryAfter(err.response?.headers);
      if (retryAfter != null) {
        return retryAfter > policy.maxRetryAfter ? null : retryAfter;
      }
    }

    final retryCount = _retryCountOf(err.requestOptions);
    final exponential = policy.baseDelay * pow(2, retryCount);
    final capped = exponential < policy.maxDelay
        ? exponential
        : policy.maxDelay;
    final jitteredMs = (random.nextDouble() * capped.inMilliseconds).round();
    return Duration(milliseconds: jitteredMs);
  }

  Duration? _parseRetryAfter(Headers? headers) {
    final value = headers?.value('retry-after');
    if (value == null) {
      return null;
    }

    final seconds = int.tryParse(value);
    if (seconds != null) {
      return Duration(seconds: seconds < 0 ? 0 : seconds);
    }

    try {
      final target = HttpDate.parse(value);
      final diff = target.difference(DateTime.now().toUtc());
      return diff.isNegative ? Duration.zero : diff;
    } on FormatException {
      return null;
    }
  }

  String _reasonOf(DioException err) => err.response?.statusCode != null
      ? 'HTTP ${err.response!.statusCode}'
      : err.type.name;

  /// Waits for [duration], unless [cancelToken] is cancelled first. Returns
  /// the cancellation [DioException] when that happens (so the caller can
  /// forward it instead of re-dispatching), or `null` when the wait
  /// completed normally.
  Future<DioException?> _waitUnlessCancelled(
    Duration duration,
    CancelToken? cancelToken,
  ) async {
    if (cancelToken == null) {
      await delay(duration);
      return null;
    }
    if (cancelToken.isCancelled) {
      return cancelToken.cancelError;
    }

    final result = await Future.any<Object?>([
      delay(duration).then((_) => null),
      cancelToken.whenCancel,
    ]);
    return result is DioException ? result : null;
  }
}
