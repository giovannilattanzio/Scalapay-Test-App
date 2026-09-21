import 'package:scalapay_test_app/src/core/core.dart';

import '../entities/product_search_result.dart';
import '../usecases/product_search_params.dart';

/// Contract for retrieving a page of the catalog. Implemented by the data
/// layer.
abstract class IProductRepository {
  Future<Result<ProductSearchResult>> searchProducts(
    ProductSearchParams params,
  );
}
