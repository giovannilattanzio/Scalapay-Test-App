import 'package:equatable/equatable.dart';

import '../catalog_defaults.dart';
import '../entities/price_range.dart';
import '../entities/product_sort.dart';

/// Everything needed to run one catalog search.
class ProductSearchParams extends Equatable {
  const ProductSearchParams({
    required this.query,
    this.sort = ProductSort.relevance,
    this.priceRange = PriceRange.none,
    this.languageCode = kDefaultLanguageCode,
    this.page = kDefaultPage,
    this.perPage = kDefaultPerPage,
  });

  final String query;
  final ProductSort sort;
  final PriceRange priceRange;
  final String languageCode;
  final int page;
  final int perPage;

  @override
  List<Object?> get props => [
    query,
    sort,
    priceRange,
    languageCode,
    page,
    perPage,
  ];
}
