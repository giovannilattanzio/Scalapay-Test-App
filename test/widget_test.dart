import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'helpers/pump_app.dart';

class _MockSearchProductsUseCase extends Mock
    implements SearchProductsUseCase {}

void main() {
  setUp(() {
    // A mocked SearchProductsUseCase keeps this boot test offline: the real
    // Dio/CatalogApi/repository chain is never registered, so nothing here
    // can reach the network. CatalogPage builds its own CatalogCubit from
    // this use case rather than resolving the cubit itself, per the DI rule
    // for single-page, single-dependency cubits.
    injector.registerLazySingleton<SearchProductsUseCase>(
      _MockSearchProductsUseCase.new,
    );
  });

  tearDown(() async {
    await injector.reset();
  });

  testWidgets('the app boots to the catalog screen', (tester) async {
    await pumpApp(tester, const CatalogPage());

    expect(find.text('Esplora i prodotti'), findsOneWidget);
    expect(find.byType(ScalapaySearchField), findsOneWidget);
  });
}
