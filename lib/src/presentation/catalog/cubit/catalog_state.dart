import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

part 'catalog_state.g.dart';

/// State of the results area as a whole (the first page of a search).
enum CatalogStatus { initial, loading, success, empty, failure }

/// State of appending further pages, independent of [CatalogStatus].
///
/// The catalog service gives no end-of-list signal: past its last page it
/// returns page 1 again, so [ProductPageAccumulator] derives the end from
/// ids it has already seen, and `exhausted` is a normal outcome rather than
/// an error. Meanwhile a network blip while appending must leave the grid
/// on screen. Folding both into one status would force a choice between
/// blanking the screen and hiding the error, so they are tracked apart.
enum LoadMoreStatus { idle, loading, failure, exhausted }

@CopyWith()
class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.query = '',
    this.pages = const ProductPageAccumulator(),
    this.loadMoreStatus = LoadMoreStatus.idle,
    this.sort = ProductSort.relevance,
    this.priceRange = PriceRange.none,
    this.failure,
    this.languageCode = kDefaultLanguageCode,
    this.perPage = kDefaultPerPage,
  });

  final CatalogStatus status;
  final String query;
  final ProductPageAccumulator pages;
  final LoadMoreStatus loadMoreStatus;
  final ProductSort sort;
  final PriceRange priceRange;
  final Failure? failure;
  final String languageCode;
  final int perPage;

  List<Product> get products => pages.products;

  bool get canLoadMore =>
      status == CatalogStatus.success &&
      loadMoreStatus == LoadMoreStatus.idle &&
      !pages.hasReachedEnd;

  @override
  List<Object?> get props => [
    status,
    query,
    pages,
    loadMoreStatus,
    sort,
    priceRange,
    failure,
    languageCode,
    perPage,
  ];
}
