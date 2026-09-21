import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

void main() {
  group('Product', () {
    test('installmentAmount divides sellingPrice by installmentCount', () {
      const product = Product(
        id: '1',
        name: 'name',
        store: 'store',
        brand: 'brand',
        imageUrl: 'url',
        sellingPrice: 85,
        listPrice: 100,
      );

      expect(Product.installmentCount, 3);
      expect(product.installmentAmount, closeTo(28.333, 0.001));
    });
  });
}
