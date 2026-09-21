import 'package:catalog_api/catalog_api.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

import '../config/catalog_partner.dart';
import '../mappers/product_mapper.dart';

/// Implements [IProductRepository] on top of the generated [ProductsApi].
///
/// There is no hand-written remote data source interface for this feature:
/// [ProductsApi] already IS the remote data source (generated from
/// `openapi/catalog-api.yaml`), and wrapping it in another interface written
/// only to be mocked would add a layer with nothing to abstract — `mocktail`
/// mocks the concrete generated class directly in tests.
class ProductRepositoryImpl implements IProductRepository {
  const ProductRepositoryImpl(this._api);

  final ProductsApi _api;

  @override
  Future<Result<ProductSearchResult>> searchProducts(
    ProductSearchParams params,
  ) async {
    try {
      final response = await _api.searchProducts(
        q: params.query,
        page: params.page,
        perPage: params.perPage,
        sortBy: params.sort.queryValue,
        language: params.languageCode,
        minPrice: params.priceRange.min,
        maxPrice: params.priceRange.max,
        partnerId: CatalogPartner.partnerId,
        source_: CatalogPartner.source,
        country: CatalogPartner.country,
      );
      return Result.success(toSearchResult(response.data!));
    } on DioException catch (e) {
      return Result.error(_mapDioException(e));
    } on FormatException catch (e) {
      return Result.error(SerializationFailure(message: e.message));
    } on TypeError catch (e) {
      return Result.error(SerializationFailure(message: e.toString()));
    } on CheckedFromJsonException catch (e) {
      return Result.error(SerializationFailure(message: e.toString()));
    } catch (e) {
      return Result.error(UnknownFailure(message: e.toString()));
    }
  }

  Failure _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkFailure(message: e.message ?? 'Network error');
      default:
        final statusCode = e.response?.statusCode;
        if (statusCode != null) {
          return ServerFailure(
            message: e.message ?? 'Server error',
            code: statusCode,
          );
        }
        return UnknownFailure(message: e.message ?? e.toString());
    }
  }
}
