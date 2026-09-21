import 'package:equatable/equatable.dart';

import '../catalog_defaults.dart';
import 'product.dart';

/// Accumulates pages of a catalog search into one list and decides when the
/// catalogue is exhausted.
///
/// The service gives no end-of-list signal whatsoever: no total, no short
/// page, no empty page, no error. Measured on four unrelated queries
/// (`nike`, `adidas`, `borraccia`, `profumo`): each has exactly 10 distinct
/// pages at `per_page=30`, and page 11 returns page 1 again, byte-identical
/// (pages 12, 13, 40, 100 and 500 also return page 1, so it clamps rather
/// than wrapping). A page is never short, including the last real one. So
/// "this page brought no product id I have not already seen" is the only
/// end signal available.
///
/// Filtering on the id set rather than comparing the page with page 1 is
/// the point of the design: comparing with page 1 is cheaper but would miss
/// a partial overlap, and a partially overlapping page would render
/// duplicate cards, which a user reads as a bug in the app, not in the
/// service. Deduplication is what protects the UI; the end signal falls out
/// of it for free.
class ProductPageAccumulator extends Equatable {
  const ProductPageAccumulator({
    this.products = const [],
    this.seenIds = const {},
    this.nextPage = kDefaultPage,
    this.hasReachedEnd = false,
  });

  final List<Product> products;
  final Set<String> seenIds;
  final int nextPage;
  final bool hasReachedEnd;

  /// Hard stop, far above the ~10 observed, so the sequence terminates even
  /// against a service that never repeats.
  static const maxPages = 50;

  /// Keeps only the products of [fetched] whose id has not already been
  /// seen. If none is new, the catalogue is exhausted and nothing is
  /// appended; `nextPage` does not advance. Otherwise the new products are
  /// appended (in `fetched` order), their ids recorded, `nextPage`
  /// incremented, and `hasReachedEnd` set when either [fetched] is shorter
  /// than [perPage] (the standard contract, never observed today but it
  /// would work the day the service is fixed) or the new `nextPage` would
  /// exceed [maxPages].
  ProductPageAccumulator append(List<Product> fetched, {required int perPage}) {
    final newProducts = fetched
        .where((product) => !seenIds.contains(product.id))
        .toList(growable: false);

    if (newProducts.isEmpty) {
      return ProductPageAccumulator(
        products: products,
        seenIds: seenIds,
        nextPage: nextPage,
        hasReachedEnd: true,
      );
    }

    final updatedNextPage = nextPage + 1;
    return ProductPageAccumulator(
      products: [...products, ...newProducts],
      seenIds: {...seenIds, ...newProducts.map((product) => product.id)},
      nextPage: updatedNextPage,
      hasReachedEnd: fetched.length < perPage || updatedNextPage > maxPages,
    );
  }

  @override
  List<Object?> get props => [products, seenIds, nextPage, hasReachedEnd];
}
