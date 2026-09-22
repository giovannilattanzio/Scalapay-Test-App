import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

import 'support/product_fixtures.dart';
import 'support/pump_catalog_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'choosing an ordering in the sort sheet reloads the results in that order',
    (tester) async {
      ProductSort? requestedSort;
      await pumpCatalogApp(
        tester,
        onSearch: (params) async {
          requestedSort = params.sort;
          final ids = params.sort == ProductSort.priceAsc
              ? idsFrom(10, 2)
              : idsFrom(0, 2);
          return Result.success(
            ProductSearchResult(products: productFixtures(ids), page: 1),
          );
        },
      );

      await tester.enterText(find.byType(TextField), 'nike');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('Product 0'), findsOneWidget);

      await tester.tap(find.text('catalog.sort'.tr()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('sort.price_asc'.tr()));
      // The sort sheet's own selection delay before it pops with the choice
      // (see test/presentation/catalog/pages/catalog_bottom_sheets_test.dart).
      await tester.pumpAndSettle(const Duration(milliseconds: 350));

      expect(requestedSort, ProductSort.priceAsc);
      expect(find.text('Product 10'), findsOneWidget);
      expect(find.text('Product 0'), findsNothing);
    },
  );
}
