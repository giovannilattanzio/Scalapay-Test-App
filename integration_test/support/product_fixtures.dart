import 'package:scalapay_test_app/src/domain/domain.dart';

/// Builds one [Product] per id, with otherwise-fixed content: the journey
/// tests only ever assert on names/ids, never on price or image rendering
/// (already covered by widget and golden tests).
List<Product> productFixtures(Iterable<String> ids) => [
  for (final id in ids)
    Product(
      id: id,
      name: 'Product $id',
      store: 'Store',
      brand: 'Brand',
      imageUrl: 'https://invalid.invalid/$id.png',
      sellingPrice: 10,
      listPrice: 20,
    ),
];

/// `count` consecutive ids starting at `start`, as strings — matches
/// `Product.id`'s type.
List<String> idsFrom(int start, int count) =>
    List.generate(count, (i) => '${start + i}');
