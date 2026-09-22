import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';

import 'support/product_fixtures.dart';
import 'support/pump_catalog_app.dart';

// The real cubit marks a page short of `perPage` (30, the state's default)
// as the end, so both pages here carry exactly 30 products: only distinct
// ids decide whether the accumulator sees the second page as new.
const _perPage = 30;

/// Drags the `CustomScrollView` to its very end, matching
/// test/presentation/catalog/pages/catalog_infinite_scroll_test.dart: a drag
/// distance far larger than the scrollable content clamps at
/// `maxScrollExtent` in one gesture and, unlike a programmatic `jumpTo`,
/// goes through the same pointer-driven path a user's scroll does. Because
/// the drag's offset is so large, ballistic scrolling carries the viewport
/// past where page 1 ended and settles at the true end of the now-appended
/// list, so the grid's lazy builder only keeps the tail products mounted —
/// the appended list itself is asserted through the real `CatalogCubit`'s
/// state rather than by finding an early, now-offscreen product's text.
Future<void> _scrollToEnd(WidgetTester tester) async {
  await tester.drag(find.byType(CustomScrollView), const Offset(0, -100000));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'scrolling near the end of the grid appends the next page below the '
    'existing products',
    (tester) async {
      await pumpCatalogApp(
        tester,
        onSearch: (params) async {
          final ids = params.page == 1
              ? idsFrom(0, _perPage)
              : idsFrom(_perPage, _perPage);
          return Result.success(
            ProductSearchResult(
              products: productFixtures(ids),
              page: params.page,
            ),
          );
        },
      );

      await tester.enterText(find.byType(TextField), 'nike');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('Product 0'), findsOneWidget);

      await _scrollToEnd(tester);

      final cubit = BlocProvider.of<CatalogCubit>(
        tester.element(find.byType(CatalogView)),
      );
      expect(cubit.state.products.length, _perPage * 2);
      // The first page's products are still first in the list: appending
      // kept them rather than replacing the list.
      expect(cubit.state.products.first.id, '0');
      expect(cubit.state.products.last.id, '${_perPage * 2 - 1}');
      // The last product of the appended page is visible at the tail the
      // scroll settled on.
      expect(find.text('Product ${_perPage * 2 - 1}'), findsOneWidget);
    },
  );
}
