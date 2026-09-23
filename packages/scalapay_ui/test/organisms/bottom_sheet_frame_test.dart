import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';
// The frame is internal, so it is imported from src.
import 'package:scalapay_ui/src/organisms/internal/bottom_sheet_frame.dart';

Widget _host(Widget child, {double width = 375}) => MaterialApp(
  theme: ScalapayTheme.light(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

Widget _italianHost(Widget child, {double width = 375}) => MaterialApp(
  theme: ScalapayTheme.light(),
  locale: const Locale('it'),
  supportedLocales: const [Locale('it'), Locale('en')],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

const _body = SizedBox(key: ValueKey('body'), height: 100);

void main() {
  const colors = ScalapayColors();

  testWidgets('shows the handle, the centered title and the close button', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const BottomSheetFrame(title: 'Filtri', child: _body)),
    );
    expect(find.text('Filtri'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 45 && w.height == 5,
      ),
      findsOneWidget,
    );
    expect(find.byType(ScalapayIcon), findsOneWidget);
    expect(
      tester.widget<ScalapayIcon>(find.byType(ScalapayIcon)).icon,
      ScalapayIconData.close,
    );
    // Title centered horizontally in the frame.
    final frame = tester.getCenter(find.byType(BottomSheetFrame));
    expect(tester.getCenter(find.text('Filtri')).dx, closeTo(frame.dx, 0.5));
    // The body sits below the header.
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('body'))).dy,
      greaterThanOrEqualTo(91),
    );
  });

  testWidgets('the handle uses textDisabled at 0.4 opacity', (tester) async {
    await tester.pumpWidget(
      _host(const BottomSheetFrame(title: 'Filtri', child: _body)),
    );
    final handleSize = find.byWidgetPredicate(
      (w) => w is SizedBox && w.width == 45 && w.height == 5,
    );
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(of: handleSize, matching: find.byType(DecoratedBox))
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, colors.textDisabled.withValues(alpha: 0.4));
  });

  testWidgets('has the surface color and the sheet radius on the top corners', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const BottomSheetFrame(title: 'Filtri', child: _body)),
    );
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(BottomSheetFrame),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, colors.surface);
    expect(
      decoration.borderRadius,
      BorderRadius.vertical(top: Radius.circular(const ScalapayRadius().sheet)),
    );
  });

  testWidgets('the close button calls onClose once', (tester) async {
    var closes = 0;
    await tester.pumpWidget(
      _host(
        BottomSheetFrame(
          title: 'Filtri',
          onClose: () => closes++,
          child: _body,
        ),
      ),
    );
    await tester.tap(find.byType(ScalapayIcon));
    expect(closes, 1);
  });

  testWidgets(
    'its height follows the content in a parent as tall as the screen',
    (tester) async {
      await tester.pumpWidget(
        _host(const BottomSheetFrame(title: 'Filtri', child: _body)),
      );
      // 91 header + 100 body, not the 600 of the test surface.
      expect(tester.getSize(find.byType(BottomSheetFrame)).height, 191);
      expect(tester.getSize(find.byType(BottomSheetFrame)).width, 375);
    },
  );

  testWidgets(
    'adds the bottom system inset below the content instead of under it',
    (tester) async {
      // FakeViewPadding is in physical pixels: fix the ratio at 1 so the
      // logical inset below matches it exactly.
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(bottom: 40);
      tester.view.viewPadding = const FakeViewPadding(bottom: 40);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(const BottomSheetFrame(title: 'Filtri', child: _body)),
      );
      // 91 header + 100 body + 40 inset, the body itself untouched.
      expect(tester.getSize(find.byType(BottomSheetFrame)).height, 231);
      final body = tester.getTopLeft(find.byKey(const ValueKey('body')));
      expect(body.dy, 91);
      expect(tester.getSize(find.byKey(const ValueKey('body'))).height, 100);
    },
  );

  testWidgets('with no bottom inset it lays out exactly as before', (
    tester,
  ) async {
    // Explicit zero, not just the test default, to prove the no-inset path
    // itself reserves nothing rather than happening to read zero.
    tester.view.viewPadding = FakeViewPadding.zero;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(const BottomSheetFrame(title: 'Filtri', child: _body)),
    );
    expect(tester.getSize(find.byType(BottomSheetFrame)).height, 191);
    expect(tester.getBottomLeft(find.byKey(const ValueKey('body'))).dy, 191);
  });

  group('close button label', () {
    testWidgets('without a closeLabel it falls back to the localized default, '
        'not the English word', (tester) async {
      final handle = tester.ensureSemantics();
      late BuildContext capturedContext;
      await tester.pumpWidget(
        _italianHost(
          Builder(
            builder: (context) {
              capturedContext = context;
              return BottomSheetFrame(
                title: 'Filtri',
                onClose: () {},
                child: _body,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final expectedLabel = MaterialLocalizations.of(capturedContext)
          .closeButtonTooltip;
      expect(expectedLabel, isNot('Close'));

      expect(
        tester.getSemantics(
          find.descendant(
            of: find.byType(BottomSheetFrame),
            matching: find.bySemanticsLabel(expectedLabel),
          ),
        ),
        matchesSemantics(
          label: expectedLabel,
          isButton: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('a caller-supplied closeLabel is used', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          BottomSheetFrame(
            title: 'Filtri',
            closeLabel: 'Chiudi filtri',
            onClose: () {},
            child: _body,
          ),
        ),
      );

      expect(
        tester.getSemantics(
          find.descendant(
            of: find.byType(BottomSheetFrame),
            matching: find.bySemanticsLabel('Chiudi filtri'),
          ),
        ),
        matchesSemantics(
          label: 'Chiudi filtri',
          isButton: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets(
      'performing the semantics tap action invokes onClose exactly once',
      (tester) async {
        final handle = tester.ensureSemantics();
        var closes = 0;
        await tester.pumpWidget(
          _host(
            BottomSheetFrame(
              title: 'Filtri',
              closeLabel: 'Chiudi filtri',
              onClose: () => closes++,
              child: _body,
            ),
          ),
        );

        tester.semantics.tap(find.semantics.byLabel('Chiudi filtri'));
        expect(closes, 1);
        handle.dispose();
      },
    );
  });

  test('the frame is not exported by the package', () {
    final barrel = File('lib/scalapay_ui.dart').readAsStringSync();
    expect(barrel.contains('bottom_sheet_frame'), isFalse);
    final organisms = File('lib/src/organisms/organisms.dart');
    if (organisms.existsSync()) {
      expect(
        organisms.readAsStringSync().contains('bottom_sheet_frame'),
        isFalse,
      );
    }
  });
}
