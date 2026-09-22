import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/config/router/app_router.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_ui/scalapay_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_product_repository.dart';

/// Resets and rebuilds the real DI graph with [onSearch] standing in for the
/// data layer, then pumps the real app shell — `EasyLocalization` wrapping a
/// `MaterialApp.router` built from the real `createRouter()` — so a test
/// drives the catalog screen exactly as `main.dart` builds it, minus the
/// network call.
///
/// Every integration test calls this instead of repeating the DI
/// reset/override sequence (design.md Decision 3): resetting the whole
/// graph, not just swapping the repository, guarantees no test depends on a
/// `SearchProductsUseCase` singleton another test already resolved against
/// the previous fake — that singleton is only built lazily on the first
/// `CatalogPage` build, which happens fresh in every test's own call to this
/// helper.
Future<void> pumpCatalogApp(
  WidgetTester tester, {
  required Future<Result<ProductSearchResult>> Function(ProductSearchParams)
  onSearch,
}) async {
  await injector.reset();
  await setupInjector();
  injector.unregister<IProductRepository>();
  injector.registerLazySingleton<IProductRepository>(
    () => FakeProductRepository(onSearch: onSearch),
  );

  // Mirrors main.dart's bootstrap; unlike test/helpers/pump_app.dart this
  // does not swap in a file-based asset loader — integration_test runs on a
  // full engine (device/simulator/Chrome), not the headless `flutter_test`
  // binding where the plain `rootBundle` loader was observed to hang.
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('it'), Locale('en')],
      startLocale: const Locale('it'),
      path: 'assets/translations',
      fallbackLocale: const Locale('it'),
      saveLocale: false,
      child: Builder(
        builder: (context) => MaterialApp.router(
          theme: ScalapayTheme.light(),
          locale: context.locale,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          routerConfig: createRouter(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
