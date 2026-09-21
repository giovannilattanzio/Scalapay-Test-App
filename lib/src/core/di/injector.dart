import 'package:catalog_api/catalog_api.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:scalapay_test_app/src/data/data.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

/// Global service locator. Always use this instance, never `GetIt.instance`.
final GetIt injector = GetIt.instance;

/// Registers every dependency. Features add their registrations to the
/// dedicated `_register<Feature>` functions below, in dependency order:
/// data sources -> repositories -> use cases -> cubits.
Future<void> setupInjector() async {
  _registerCore();
  _registerCatalog();
}

void _registerCore() {
  // The generated `CatalogApi` only applies `basePath` when it builds its own
  // `Dio` (its `??` fallback); since we inject ours to share transport and
  // timeouts, that branch never runs, so `baseUrl` must be set here. This is
  // safe with exactly one backend; a second API on a different host would
  // need the shared `Dio` split rather than another `baseUrl`.
  injector.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: CatalogApi.basePath,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    ),
  );
}

void _registerCatalog() {
  // Sharing our configured `Dio` is what makes the generated client use the
  // app's transport and timeouts instead of building its own.
  injector.registerLazySingleton<CatalogApi>(
    () => CatalogApi(dio: injector<Dio>()),
  );
  injector.registerLazySingleton<ProductsApi>(
    () => injector<CatalogApi>().getProductsApi(),
  );
  injector.registerLazySingleton<IProductRepository>(
    () => ProductRepositoryImpl(injector<ProductsApi>()),
  );
  injector.registerLazySingleton<SearchProductsUseCase>(
    () => SearchProductsUseCase(injector<IProductRepository>()),
  );
}
