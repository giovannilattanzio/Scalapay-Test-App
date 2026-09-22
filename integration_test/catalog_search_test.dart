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
    'shows the initial prompt, then the products for a submitted search',
    (tester) async {
      ProductSearchParams? requested;
      await pumpCatalogApp(
        tester,
        onSearch: (params) async {
          requested = params;
          return Result.success(
            ProductSearchResult(
              products: productFixtures(idsFrom(0, 2)),
              page: 1,
            ),
          );
        },
      );

      expect(find.text('catalog.initial'.tr()), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'nike');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(requested?.query, 'nike');
      expect(find.text('Product 0'), findsOneWidget);
      expect(find.text('Product 1'), findsOneWidget);
    },
  );
}
