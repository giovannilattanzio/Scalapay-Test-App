import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/data/data.dart';

void main() {
  group('CatalogPartner', () {
    // These three values, together with the host baked into the generated
    // client, identify this app to the catalog service. If any of them
    // drifts silently the app starts hitting `catalog-api.dev.scalapay.com`
    // (which answers 401) or is misidentified by the correct host.
    test('exposes the constant partner identity', () {
      expect(CatalogPartner.partnerId, 'scalapayappit');
      expect(CatalogPartner.source, 'trovaprezzi');
      expect(CatalogPartner.country, 'IT');
    });
  });
}
