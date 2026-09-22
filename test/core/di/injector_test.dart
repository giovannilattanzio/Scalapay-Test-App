import 'dart:async';
import 'dart:typed_data';

import 'package:catalog_api/catalog_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/data/data.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

/// Fails every request with the given [DioExceptionType], entirely offline:
/// no `HttpClientAdapter` in this test ever opens a socket.
class _ThrowingAdapter implements HttpClientAdapter {
  _ThrowingAdapter(this.type);

  final DioExceptionType type;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw DioException(requestOptions: options, type: type);
  }

  @override
  void close({bool force = false}) {}
}

/// Records the [Uri] of every request it sees, then fails it, entirely
/// offline: no `HttpClientAdapter` in this test ever opens a socket.
class _RecordingAdapter implements HttpClientAdapter {
  final List<Uri> requestedUris = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requestedUris.add(options.uri);
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUp(() async {
    await injector.reset();
  });

  tearDown(() async {
    await injector.reset();
  });

  group('setupInjector', () {
    test('the generated CatalogApi reuses the same Dio instance registered '
        'in core, carrying its timeouts', () async {
      await setupInjector();

      final dio = injector<Dio>();
      final catalogApi = injector<CatalogApi>();

      expect(identical(catalogApi.dio, dio), isTrue);
      expect(dio.options.connectTimeout, const Duration(seconds: 15));
      expect(dio.options.receiveTimeout, const Duration(seconds: 15));
      expect(dio.interceptors.whereType<RetryInterceptor>(), hasLength(1));
    });

    test('ProductsApi resolves from the registered CatalogApi', () async {
      await setupInjector();

      // ProductsApi keeps the Dio it was built with private, so sharing is
      // verified end to end below (the receive-timeout test) rather than by
      // reaching into that field here.
      expect(injector<ProductsApi>(), isA<ProductsApi>());
    });

    test('IProductRepository resolves to a ProductRepositoryImpl', () async {
      await setupInjector();

      expect(injector<IProductRepository>(), isA<ProductRepositoryImpl>());
    });

    test(
      'two reads of SearchProductsUseCase return the same instance',
      () async {
        await setupInjector();

        expect(
          identical(
            injector<SearchProductsUseCase>(),
            injector<SearchProductsUseCase>(),
          ),
          isTrue,
        );
      },
    );

    test(
      'a receive timeout surfaces through the whole graph as a NetworkFailure',
      () async {
        await setupInjector();
        injector<Dio>().httpClientAdapter = _ThrowingAdapter(
          DioExceptionType.receiveTimeout,
        );

        final result = await injector<IProductRepository>().searchProducts(
          const ProductSearchParams(query: 'nike'),
        );

        expect(result.isError, isTrue);
        expect(result.failure, isA<NetworkFailure>());
      },
    );

    test(
      'a search sends an absolute request against CatalogApi.basePath',
      () async {
        await setupInjector();
        final recordingAdapter = _RecordingAdapter();
        injector<Dio>().httpClientAdapter = recordingAdapter;

        await injector<IProductRepository>().searchProducts(
          const ProductSearchParams(query: 'nike'),
        );

        // The adapter always fails with a connectionError, which
        // RetryInterceptor retries against the same `Dio`, so more than one
        // identical request is expected here; every one of them must still
        // be the same absolute URL.
        expect(recordingAdapter.requestedUris, isNotEmpty);
        for (final uri in recordingAdapter.requestedUris) {
          expect(uri.hasScheme, isTrue);
          expect(uri.host, isNotEmpty);
          expect(uri.toString(), startsWith(CatalogApi.basePath));
          expect(uri.path, '/v1/products/search');
        }
      },
    );
  });
}
