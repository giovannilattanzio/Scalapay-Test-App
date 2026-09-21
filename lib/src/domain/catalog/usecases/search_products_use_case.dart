import 'package:scalapay_test_app/src/core/core.dart';

import '../entities/product_search_result.dart';
import '../repositories/i_product_repository.dart';
import 'product_search_params.dart';

/// Runs a catalog search.
///
/// Pure delegation: it returns the repository's result unchanged and
/// reorders nothing. An earlier draft sorted by product name here; that was
/// removed once the service was measured, because every ordering the app
/// offers is now performed server-side (see `ProductSort`). Reintroducing
/// client-side sorting would silently break as soon as further pages are
/// appended.
class SearchProductsUseCase
    implements UseCase<Result<ProductSearchResult>, ProductSearchParams> {
  const SearchProductsUseCase(this._repository);

  final IProductRepository _repository;

  @override
  Future<Result<ProductSearchResult>> call({
    required ProductSearchParams params,
  }) => _repository.searchProducts(params);
}
