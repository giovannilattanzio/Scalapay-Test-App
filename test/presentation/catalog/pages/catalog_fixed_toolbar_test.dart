import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import '../../../helpers/pump_app.dart';

class _MockSearchProductsUseCase extends Mock
    implements SearchProductsUseCase {}

// Enough rows (2 columns) that the grid is well taller than the viewport, so
// scrolling to the end genuinely leaves the first row off screen rather than
// merely nudging it.
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
    when(() => useCase.call(params: any(named: 'params'))).thenAnswer(
      (_) async =>
          Result.success(ProductSearchResult(products: _products(30), page: 1)),
    );
    cubit = CatalogCubit(useCase);
  });

  testWidgets(
    'the Filtri and Ordina chips stay on screen, and stay tappable, once the '
    'first row has scrolled off',
    (tester) async {
      await cubit.search('nike');
      await pumpApp(tester, const CatalogView(), cubit: cubit);

      await _scrollToEnd(tester);

      // The point of this test: the first row is genuinely gone, not merely
      // scrolled a little. A test that scrolled a small amount would still
      // pass with the toolbar inside the scroll view.
      expect(find.text('Product 0'), findsNothing);

      expect(find.text('Filtri'), findsOneWidget);
      expect(find.text('Ordina'), findsOneWidget);

      await tester.tap(find.text('Filtri'));
      await tester.pumpAndSettle();

      expect(find.byType(ScalapayFiltersBottomSheet), findsOneWidget);
    },
  );
}
