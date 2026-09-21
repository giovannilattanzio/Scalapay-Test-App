import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';

import '../../../helpers/pump_app.dart';

List<Product> _products(int count) => List.generate(
  count,
  (i) => Product(
    id: '$i',
    name: 'Product $i',
    store: 'Store',
    brand: 'Brand',
    imageUrl: 'https://invalid.invalid/$i.png',
    sellingPrice: 10 + i.toDouble(),
    listPrice: 20 + i.toDouble(),
  ),
);

Widget _grid(List<Product> products) =>
    CustomScrollView(slivers: [CatalogProductGrid(products: products)]);

/// Number of tiles sharing the top-most `dy`, i.e. the columns in the first
/// row (grid layout is row-major, so they are the first N tiles found).
int _firstRowColumnCount(WidgetTester tester) {
  final tiles = tester.widgetList(find.byType(CatalogProductTile)).toList();
  final positions = tiles
      .map((w) => tester.getTopLeft(find.byWidget(w)).dy)
      .toList();
  final firstRowDy = positions.first;
  return positions.where((dy) => dy == firstRowDy).length;
}

void main() {
  testWidgets('lays out exactly two columns at 375 width', (tester) async {
    await pumpApp(
      tester,
      _grid(_products(6)),
      surfaceSize: const Size(375, 812),
    );
    expect(_firstRowColumnCount(tester), 2);
  });

  testWidgets('lays out more than two columns on a wide (900) viewport', (
    tester,
  ) async {
    await pumpApp(
      tester,
      _grid(_products(12)),
      surfaceSize: const Size(900, 812),
    );
    expect(_firstRowColumnCount(tester), greaterThan(2));
  });

  testWidgets('does not overflow at 320 width', (tester) async {
    await pumpApp(
      tester,
      _grid(_products(6)),
      surfaceSize: const Size(320, 812),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow at a 1.5x text scale', (tester) async {
    await pumpApp(
      tester,
      _grid(_products(6)),
      surfaceSize: const Size(375, 812),
      textScaleFactor: 1.5,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a placeholder tile when its image fails to load', (
    tester,
  ) async {
    await pumpApp(tester, _grid(_products(2)));
    expect(find.byType(CatalogImagePlaceholder), findsNWidgets(2));
  });
}
