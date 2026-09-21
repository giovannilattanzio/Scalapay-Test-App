import 'package:equatable/equatable.dart';

import 'product.dart';

/// One page of a catalog search.
///
/// No total: the service's `found` field always equals the number of items
/// returned by the call, so it is not a total and is deliberately not
/// carried into the domain.
class ProductSearchResult extends Equatable {
  const ProductSearchResult({required this.products, required this.page});

  final List<Product> products;
  final int page;

  @override
  List<Object?> get props => [products, page];
}
