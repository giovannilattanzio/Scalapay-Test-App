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

  testWidgets(
    'decodes the network image at the physical width of its display area',
    (tester) async {
      await pumpApp(
        tester,
        CatalogProductTile(product: _product()),
        devicePixelRatio: 3,
      );

      // The image area's width is whatever constraint `Center` passes down
      // to `LayoutBuilder`, not the (shrink-wrapped) `LayoutBuilder`'s own
      // size, so it is measured from the nearest `Center` ancestor.
      final layoutBuilderFinder = find
          .descendant(
            of: find.byType(CatalogProductTile),
            matching: find.byType(LayoutBuilder),
          )
          .first;
      final centerFinder = find
          .ancestor(of: layoutBuilderFinder, matching: find.byType(Center))
          .first;
      final areaWidth = tester.getSize(centerFinder).width;
      expect(areaWidth, greaterThan(0));

      final image = tester.widget<Image>(find.byType(Image));
      final resizeImage = image.image as ResizeImage;
      expect(resizeImage.width, (areaWidth * 3).round());
    },
  );
}
