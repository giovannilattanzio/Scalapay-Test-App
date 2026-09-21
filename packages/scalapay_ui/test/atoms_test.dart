import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

Widget _host(Widget child, {ScalapayTokens? tokens}) => MaterialApp(
  theme: ScalapayTheme.light(tokens: tokens ?? const ScalapayTokens()),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('ScalapayButton', () {
    testWidgets('invokes callback once when enabled', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(ScalapayButton(label: 'Go', onPressed: () => taps++)),
      );
      await tester.tap(find.text('Go'));
      expect(taps, 1);
    });

    testWidgets('is disabled without callback', (tester) async {
      await tester.pumpWidget(_host(const ScalapayButton(label: 'Go')));
      await tester.tap(find.text('Go'));
      expect(
        tester.getSemantics(find.byType(ScalapayButton)),
        matchesSemantics(
          label: 'Go',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
    });

    testWidgets('uses the primary token as background', (tester) async {
      const custom = ScalapayTokens(
        colors: ScalapayColors(primary: Color(0xFF123456)),
      );
      await tester.pumpWidget(
        _host(
          ScalapayButton(label: 'Go', onPressed: () {}),
          tokens: custom,
        ),
      );
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(ScalapayButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, const Color(0xFF123456));
    });
  });

  group('ScalapayButton tertiary', () {
    testWidgets('invokes callback when enabled', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          ScalapayButton(
            variant: ScalapayButtonVariant.tertiary,
            label: 'Clear',
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.text('Clear'));
      expect(taps, 1);
    });

    testWidgets('has no background and a primary label when enabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ScalapayButton(
            variant: ScalapayButtonVariant.tertiary,
            label: 'Clear',
            onPressed: () {},
          ),
        ),
      );
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(ScalapayButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.type, MaterialType.transparency);
      expect(
        tester.widget<Text>(find.text('Clear')).style!.color,
        const ScalapayColors().primary,
      );
    });

    testWidgets('label uses the disabled color without a callback', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const ScalapayButton(
            variant: ScalapayButtonVariant.tertiary,
            label: 'Clear',
          ),
        ),
      );
      expect(
        tester.widget<Text>(find.text('Clear')).style!.color,
        const ScalapayColors().textDisabled,
      );
    });
  });

  group('ScalapayButton height', () {
    for (final variant in ScalapayButtonVariant.values) {
      testWidgets(
        '${variant.name} is 44 tall in a parent as tall as the screen',
        (tester) async {
          await tester.pumpWidget(
            _host(
              ScalapayButton(variant: variant, label: 'Go', onPressed: () {}),
            ),
          );
          expect(tester.getSize(find.byType(ScalapayButton)).height, 44);
        },
      );
    }
  });

  testWidgets('ScalapayFilterChip reports taps and shows label', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        ScalapayFilterChip(
          label: 'Filtri',
          icon: ScalapayIconData.filter,
          onPressed: () => taps++,
        ),
      ),
    );
    await tester.tap(find.text('Filtri'));
    expect(taps, 1);
    expect(find.byType(ScalapayIcon), findsOneWidget);
  });

  group('ScalapaySearchField', () {
    testWidgets('action button submits the current text', (tester) async {
      String? submitted;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 343,
            child: ScalapaySearchField(onSubmitted: (v) => submitted = v),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Nike');
      await tester.tap(find.byType(ScalapayIcon));
      expect(submitted, 'Nike');
    });

    testWidgets('keyboard submit also submits', (tester) async {
      String? submitted;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 343,
            child: ScalapaySearchField(onSubmitted: (v) => submitted = v),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Adidas');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      expect(submitted, 'Adidas');
    });
  });

  group('ScalapayTextField', () {
    testWidgets('a rejecting formatter leaves the field unchanged', (
      tester,
    ) async {
      final c = TextEditingController();
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 200,
            child: ScalapayTextField(
              label: 'Minimo',
              controller: c,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '12');
      await tester.enterText(find.byType(TextField), '12a');
      expect(c.text, '12');
    });

    testWidgets('without formatters any text is accepted', (tester) async {
      final c = TextEditingController();
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 200,
            child: ScalapayTextField(label: 'Minimo', controller: c),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'ab -1,2.3');
      expect(c.text, 'ab -1,2.3');
    });

    testWidgets('label floats once the field has text', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(width: 200, child: ScalapayTextField(label: 'Minimo')),
        ),
      );
      final before = tester.getTopLeft(find.text('Minimo')).dy;
      await tester.enterText(find.byType(TextField), '150');
      await tester.pumpAndSettle();
      final after = tester.getTopLeft(find.text('Minimo')).dy;
      expect(after, lessThan(before));
    });

    testWidgets('shows the error message', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 200,
            child: ScalapayTextField(label: 'Minimo', errorText: 'Non valido'),
          ),
        ),
      );
      expect(find.text('Non valido'), findsOneWidget);
      final style = tester.widget<Text>(find.text('Non valido')).style!;
      expect(style.color, const ScalapayColors().error);
    });
  });

  group('ScalapayRadio', () {
    testWidgets('unselected option reports its value', (tester) async {
      String? picked;
      await tester.pumpWidget(
        _host(
          ScalapayRadio<String>(
            value: 'asc',
            groupValue: 'desc',
            label: 'Prezzo crescente',
            onChanged: (v) => picked = v,
          ),
        ),
      );
      await tester.tap(find.text('Prezzo crescente'));
      expect(picked, 'asc');
    });

    testWidgets('selected option does not re-report and is marked checked', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        _host(
          ScalapayRadio<String>(
            value: 'asc',
            groupValue: 'asc',
            label: 'Prezzo crescente',
            onChanged: (_) => calls++,
          ),
        ),
      );
      await tester.tap(find.text('Prezzo crescente'));
      expect(calls, 0);
      expect(
        tester.getSemantics(find.byType(ScalapayRadio<String>)),
        matchesSemantics(
          label: 'Prezzo crescente',
          isInMutuallyExclusiveGroup: true,
          hasCheckedState: true,
          isChecked: true,
        ),
      );
    });
  });

  group('icons and divider', () {
    testWidgets('icon renders in the given color and size', (tester) async {
      await tester.pumpWidget(
        _host(
          const ScalapayIcon(
            ScalapayIconData.close,
            size: 32,
            color: Color(0xFFFF0000),
          ),
        ),
      );
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.width, 32);
      expect(
        svg.colorFilter,
        const ColorFilter.mode(Color(0xFFFF0000), BlendMode.srcIn),
      );
    });

    test('icon constants point to existing files and match the enum', () {
      for (final path in ScalapayIcons.all) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }
      expect(ScalapayIconData.values.map((i) => i.asset), ScalapayIcons.all);
    });

    test('every icon asset exists', () {
      for (final icon in ScalapayIconData.values) {
        expect(File(icon.asset).existsSync(), isTrue, reason: icon.asset);
      }
    });

    testWidgets('divider uses the border token', (tester) async {
      await tester.pumpWidget(
        _host(const SizedBox(width: 100, child: ScalapayDivider())),
      );
      expect(
        tester.widget<Divider>(find.byType(Divider)).color,
        const ScalapayColors().border,
      );
    });
  });

  test('atoms, molecules and organisms do not hardcode colors', () {
    final sources =
        ['lib/src/widgets', 'lib/src/molecules', 'lib/src/organisms']
            .expand((dir) => Directory(dir).listSync(recursive: true))
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));
    expect(sources, isNotEmpty);
    for (final file in sources) {
      expect(
        _hasHardcodedColor(file.readAsStringSync()),
        isFalse,
        reason: file.path,
      );
    }
    // The molecules and organisms directories are really scanned.
    final paths = sources.map((f) => f.path).toList();
    expect(paths.any((p) => p.contains('scalapay_product_card.dart')), isTrue);
    expect(paths.any((p) => p.contains('show_modal_sheet.dart')), isTrue);
    expect(paths.any((p) => p.contains('bottom_sheet_frame.dart')), isTrue);
  });

  test('the hardcoded color check allows only Colors.transparent', () {
    expect(_hasHardcodedColor('color: Colors.transparent,'), isFalse);
    expect(_hasHardcodedColor('color: Colors.red,'), isTrue);
    expect(_hasHardcodedColor('color: Colors.transparentish,'), isTrue);
    expect(_hasHardcodedColor('color: Color(0xFF000000),'), isTrue);
    expect(_hasHardcodedColor('Colors.transparent, Colors.white'), isTrue);
  });
}

/// Real colors are never hardcoded in the design system widgets: they come
/// from the tokens. `Colors.transparent` is the absence of a color and is the
/// only allowed constant (the modal background of the bottom sheets).
bool _hasHardcodedColor(String source) {
  final withoutTransparent = source.replaceAll(
    RegExp(r'Colors\.transparent\b'),
    '',
  );
  return RegExp(r'Color\(0x|Colors\.').hasMatch(withoutTransparent);
}
