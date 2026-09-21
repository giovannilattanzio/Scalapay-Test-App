import 'package:catalog_api/catalog_api.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

/// Maps one generated [ProductDocument] onto the domain [Product].
///
/// A straight field-to-field copy: `title`→`name`, `merchant`→`store`,
/// `image`→`imageUrl`, the rest carried across unchanged. Kept as a
/// top-level function, rather than an extension, so [toSearchResult] can
/// wrap each call in its own try/catch below.
Product toEntity(ProductDocument document) => Product(
  id: document.id,
  name: document.title,
  store: document.merchant,
  brand: document.brand,
  imageUrl: document.image,
  sellingPrice: document.sellingPrice,
  listPrice: document.listPrice,
);

/// Flattens `groupedHits[i].hits[j].document` into the domain's flat product
/// list, in order, carrying `page` through untouched. There is no total to
/// carry: the service's `found` field always equals the number of items
/// returned, not the number of matches, so `ProductSearchResult` intentionally
/// exposes only `products` and `page`.
///
/// Each hit is mapped independently inside a try/catch. This guards
/// *mapping* errors only — a bug in [toEntity] itself, or a future domain
/// invariant this function starts enforcing — and is not, and cannot be,
/// a defence against a malformed document: `ProductSearchResponse.fromJson`
/// decodes every document eagerly (`checked: true`), so a document missing
/// a required field already throws before a [ProductSearchResponse] exists
/// to pass in here. That failure is real and is handled one layer up, in
/// the repository, as a `SerializationFailure` for the whole search.
ProductSearchResult toSearchResult(ProductSearchResponse response) {
  final products = <Product>[];
  for (final groupedHit in response.groupedHits) {
    for (final hit in groupedHit.hits) {
      try {
        products.add(toEntity(hit.document));
      } catch (_) {
        // Skip: see the doc comment above.
      }
    }
  }
  return ProductSearchResult(products: products, page: response.page);
}
