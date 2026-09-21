import 'dart:convert';
import 'dart:io';

import 'package:catalog_api/catalog_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/data/data.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

const _fixturePath = 'test/fixtures/product_search_nike.json';

class MockProductsApi extends Mock implements ProductsApi {}

Response<ProductSearchResponse> _responseWith(ProductSearchResponse data) =>
    Response<ProductSearchResponse>(
      requestOptions: RequestOptions(path: '/v1/products/search'),
      data: data,
      statusCode: 200,
    );

ProductSearchResponse _emptyResponse({int page = 1}) =>
    ProductSearchResponse(page: page, found: 0, groupedHits: const []);

ProductSearchResponse _decodeFixture() {
  final raw = File(_fixturePath).readAsStringSync();
  return ProductSearchResponse.fromJson(
    jsonDecode(raw) as Map<String, dynamic>,
  );
}

/// Runs the real `fromJson` on [json] and returns whatever it throws, so a
/// test can hand that exact exception to a stub instead of fabricating one.
Object _captureFromJsonError(Map<String, dynamic> json) {
  try {
    ProductSearchResponse.fromJson(json);
  } catch (e) {
    return e;
  }
  throw StateError('expected ProductSearchResponse.fromJson to throw');
}

void main() {
  late MockProductsApi api;
  late ProductRepositoryImpl repository;

  setUp(() {
    api = MockProductsApi();
    repository = ProductRepositoryImpl(api);
  });

  void stubApiSuccess(ProductSearchResponse response) {
    when(
      () => api.searchProducts(
        q: any(named: 'q'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        sortBy: any(named: 'sortBy'),
        language: any(named: 'language'),
        minPrice: any(named: 'minPrice'),
        maxPrice: any(named: 'maxPrice'),
        partnerId: any(named: 'partnerId'),
        source_: any(named: 'source_'),
        country: any(named: 'country'),
      ),
    ).thenAnswer((_) async => _responseWith(response));
  }

  group('outgoing arguments', () {
    test('no price filter reaches the api with both bounds null', () async {
      stubApiSuccess(_emptyResponse());

      await repository.searchProducts(const ProductSearchParams(query: 'nike'));

      verify(
        () => api.searchProducts(
          q: 'nike',
          page: 1,
          perPage: 30,
          sortBy: ProductSort.relevance.queryValue,
          language: 'it',
          minPrice: null,
          maxPrice: null,
          partnerId: CatalogPartner.partnerId,
          source_: CatalogPartner.source,
          country: CatalogPartner.country,
        ),
      ).called(1);
    });

    test(
      'a minimum-only price range reaches the api with maxPrice null',
      () async {
        stubApiSuccess(_emptyResponse());

        await repository.searchProducts(
          const ProductSearchParams(
            query: 'nike',
            priceRange: PriceRange(min: 10),
          ),
        );

        verify(
          () => api.searchProducts(
            q: 'nike',
            page: 1,
            perPage: 30,
            sortBy: ProductSort.relevance.queryValue,
            language: 'it',
            minPrice: 10,
            maxPrice: null,
            partnerId: CatalogPartner.partnerId,
            source_: CatalogPartner.source,
            country: CatalogPartner.country,
          ),
        ).called(1);
      },
    );

    test('a full price range reaches the api with both bounds', () async {
      stubApiSuccess(_emptyResponse());

      await repository.searchProducts(
        const ProductSearchParams(
          query: 'nike',
          priceRange: PriceRange(min: 10, max: 50),
        ),
      );

      verify(
        () => api.searchProducts(
          q: 'nike',
          page: 1,
          perPage: 30,
          sortBy: ProductSort.relevance.queryValue,
          language: 'it',
          minPrice: 10,
          maxPrice: 50,
          partnerId: CatalogPartner.partnerId,
          source_: CatalogPartner.source,
          country: CatalogPartner.country,
        ),
      ).called(1);
    });

    test('an English languageCode reaches the api unchanged', () async {
      stubApiSuccess(_emptyResponse());

      await repository.searchProducts(
        const ProductSearchParams(query: 'nike', languageCode: 'en'),
      );

      verify(
        () => api.searchProducts(
          q: 'nike',
          page: 1,
          perPage: 30,
          sortBy: ProductSort.relevance.queryValue,
          language: 'en',
          minPrice: null,
          maxPrice: null,
          partnerId: CatalogPartner.partnerId,
          source_: CatalogPartner.source,
          country: CatalogPartner.country,
        ),
      ).called(1);
    });

    test('a non-default page and perPage reach the api unchanged', () async {
      stubApiSuccess(_emptyResponse(page: 3));

      await repository.searchProducts(
        const ProductSearchParams(query: 'nike', page: 3, perPage: 10),
      );

      verify(
        () => api.searchProducts(
          q: 'nike',
          page: 3,
          perPage: 10,
          sortBy: ProductSort.relevance.queryValue,
          language: 'it',
          minPrice: null,
          maxPrice: null,
          partnerId: CatalogPartner.partnerId,
          source_: CatalogPartner.source,
          country: CatalogPartner.country,
        ),
      ).called(1);
    });

    for (final entry in {
      ProductSort.relevance: '_text_match:desc',
      ProductSort.priceAsc: 'selling_price:asc',
      ProductSort.priceDesc: 'selling_price:desc',
    }.entries) {
      test(
        'sort ${entry.key.queryValue} arrives as sortBy "${entry.value}"',
        () async {
          stubApiSuccess(_emptyResponse());

          await repository.searchProducts(
            ProductSearchParams(query: 'nike', sort: entry.key),
          );

          verify(
            () => api.searchProducts(
              q: 'nike',
              page: 1,
              perPage: 30,
              sortBy: entry.value,
              language: 'it',
              minPrice: null,
              maxPrice: null,
              partnerId: CatalogPartner.partnerId,
              source_: CatalogPartner.source,
              country: CatalogPartner.country,
            ),
          ).called(1);
        },
      );
    }
  });

  group('success mapping', () {
    test('maps the captured fixture into a successful result', () async {
      stubApiSuccess(_decodeFixture());

      final result = await repository.searchProducts(
        const ProductSearchParams(query: 'nike'),
      );

      expect(result.isSuccess, isTrue);
      expect(result.ok!.products, hasLength(6));
      expect(result.ok!.products.map((p) => p.sellingPrice).toList(), [
        6.0,
        8.0,
        8.0,
        3.4,
        3.7,
        3.7,
      ]);
    });

    test('an empty result is a success with an empty product list', () async {
      stubApiSuccess(_emptyResponse());

      final result = await repository.searchProducts(
        const ProductSearchParams(query: 'zzzznoresults'),
      );

      expect(result.isSuccess, isTrue);
      expect(result.ok!.products, isEmpty);
    });
  });

  group('failure mapping', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ]) {
      test('$type maps to NetworkFailure', () async {
        when(
          () => api.searchProducts(
            q: any(named: 'q'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
            sortBy: any(named: 'sortBy'),
            language: any(named: 'language'),
            minPrice: any(named: 'minPrice'),
            maxPrice: any(named: 'maxPrice'),
            partnerId: any(named: 'partnerId'),
            source_: any(named: 'source_'),
            country: any(named: 'country'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/v1/products/search'),
            type: type,
          ),
        );

        final result = await repository.searchProducts(
          const ProductSearchParams(query: 'nike'),
        );

        expect(result.isError, isTrue);
        expect(result.failure, isA<NetworkFailure>());
      });
    }

    test('a DioException carrying a response status maps to ServerFailure with that code', () async {
      when(
        () => api.searchProducts(
          q: any(named: 'q'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          sortBy: any(named: 'sortBy'),
          language: any(named: 'language'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          partnerId: any(named: 'partnerId'),
          source_: any(named: 'source_'),
          country: any(named: 'country'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/v1/products/search'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/v1/products/search'),
            statusCode: 500,
          ),
        ),
      );

      final result = await repository.searchProducts(
        const ProductSearchParams(query: 'nike'),
      );

      expect(result.isError, isTrue);
      expect(result.failure, isA<ServerFailure>());
      expect(result.failure!.code, 500);
    });

    test('a malformed payload maps to SerializationFailure', () async {
      // The generated client returns a null body (rather than throwing)
      // when the response cannot be deserialized into the declared type;
      // the repository's own null-check then surfaces as a TypeError.
      when(
        () => api.searchProducts(
          q: any(named: 'q'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          sortBy: any(named: 'sortBy'),
          language: any(named: 'language'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          partnerId: any(named: 'partnerId'),
          source_: any(named: 'source_'),
          country: any(named: 'country'),
        ),
      ).thenAnswer(
        (_) async => Response<ProductSearchResponse>(
          requestOptions: RequestOptions(path: '/v1/products/search'),
          data: null,
          statusCode: 200,
        ),
      );

      final result = await repository.searchProducts(
        const ProductSearchParams(query: 'nike'),
      );

      expect(result.isError, isTrue);
      expect(result.failure, isA<SerializationFailure>());
    });

    test('a document missing a required field fails to parse, and surfaces as '
        'SerializationFailure with no products', () async {
      // The real path: ProductSearchResponse.fromJson decodes every
      // document eagerly, so a document missing a required field never
      // becomes a ProductSearchResponse — it throws first. This is the
      // exception the mapper's per-hit try/catch cannot help with (see
      // its doc comment): by the time the mapper would run, parsing has
      // already failed for the whole response.
      final raw = File(_fixturePath).readAsStringSync();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final firstDocument =
          ((json['grouped_hits'] as List)
                          .cast<Map<String, dynamic>>()
                          .first['hits']
                      as List)
                  .cast<Map<String, dynamic>>()
                  .first['document']
              as Map<String, dynamic>;
      firstDocument.remove('title');

      expect(() => ProductSearchResponse.fromJson(json), throwsA(anything));

      when(
        () => api.searchProducts(
          q: any(named: 'q'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          sortBy: any(named: 'sortBy'),
          language: any(named: 'language'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          partnerId: any(named: 'partnerId'),
          source_: any(named: 'source_'),
          country: any(named: 'country'),
        ),
      ).thenThrow(_captureFromJsonError(json));

      final result = await repository.searchProducts(
        const ProductSearchParams(query: 'nike'),
      );

      expect(result.isError, isTrue);
      expect(result.failure, isA<SerializationFailure>());
      expect(result.ok, isNull);
    });

    test('an arbitrary thrown object still comes back as a Result with UnknownFailure', () async {
      when(
        () => api.searchProducts(
          q: any(named: 'q'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          sortBy: any(named: 'sortBy'),
          language: any(named: 'language'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          partnerId: any(named: 'partnerId'),
          source_: any(named: 'source_'),
          country: any(named: 'country'),
        ),
      ).thenThrow(Object());

      final result = await repository.searchProducts(
        const ProductSearchParams(query: 'nike'),
      );

      expect(result.isError, isTrue);
      expect(result.failure, isA<UnknownFailure>());
    });
  });
}
