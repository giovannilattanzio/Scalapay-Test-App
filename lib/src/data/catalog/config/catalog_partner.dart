/// Identity of this app as a caller of the catalog service.
///
/// The base address lives in `openapi/catalog-api.yaml`'s `servers` entry and
/// the query parameter names became typed arguments on the generated
/// `ProductsApi`, so neither is repeated here — only the three values that
/// identify this app and never vary per search. `catalog-api.dev.scalapay.com`
/// answers 401 to the identical request, so these values (and the host baked
/// into the generated client) must not drift silently; see the test for this
/// file.
abstract final class CatalogPartner {
  static const partnerId = 'scalapayappit';
  static const source = 'trovaprezzi';
  static const country = 'IT';
}
