import 'package:scalapay_widgetbook/main.directories.g.dart';
import 'package:widgetbook/widgetbook.dart';

/// A use case with the route Widgetbook resolves for it.
///
/// `WidgetbookNode.path` is not a valid route: it has no separator between
/// the folder and the component. The route is `folder/component/use-case`,
/// each segment lowercased with spaces turned into dashes.
typedef UseCaseRoute = ({WidgetbookUseCase useCase, String route});

/// Walks [directories] and returns every use case with its Widgetbook route.
List<UseCaseRoute> useCaseRoutes() {
  final routes = <UseCaseRoute>[];
  String segment(String name) => name.toLowerCase().replaceAll(' ', '-');

  void walk(List<WidgetbookNode> nodes, List<String> parents) {
    for (final node in nodes) {
      if (node is WidgetbookUseCase) {
        routes.add((
          useCase: node,
          route: [...parents, segment(node.name)].join('/'),
        ));
      } else {
        walk(node.children ?? const [], [...parents, segment(node.name)]);
      }
    }
  }

  walk(directories, const []);
  return routes;
}
