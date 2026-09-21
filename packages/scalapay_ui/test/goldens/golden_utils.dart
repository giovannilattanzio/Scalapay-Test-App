import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

/// Loads the bundled Poppins so goldens render the design font instead of the
/// test font. Call once in `setUpAll`.
Future<void> loadPoppins() async {
  final loader = FontLoader('packages/scalapay_ui/Poppins');
  for (final weight in ['Medium', 'SemiBold']) {
    final bytes = File('assets/fonts/Poppins-$weight.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

const _boundaryKey = ValueKey('golden-boundary');

/// Renders [child] with the design system theme on the background color,
/// inside a [width]-wide box with 16px padding, under [locale], and compares
/// it with `images/<name>.png`.
Future<void> expectGolden(
  WidgetTester tester,
  Widget child,
  String name, {
  double width = 343,
  Locale locale = const Locale('en', 'US'),
}) async {
  tester.view.physicalSize = const Size(1200, 1400);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  const colors = ScalapayColors();
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ScalapayTheme.light(),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            key: _boundaryKey,
            child: ColoredBox(
              color: colors.background,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: width,
                  // Loose constraints: components show their intrinsic size.
                  child: Align(
                    alignment: Alignment.centerLeft,
                    heightFactor: 1,
                    child: Builder(
                      builder: (context) => Localizations.override(
                        context: context,
                        locale: locale,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await expectLater(
    find.byKey(_boundaryKey),
    matchesGoldenFile('images/$name.png'),
  );
}
