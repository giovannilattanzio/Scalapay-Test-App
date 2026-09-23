import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import '../../../helpers/android_nonlinear_text_scaler.dart';
import '../../../helpers/pump_app.dart';

class _MockCatalogCubit extends MockCubit<CatalogState>
    implements CatalogCubit {}

// Enough rows (2 columns) that the grid is well taller than the viewport, so
// scrolling through it genuinely moves through several rows rather than
// merely nudging the first one.
List<Product> _products(int count) => List.generate(
  count,
  (i) => Product(
    id: '$i',
    name: 'Product $i',
    store: 'Store',
    brand: 'Brand',
    imageUrl: 'https://invalid.invalid/$i.png',
    sellingPrice: 10 + i.toDouble(),
    listPrice: 20 + i.toDouble(),
  ),
);

const _sizes = {'375x812': Size(375, 812), '320x568': Size(320, 568)};

/// Number of tiles sharing the top-most `dy`, i.e. the columns in the first
/// row (grid layout is row-major, so they are the first N tiles found), the
/// same way `catalog_product_grid_test.dart` establishes column counts.
int _firstRowColumnCount(WidgetTester tester) {
  final tiles = tester.widgetList(find.byType(CatalogProductTile)).toList();
  final positions = tiles
      .map((w) => tester.getTopLeft(find.byWidget(w)).dy)
      .toList();
  final firstRowDy = positions.first;
  return positions.where((dy) => dy == firstRowDy).length;
}

void main() {
  setUpAll(() {
    registerFallbackValue(ProductSort.relevance);
    registerFallbackValue(PriceRange.none);
  });

  late _MockCatalogCubit cubit;

  setUp(() {
    cubit = _MockCatalogCubit();
    when(() => cubit.search(any())).thenAnswer((_) async {});
    when(() => cubit.retry()).thenAnswer((_) async {});
    when(() => cubit.loadMore()).thenAnswer((_) async {});
    when(() => cubit.changeSort(any())).thenAnswer((_) async {});
    when(() => cubit.applyPriceRange(any())).thenAnswer((_) async {});
    when(() => cubit.setLanguage(any())).thenReturn(null);
  });

  void seed(CatalogState state) {
    whenListen(cubit, const Stream<CatalogState>.empty(), initialState: state);
  }

  for (final entry in _sizes.entries) {
    testWidgets('results scroll cleanly at 200% text scale on ${entry.key}', (
      tester,
    ) async {
      seed(
        CatalogState(
          status: CatalogStatus.success,
          pages: ProductPageAccumulator(
            products: _products(30),
            seenIds: {for (var i = 0; i < 30; i++) '$i'},
          ),
        ),
      );
      await pumpApp(
        tester,
        const CatalogView(),
        cubit: cubit,
        surfaceSize: entry.value,
        textScaleFactor: 2.0,
      );
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -100000),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'the sort sheet shows every option at 200% text scale on ${entry.key}',
      (tester) async {
        seed(const CatalogState());
        await pumpApp(
          tester,
          const CatalogView(),
          cubit: cubit,
          surfaceSize: entry.value,
          textScaleFactor: 2.0,
        );

        await tester.tap(find.text('Ordina'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        for (final option in [
          'Rilevanza',
          'Prezzo crescente',
          'Prezzo decrescente',
        ]) {
          final finder = find.text(option, skipOffstage: false);
          expect(finder, findsOneWidget);
          await tester.ensureVisible(finder);
          await tester.pump();
        }
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('the filters sheet shows both buttons at 200% text scale on '
        '${entry.key}', (tester) async {
      seed(const CatalogState());
      await pumpApp(
        tester,
        const CatalogView(),
        cubit: cubit,
        surfaceSize: entry.value,
        textScaleFactor: 2.0,
      );

      await tester.tap(find.text('Filtri'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      for (final label in ['Cancella tutto', 'Mostra risultati']) {
        final finder = find.text(label, skipOffstage: false);
        expect(finder, findsOneWidget);
        await tester.ensureVisible(finder);
        await tester.pump();
      }
      expect(tester.takeException(), isNull);
    });
  }

  // `TextScaler.linear` cannot reproduce Android 14+'s non-linear font scale
  // curve (small font sizes roughly double, large inputs barely scale), the
  // one that let `CatalogProductGrid` pass a layout length into
  // `textScaler.scale` go unnoticed: on a linear scaler that mistake still
  // scaled the length like everything else; on this curve a value as large
  // as a cell height or `maxCrossAxisExtent` sits past the table and comes
  // back almost unscaled, while the card's own text still roughly doubles,
  // so the grid both overflows the card and keeps two columns instead of
  // widening to one.
  for (final entry in _sizes.entries) {
    testWidgets(
      'results scroll cleanly with the Android 14+ non-linear text scaler '
      'on ${entry.key}, and the grid falls back to a single column',
      (tester) async {
        seed(
          CatalogState(
            status: CatalogStatus.success,
            pages: ProductPageAccumulator(
              products: _products(30),
              seenIds: {for (var i = 0; i < 30; i++) '$i'},
            ),
          ),
        );
        await pumpApp(
          tester,
          const CatalogView(),
          cubit: cubit,
          surfaceSize: entry.value,
          textScaler: const AndroidNonLinearTextScaler(),
        );
        expect(tester.takeException(), isNull);
        expect(_firstRowColumnCount(tester), 1);

        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -2000),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -100000),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'at 320x568 and 200% text scale, both toolbar chips stay fully on '
    'screen and the grid falls back to a single column',
    (tester) async {
      const size = Size(320, 568);
      seed(
        CatalogState(
          status: CatalogStatus.success,
          pages: ProductPageAccumulator(
            products: _products(4),
            seenIds: {for (var i = 0; i < 4; i++) '$i'},
          ),
        ),
      );
      await pumpApp(
        tester,
        const CatalogView(),
        cubit: cubit,
        surfaceSize: size,
        textScaleFactor: 2.0,
      );
      expect(tester.takeException(), isNull);

      // Fully on screen: both chips' bounds sit inside the device surface,
      // rather than off to either side (the toolbar's own previous bug,
      // centered instead of trailing-aligned, kept both technically within
      // this same check, so hit-testing each below is what actually proves
      // neither is clipped or otherwise unreachable).
      final screen = Offset.zero & size;
      final filtriRect = tester.getRect(find.text('Filtri'));
      final ordinaRect = tester.getRect(find.text('Ordina'));
      expect(screen.contains(filtriRect.topLeft), isTrue);
      expect(screen.contains(filtriRect.bottomRight), isTrue);
      expect(screen.contains(ordinaRect.topLeft), isTrue);
      expect(screen.contains(ordinaRect.bottomRight), isTrue);

      // Hit-testable: tapping each chip's label actually opens its sheet.
      await tester.tap(find.text('Filtri'));
      await tester.pumpAndSettle();
      expect(find.byType(ScalapayFiltersBottomSheet), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ordina'));
      await tester.pumpAndSettle();
      expect(find.byType(ScalapaySortBottomSheet<ProductSort>), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(_firstRowColumnCount(tester), 1);
      expect(tester.takeException(), isNull);
    },
  );
}
