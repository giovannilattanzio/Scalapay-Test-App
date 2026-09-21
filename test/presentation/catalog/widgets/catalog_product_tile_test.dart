import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import '../../../helpers/pump_app.dart';

Product _product({String imageUrl = 'https://example.com/shoe.png'}) => Product(
  id: '1',
  name: 'Air something',
  store: 'Nike Store',
  brand: 'Nike',
  imageUrl: imageUrl,
  sellingPrice: 85,
  listPrice: 100,
);

void main() {
  testWidgets('shows a neutral placeholder while a network image is loading '
      'or fails', (tester) async {
    await pumpApp(
      tester,
      CatalogProductTile(
        product: _product(imageUrl: 'https://invalid.invalid/x.png'),
      ),
    );

    // The test binding has no real network access, so the image errors and
    // the error placeholder takes over rather than a broken-image icon.
    expect(find.byType(CatalogImagePlaceholder), findsOneWidget);
    expect(find.byIcon(Icons.broken_image), findsNothing);
  });

  testWidgets('feeds the product data and 3 fixed instalments to the card', (
    tester,
  ) async {
    final product = _product();
    await pumpApp(tester, CatalogProductTile(product: product));

    final card = tester.widget<ScalapayProductCard>(
      find.byType(ScalapayProductCard),
    );
    expect(card.name, product.name);
    expect(card.store, product.store);
    expect(card.price, product.sellingPrice);
    expect(card.installmentCount, Product.installmentCount);
    expect(card.installmentAmount, product.installmentAmount);
  });
}
