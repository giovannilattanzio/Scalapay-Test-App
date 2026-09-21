import 'package:equatable/equatable.dart';

/// `field` is the value the service accepts in `sort_by`. Only these two are
/// honoured: every other field name (`title`, `brand`, `merchant`,
/// `list_price`, `id`, ...) is accepted and silently ignored by the service,
/// returning relevance order with no error. That is why this enum cannot
/// express anything else.
enum ProductSortType {
  relevance('_text_match'),
  sellingPrice('selling_price');

  const ProductSortType(this.field);

  final String field;
}

enum SortDirection { asc, desc }

/// The catalog service takes the ordering as `sort_by=<field>:<direction>`,
/// so the domain models the same pair instead of a flat enum. `sheetOptions`
/// offers only the two price combinations because ordering by product name
/// is impossible server-side: offering it would show relevance order under
/// a "Nome A-Z" label. The direction is inert on relevance
/// (`_text_match:asc` equals `_text_match:desc`, measured); the pair is kept
/// uniform anyway.
class ProductSort extends Equatable {
  const ProductSort({required this.type, required this.direction});

  static const relevance = ProductSort(
    type: ProductSortType.relevance,
    direction: SortDirection.desc,
  );
  static const priceAsc = ProductSort(
    type: ProductSortType.sellingPrice,
    direction: SortDirection.asc,
  );
  static const priceDesc = ProductSort(
    type: ProductSortType.sellingPrice,
    direction: SortDirection.desc,
  );

  /// The combinations the sort sheet offers, in order. Relevance is listed
  /// alongside the price options (not omitted like name ordering) so the
  /// default ordering stays reachable after another one has been chosen.
  static const sheetOptions = [relevance, priceAsc, priceDesc];

  final ProductSortType type;
  final SortDirection direction;

  String get queryValue => '${type.field}:${direction.name}';

  @override
  List<Object?> get props => [type, direction];
}
