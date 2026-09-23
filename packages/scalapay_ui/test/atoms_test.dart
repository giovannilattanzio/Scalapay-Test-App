import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  group('ScalapayButton horizontal padding', () {
    for (final variant in ScalapayButtonVariant.values) {
      testWidgets('${variant.name} width equals label width + 32', (
        tester,
      ) async {
        const label = 'Go';
        await tester.pumpWidget(
          _host(
            ScalapayButton(variant: variant, label: label, onPressed: () {}),
          ),
        );
        final buttonWidth = tester.getSize(find.byType(ScalapayButton)).width;
        final labelWidth = tester.getSize(find.text(label)).width;
        expect(buttonWidth, closeTo(labelWidth + 32, 0.5));
      });
    }
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

  group('ScalapayFilterChip layout', () {
    testWidgets('filter icon is 20, chip width is label width + 40', (
      tester,
    ) async {
      const label = 'Filtri';
      await tester.pumpWidget(
        _host(
          const ScalapayFilterChip(label: label, icon: ScalapayIconData.filter),
        ),
      );
      final chipWidth = tester.getSize(find.byType(ScalapayFilterChip)).width;
      final labelWidth = tester.getSize(find.text(label)).width;
      expect(chipWidth, closeTo(labelWidth + 40, 0.5));
      expect(tester.getSize(find.byType(ScalapayIcon)).width, 20);
      // The tap target is 44 tall (WCAG 2.5.5 / Apple HIG); the visible pill
      // inside it stays 32 tall (see the "ScalapayFilterChip tap target"
      // group).
      expect(tester.getSize(find.byType(ScalapayFilterChip)).height, 44);
    });

    testWidgets('order icon is 24, chip width is label width + 36', (
      tester,
    ) async {
      const label = 'Ordina';
      await tester.pumpWidget(
        _host(
          const ScalapayFilterChip(label: label, icon: ScalapayIconData.order),
        ),
      );
      final chipWidth = tester.getSize(find.byType(ScalapayFilterChip)).width;
      final labelWidth = tester.getSize(find.text(label)).width;
      expect(chipWidth, closeTo(labelWidth + 36, 0.5));
      expect(tester.getSize(find.byType(ScalapayIcon)).width, 24);
      expect(tester.getSize(find.byType(ScalapayFilterChip)).height, 44);
    });
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

    testWidgets('at a large text scale it grows instead of overflowing', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ScalapayTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 343,
                child: ScalapaySearchField(
                  controller: TextEditingController(text: 'Nike'),
                  onSubmitted: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Nike'), findsOneWidget);
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

    testWidgets('floated label renders at 11 (P5), not scaled down further', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(width: 200, child: ScalapayTextField(label: 'Minimo')),
        ),
      );
      await tester.enterText(find.byType(TextField), '150');
      await tester.pumpAndSettle();
      final renderParagraph = tester.renderObject<RenderParagraph>(
        find.text('Minimo'),
      );
      final textSpan = renderParagraph.text as TextSpan;
      final styledFontSize = textSpan.style!.fontSize!;
      // InputDecorator paints the floated label through a Transform (its
      // private `_kFinalLabelScale`), so the style's fontSize alone does not
      // reflect what is actually rendered: multiply by the scale applied to
      // the RenderParagraph to get the true on-screen size.
      final scale = renderParagraph.getTransformTo(null).getMaxScaleOnAxis();
      expect(styledFontSize * scale, closeTo(11, 0.1));
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

    testWidgets('is 56 tall when empty and without an error', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(width: 200, child: ScalapayTextField(label: 'Minimo')),
        ),
      );
      expect(tester.getSize(find.byType(ScalapayTextField)).height, 56);
    });

    testWidgets('is 56 tall when filled and without an error', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(width: 200, child: ScalapayTextField(label: 'Minimo')),
        ),
      );
      await tester.enterText(find.byType(TextField), '150');
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(ScalapayTextField)).height, 56);
    });

    testWidgets('value text uses the textInput color', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(width: 200, child: ScalapayTextField(label: 'Minimo')),
        ),
      );
      final style = tester.widget<TextField>(find.byType(TextField)).style!;
      expect(style.color, const Color(0xFF3A4045));
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

    testWidgets('label starts 34px from the option left edge in P2 Medium', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ScalapayRadio<String>(
            value: 'asc',
            groupValue: 'asc',
            label: 'Prezzo crescente',
            onChanged: (_) {},
          ),
        ),
      );
      final optionLeft = tester
          .getTopLeft(find.byType(ScalapayRadio<String>))
          .dx;
      final labelLeft = tester.getTopLeft(find.text('Prezzo crescente')).dx;
      expect(labelLeft - optionLeft, 34);
      expect(
        tester.widget<Text>(find.text('Prezzo crescente')).style,
        const ScalapayTypography().p2Medium.copyWith(
          color: const ScalapayColors().textPrimary,
        ),
      );
    });

    testWidgets('unselected ring uses the primaryMuted color', (tester) async {
      await tester.pumpWidget(
        _host(
          ScalapayRadio<String>(
            value: 'asc',
            groupValue: 'desc',
            label: 'Prezzo crescente',
            onChanged: (_) {},
          ),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.border!.top.color, const Color(0xFFCACCF2));
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

  group('accessibility - semantics tap actions', () {
    testWidgets('enabled ScalapayButton primary exposes a tap action', (
      tester,
    ) async {
      // Disposed explicitly (not via addTearDown): addTearDown callbacks run
      // after WidgetTester's end-of-test invariant checks, which would flag
      // the handle as still active.
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _host(ScalapayButton(label: 'Riprova', onPressed: () => taps++)),
      );

      expect(
        tester.getSemantics(find.byType(ScalapayButton)),
        matchesSemantics(
          label: 'Riprova',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      tester.semantics.tap(find.semantics.byLabel('Riprova'));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('enabled ScalapayButton tertiary exposes a tap action', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _host(
          ScalapayButton(
            variant: ScalapayButtonVariant.tertiary,
            label: 'Riprova',
            onPressed: () => taps++,
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(ScalapayButton)),
        matchesSemantics(
          label: 'Riprova',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      tester.semantics.tap(find.semantics.byLabel('Riprova'));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('disabled ScalapayButton has no tap action', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const ScalapayButton(label: 'Riprova')));

      expect(
        tester.getSemantics(find.byType(ScalapayButton)),
        matchesSemantics(
          label: 'Riprova',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('enabled ScalapayFilterChip exposes a tap action', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
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

      expect(
        tester.getSemantics(find.byType(ScalapayFilterChip)),
        matchesSemantics(
          label: 'Filtri',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      tester.semantics.tap(find.semantics.byLabel('Filtri'));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets(
      'unselected ScalapayRadio exposes a tap action and reports its value',
      (tester) async {
        final handle = tester.ensureSemantics();
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

        expect(
          tester.getSemantics(find.byType(ScalapayRadio<String>)),
          matchesSemantics(
            label: 'Prezzo crescente',
            isInMutuallyExclusiveGroup: true,
            hasCheckedState: true,
            isChecked: false,
            hasTapAction: true,
          ),
        );

        tester.semantics.tap(find.semantics.byLabel('Prezzo crescente'));
        expect(picked, 'asc');
        handle.dispose();
      },
    );

    testWidgets('selected ScalapayRadio has no tap action', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          ScalapayRadio<String>(
            value: 'asc',
            groupValue: 'asc',
            label: 'Prezzo crescente',
            onChanged: (_) {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(ScalapayRadio<String>)),
        matchesSemantics(
          label: 'Prezzo crescente',
          isInMutuallyExclusiveGroup: true,
          hasCheckedState: true,
          isChecked: true,
          hasTapAction: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('ScalapaySearchField action button exposes a tap action', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      String? submitted;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 343,
            child: ScalapaySearchField(onSubmitted: (v) => submitted = v),
          ),
        ),
      );
      final buttonFinder = find.descendant(
        of: find.byType(ScalapaySearchField),
        matching: find.bySemanticsLabel('Search'),
      );

      expect(
        tester.getSemantics(buttonFinder),
        matchesSemantics(label: 'Search', isButton: true, hasTapAction: true),
      );

      tester.semantics.tap(find.semantics.byLabel('Search'));
      expect(submitted, '');
      handle.dispose();
    });
  });

  group('ScalapaySearchField actionLabel', () {
    testWidgets('caller-supplied label is used for the action button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 343,
            child: ScalapaySearchField(actionLabel: 'Avvia ricerca'),
          ),
        ),
      );
      expect(
        tester.getSemantics(
          find.descendant(
            of: find.byType(ScalapaySearchField),
            matching: find.bySemanticsLabel('Avvia ricerca'),
          ),
        ),
        matchesSemantics(
          label: 'Avvia ricerca',
          isButton: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('without a label it falls back to the localized default', (
      tester,
    ) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: ScalapayTheme.light(),
          locale: const Locale('it'),
          supportedLocales: const [Locale('it'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox(width: 343, child: ScalapaySearchField());
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final expectedLabel = MaterialLocalizations.of(capturedContext)
          .searchFieldLabel;
      expect(expectedLabel, isNot('Search'));
      expect(
        tester.getSemantics(
          find.descendant(
            of: find.byType(ScalapaySearchField),
            matching: find.bySemanticsLabel(expectedLabel),
          ),
        ),
        matchesSemantics(
          label: expectedLabel,
          isButton: true,
          hasTapAction: true,
        ),
      );
    });
  });

  group('ScalapayFilterChip tap target', () {
    testWidgets('tapping the pill invokes the callback exactly once', (
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
    });

    testWidgets(
      'tapping 5px above the visible pill invokes the callback exactly once',
      (tester) async {
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
        final chipTop = tester.getTopLeft(find.byType(ScalapayFilterChip)).dy;
        final chipCenterX = tester
            .getCenter(find.byType(ScalapayFilterChip))
            .dx;
        await tester.tapAt(Offset(chipCenterX, chipTop + 5));
        expect(taps, 1);
      },
    );

    testWidgets('the visible pill stays 32 tall', (tester) async {
      await tester.pumpWidget(
        _host(
          ScalapayFilterChip(
            label: 'Filtri',
            icon: ScalapayIconData.filter,
            onPressed: () {},
          ),
        ),
      );
      final pillFinder = find.descendant(
        of: find.byType(ScalapayFilterChip),
        matching: find.byWidgetPredicate(
          (w) => w is Material && w.shape is StadiumBorder,
        ),
      );
      expect(tester.getSize(pillFinder).height, 32);
    });

    testWidgets('the whole chip is at least 44 tall', (tester) async {
      await tester.pumpWidget(
        _host(
          ScalapayFilterChip(
            label: 'Filtri',
            icon: ScalapayIconData.filter,
            onPressed: () {},
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(ScalapayFilterChip)).height,
        greaterThanOrEqualTo(44),
      );
    });

    testWidgets(
      'the ink (press highlight) is clipped to the pill, not the 44 box',
      (tester) async {
        await tester.pumpWidget(
          _host(
            ScalapayFilterChip(
              label: 'Filtri',
              icon: ScalapayIconData.filter,
              onPressed: () {},
            ),
          ),
        );
        final inkWellFinder = find.descendant(
          of: find.byType(ScalapayFilterChip),
          matching: find.byType(InkWell),
        );
        expect(inkWellFinder, findsOneWidget);
        final pillFinder = find.ancestor(
          of: inkWellFinder,
          matching: find.byWidgetPredicate(
            (w) => w is Material && w.shape is StadiumBorder,
          ),
        );
        expect(pillFinder, findsOneWidget);
      },
    );
  });

  group('accessibility - tap target guidelines', () {
    Widget padded(Widget child) =>
        Padding(padding: const EdgeInsets.all(24), child: child);

    testWidgets('ScalapayButton primary meets tap target guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(padded(ScalapayButton(label: 'Riprova', onPressed: () {}))),
      );
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('ScalapayButton tertiary meets tap target guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          padded(
            ScalapayButton(
              variant: ScalapayButtonVariant.tertiary,
              label: 'Riprova',
              onPressed: () {},
            ),
          ),
        ),
      );
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('ScalapayFilterChip filter icon meets tap target guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          padded(
            ScalapayFilterChip(
              label: 'Filtri',
              icon: ScalapayIconData.filter,
              onPressed: () {},
            ),
          ),
        ),
      );
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('ScalapayFilterChip order icon meets tap target guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          padded(
            ScalapayFilterChip(
              label: 'Ordina',
              icon: ScalapayIconData.order,
              onPressed: () {},
            ),
          ),
        ),
      );
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('unselected ScalapayRadio meets tap target guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          padded(
            SizedBox(
              width: 300,
              child: ScalapayRadio<String>(
                value: 'asc',
                groupValue: 'desc',
                label: 'Prezzo crescente',
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('ScalapaySearchField meets tap target guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(padded(const SizedBox(width: 343, child: ScalapaySearchField()))),
      );
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
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
