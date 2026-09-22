import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

/// Stands in for the real data layer in the integration suite: only the
/// repository is faked, everything above it (use case, cubit, widget tree)
/// stays real. Each test supplies [onSearch] with whatever logic that
/// journey needs (a fixed response, a page-aware response, a call counter
/// for retry, ...) instead of this class trying to cover every journey with
/// canned fixtures.
class FakeProductRepository implements IProductRepository {
  FakeProductRepository({required this.onSearch});

  final Future<Result<ProductSearchResult>> Function(ProductSearchParams params)
  onSearch;

  @override
  Future<Result<ProductSearchResult>> searchProducts(
    ProductSearchParams params,
  ) => onSearch(params);
}
