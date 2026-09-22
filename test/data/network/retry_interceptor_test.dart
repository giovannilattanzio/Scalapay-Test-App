import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:catalog_api/catalog_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/data/data.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

/// One scripted outcome for one call of [_ScriptedAdapter.fetch].
typedef _Step = FutureOr<ResponseBody> Function(RequestOptions options);

/// Fully offline, scriptable [HttpClientAdapter]: every call consumes the
/// next [_Step] (the last one repeats once the list is exhausted, so a
/// "fails forever" script only needs one entry), and records how many times
/// and with what [RequestOptions] it was hit. No adapter in this file ever
/// opens a socket, following `test/core/di/injector_test.dart`'s pattern.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._steps);

  final List<_Step> _steps;
  int callCount = 0;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final index = callCount < _steps.length ? callCount : _steps.length - 1;
    callCount++;
    return _steps[index](options);
  }

  @override
  void close({bool force = false}) {}
}

/// Records every [Duration] it was asked to wait for, without ever actually
/// waiting, so tests stay fast and deterministic.
class _RecordingDelay {
  final List<Duration> durations = [];

  Future<void> call(Duration duration) async {
    durations.add(duration);
  }
}

/// A [Random] that always returns the same jitter, so the delay the
/// interceptor computes is exactly the backoff cap for a given attempt.
class _FixedRandom implements Random {
  _FixedRandom(this.value);

  final double value;

  @override
  double nextDouble() => value;

  @override
  bool nextBool() => false;

  @override
  int nextInt(int max) => 0;
}

_Step _throwing(DioExceptionType type) =>
    (options) => throw DioException(requestOptions: options, type: type);

ResponseBody _okBody(RequestOptions options) => ResponseBody.fromString(
  '{}',
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

_Step _statusBody(int status, {Map<String, List<String>>? headers}) =>
    (options) => ResponseBody.fromString('', status, headers: headers ?? {});

Dio _dioWith(
  HttpClientAdapter adapter, {
  RetryPolicy policy = const RetryPolicy(),
  Future<void> Function(Duration duration)? delay,
  Random? random,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter;
  dio.interceptors.add(
    RetryInterceptor(
      dio,
      policy: policy,
      delay: delay ?? (_) async {},
      random: random,
    ),
  );
  return dio;
}

Matcher _dioExceptionOfType(DioExceptionType type) =>
    isA<DioException>().having((e) => e.type, 'type', type);

Matcher _dioExceptionWithStatus(int status) => isA<DioException>().having(
  (e) => e.response?.statusCode,
  'response.statusCode',
  status,
);

void main() {
  group('retries on transient errors (spec: Transient failures are retried '
      'transparently)', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ]) {
      test('$type on a GET is retried and the retry succeeds', () async {
        final adapter = _ScriptedAdapter([_throwing(type), _okBody]);
        final dio = _dioWith(adapter);

        final response = await dio.get<dynamic>('/x');

        expect(response.statusCode, 200);
        expect(adapter.callCount, 2);
      });
    }

    for (final status in [408, 429, 502, 503, 504]) {
      test('HTTP $status on a GET is retried and the retry succeeds', () async {
        final adapter = _ScriptedAdapter([_statusBody(status), _okBody]);
        final dio = _dioWith(adapter);

        final response = await dio.get<dynamic>('/x');

        expect(response.statusCode, 200);
        expect(adapter.callCount, 2);
      });
    }
  });

  group('never retries (spec: Transient failures are retried transparently, '
      'client/server error scenarios)', () {
    for (final status in [400, 404, 422]) {
      test('HTTP $status is never retried', () async {
        final adapter = _ScriptedAdapter([_statusBody(status)]);
        final dio = _dioWith(adapter);

        await expectLater(
          dio.get<dynamic>('/x'),
          throwsA(_dioExceptionWithStatus(status)),
        );
        expect(adapter.callCount, 1);
      });
    }

    test('HTTP 500 is never retried', () async {
      final adapter = _ScriptedAdapter([_statusBody(500)]);
      final dio = _dioWith(adapter);

      await expectLater(
        dio.get<dynamic>('/x'),
        throwsA(_dioExceptionWithStatus(500)),
      );
      expect(adapter.callCount, 1);
    });

    test('a cancelled request is never retried', () async {
      final adapter = _ScriptedAdapter([_throwing(DioExceptionType.cancel)]);
      final dio = _dioWith(adapter);

      await expectLater(
        dio.get<dynamic>('/x'),
        throwsA(_dioExceptionOfType(DioExceptionType.cancel)),
      );
      expect(adapter.callCount, 1);
    });

    test('cancelling while waiting to retry stops it and reports the '
        'cancellation', () async {
      final adapter = _ScriptedAdapter([
        _throwing(DioExceptionType.connectionError),
      ]);
      final cancelToken = CancelToken();
      final neverCompletes = Completer<void>();
      final dio = _dioWith(
        adapter,
        delay: (_) {
          // Cancels as a side effect of the wait starting, so the race
          // inside the interceptor deterministically picks the
          // cancellation over this (otherwise never-completing) delay.
          cancelToken.cancel('stop');
          return neverCompletes.future;
        },
      );

      final future = dio.get<dynamic>('/x', cancelToken: cancelToken);

      await expectLater(
        future,
        throwsA(_dioExceptionOfType(DioExceptionType.cancel)),
      );
      // Only the first attempt was ever sent: the wait was interrupted
      // before a second dispatch could happen.
      expect(adapter.callCount, 1);
    });

    test('a bad certificate is never retried', () async {
      final adapter = _ScriptedAdapter([
        _throwing(DioExceptionType.badCertificate),
      ]);
      final dio = _dioWith(adapter);

      await expectLater(
        dio.get<dynamic>('/x'),
        throwsA(_dioExceptionOfType(DioExceptionType.badCertificate)),
      );
      expect(adapter.callCount, 1);
    });

    test('a POST that times out is not retried without opting in', () async {
      final adapter = _ScriptedAdapter([
        _throwing(DioExceptionType.receiveTimeout),
      ]);
      final dio = _dioWith(adapter);

      await expectLater(
        dio.post<dynamic>('/x'),
        throwsA(_dioExceptionOfType(DioExceptionType.receiveTimeout)),
      );
      expect(adapter.callCount, 1);
    });
  });

  group('retries are bounded (spec: Retries are bounded and spaced out)', () {
    test('a non-timeout retryable error stops after 3 attempts', () async {
      final adapter = _ScriptedAdapter([_statusBody(503)]);
      final dio = _dioWith(adapter);

      await expectLater(
        dio.get<dynamic>('/x'),
        throwsA(_dioExceptionWithStatus(503)),
      );
      expect(adapter.callCount, 3);
    });

    test('a timeout stops after 2 attempts', () async {
      final adapter = _ScriptedAdapter([
        _throwing(DioExceptionType.receiveTimeout),
      ]);
      final dio = _dioWith(adapter);

      await expectLater(
        dio.get<dynamic>('/x'),
        throwsA(_dioExceptionOfType(DioExceptionType.receiveTimeout)),
      );
      expect(adapter.callCount, 2);
    });

    test(
      'recovery on the 2nd attempt returns the response and stops there',
      () async {
        final adapter = _ScriptedAdapter([_statusBody(503), _okBody]);
        final dio = _dioWith(adapter);

        final response = await dio.get<dynamic>('/x');

        expect(response.statusCode, 200);
        expect(adapter.callCount, 2);
      },
    );
  });

  group('per-request overrides (spec: Retry behaviour can be set per '
      'request)', () {
    test(
      'retry: false disables retry on an otherwise-idempotent GET',
      () async {
        final adapter = _ScriptedAdapter([_statusBody(503)]);
        final dio = _dioWith(adapter);

        await expectLater(
          dio.get<dynamic>(
            '/x',
            options: Options(extra: {RetryPolicy.retryExtraKey: false}),
          ),
          throwsA(_dioExceptionWithStatus(503)),
        );
        expect(adapter.callCount, 1);
      },
    );

    test('retry: true enables retry on a non-idempotent POST', () async {
      final adapter = _ScriptedAdapter([_statusBody(503), _okBody]);
      final dio = _dioWith(adapter);

      final response = await dio.post<dynamic>(
        '/x',
        options: Options(extra: {RetryPolicy.retryExtraKey: true}),
      );

      expect(response.statusCode, 200);
      expect(adapter.callCount, 2);
    });

    test('maxRetries overrides the default budget for one request', () async {
      final adapter = _ScriptedAdapter([_statusBody(503)]);
      final dio = _dioWith(adapter);

      await expectLater(
        dio.get<dynamic>(
          '/x',
          options: Options(extra: {RetryPolicy.maxRetriesExtraKey: 0}),
        ),
        throwsA(_dioExceptionWithStatus(503)),
      );
      // maxRetries: 0 means the first failure is already final.
      expect(adapter.callCount, 1);
    });
  });

  group('delays (spec: Retries are bounded and spaced out)', () {
    test('recorded delays are non-decreasing in upper bound and never '
        'exceed 4s', () async {
      final adapter = _ScriptedAdapter([_statusBody(503)]);
      final recordingDelay = _RecordingDelay();
      final dio = _dioWith(
        adapter,
        delay: recordingDelay.call,
        random: _FixedRandom(1),
      );

      await expectLater(
        dio.get<dynamic>('/x'),
        throwsA(_dioExceptionWithStatus(503)),
      );

      expect(recordingDelay.durations, [
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 1000),
      ]);
      for (final duration in recordingDelay.durations) {
        expect(duration.inMilliseconds, lessThanOrEqualTo(4000));
      }
    });

    test('a 429 with Retry-After: 2 is retried after exactly 2s, not the '
        'computed backoff', () async {
      final adapter = _ScriptedAdapter([
        _statusBody(
          429,
          headers: {
            'retry-after': const ['2'],
          },
        ),
        _okBody,
      ]);
      final recordingDelay = _RecordingDelay();
      final dio = _dioWith(adapter, delay: recordingDelay.call);

      final response = await dio.get<dynamic>('/x');

      expect(response.statusCode, 200);
      expect(recordingDelay.durations, [const Duration(seconds: 2)]);
    });

    test('a 503 with Retry-After: 60 is never retried', () async {
      final adapter = _ScriptedAdapter([
        _statusBody(
          503,
          headers: {
            'retry-after': const ['60'],
          },
        ),
      ]);
      final dio = _dioWith(adapter);

      await expectLater(
        dio.get<dynamic>('/x'),
        throwsA(_dioExceptionWithStatus(503)),
      );
      expect(adapter.callCount, 1);
    });
  });

  group('exhausted retries surface as the existing typed failures (spec: '
      'Exhausted retries surface as the existing typed failures)', () {
    ProductsApi buildProductsApi(HttpClientAdapter adapter) {
      final dio = _dioWith(adapter);
      return CatalogApi(dio: dio).getProductsApi();
    }

    test('a persistent timeout surfaces through ProductRepositoryImpl as a '
        'NetworkFailure, after the interceptor exhausts its retries', () async {
      final adapter = _ScriptedAdapter([
        _throwing(DioExceptionType.receiveTimeout),
      ]);
      final repository = ProductRepositoryImpl(buildProductsApi(adapter));

      final result = await repository.searchProducts(
        const ProductSearchParams(query: 'nike'),
      );

      expect(result.isError, isTrue);
      expect(result.failure, isA<NetworkFailure>());
      // 1 initial attempt + 1 retry (timeoutMaxRetries), no 3rd.
      expect(adapter.callCount, 2);
    });

    test(
      'a persistent 503 surfaces through ProductRepositoryImpl as a '
      'ServerFailure(503), after the interceptor exhausts its retries',
      () async {
        final adapter = _ScriptedAdapter([_statusBody(503)]);
        final repository = ProductRepositoryImpl(buildProductsApi(adapter));

        final result = await repository.searchProducts(
          const ProductSearchParams(query: 'nike'),
        );

        expect(result.isError, isTrue);
        expect(result.failure, isA<ServerFailure>());
        expect(result.failure!.code, 503);
        // 1 initial attempt + 2 retries (maxRetries), no 4th.
        expect(adapter.callCount, 3);
      },
    );

    test('recovery mid-way: a timeout on the 1st attempt and success on the '
        '2nd returns products and no failure', () async {
      final adapter = _ScriptedAdapter([
        _throwing(DioExceptionType.receiveTimeout),
        (options) => ResponseBody.fromString(
          '{"page":1,"found":0,"grouped_hits":[]}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      ]);
      final repository = ProductRepositoryImpl(buildProductsApi(adapter));

      final result = await repository.searchProducts(
        const ProductSearchParams(query: 'nike'),
      );

      expect(result.isSuccess, isTrue);
      expect(result.ok!.products, isEmpty);
      expect(adapter.callCount, 2);
    });
  });
}
