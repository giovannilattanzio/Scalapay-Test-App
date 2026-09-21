import 'package:go_router/go_router.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';

/// Route paths, one constant per screen: `context.go(AppRoutes.<name>)`.
abstract class AppRoutes {
  static const catalog = '/';
}

/// Built once and held here rather than inside `build`: recreating a
/// `GoRouter` on every frame would reset navigation state.
final GoRouter _router = GoRouter(routes: routes);

/// Builds the app router. Feature routes are added to [routes] by the
/// infrastructure agent:
/// `GoRoute(path: AppRoutes.<name>, builder: (context, state) => const <Feature>Page())`.
GoRouter createRouter() => _router;

final List<RouteBase> routes = [
  GoRoute(
    path: AppRoutes.catalog,
    builder: (context, state) => const CatalogPage(),
  ),
];
