import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';

import '../../../helpers/pump_app.dart';

class _MockSearchProductsUseCase extends Mock
    implements SearchProductsUseCase {}

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

/// Drags the `CustomScrollView` to its very end, the same way
/// `catalog_infinite_scroll_test.dart` does: a drag distance far larger than
/// the scrollable content clamps at `maxScrollExtent` in one gesture.
Future<void> _scrollToEnd(WidgetTester tester) async {
  await tester.drag(find.byType(CustomScrollView), const Offset(0, -100000));
  await tester.pump();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const ProductSearchParams(query: 'fallback'));
  });

  late _MockSearchProductsUseCase useCase;
  late CatalogCubit cubit;

  setUp(() {
    useCase = _MockSearchProductsUseCase();
    cubit = CatalogCubit(useCase);
  });

  testWidgets(
    'on a device with a notch and a home indicator, the scroll viewport '
    'reaches the physical bottom, the title still clears the notch, and the '
    'last product row can be scrolled fully above the indicator',
    (tester) async {
      when(() => useCase.call(params: any(named: 'params'))).thenAnswer(
        (_) async => Result.success(
          ProductSearchResult(products: _products(20), page: 1),
        ),
      );
      await cubit.search('nike');

      // FakeViewPadding is in physical pixels: fix the ratio at 1 so the
      // logical insets below match it exactly. Both `padding` and
      // `viewPadding` are set to the same values, as they are on a real
      // device with no keyboard up; only `viewPadding` drives the fix, so
      // setting just `padding` would leave it untested.
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(top: 47, bottom: 34);
      addTearDown(tester.view.reset);

      await pumpApp(
        tester,
        const CatalogView(),
        cubit: cubit,
        surfaceSize: const Size(393, 852),
      );

      // Top inset preserved: the title still lands below the notch's
      // reserved back-arrow slot (47 + 57).
      expect(tester.getTopLeft(find.text('Esplora i prodotti')).dy, 104);

      // The scroll viewport now reaches the physical bottom of the screen,
      // not the old safe bottom (852 - 34 = 818).
      expect(tester.getBottomLeft(find.byType(CustomScrollView)).dy, 852);

      await _scrollToEnd(tester);

      // The last product row must be fully revealed above the home
      // indicator once scrolled into view, not merely reachable behind it.
      final tiles = tester.widgetList(find.byType(CatalogProductTile));
      final lastRowBottom = tiles
          .map((w) => tester.getBottomLeft(find.byWidget(w)).dy)
          .reduce((a, b) => a > b ? a : b);
      expect(lastRowBottom, lessThanOrEqualTo(818));
    },
  );
}
