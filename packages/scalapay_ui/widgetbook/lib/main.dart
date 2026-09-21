import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'main.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key, this.initialRoute = '/'});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      initialRoute: initialRoute,
      // The theme of the previewed widgets. (`lightTheme` on Widgetbook only
      // styles Widgetbook's own interface, not the use cases.)
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Scalapay', data: ScalapayTheme.light()),
          ],
        ),
      ],
    );
  }
}
