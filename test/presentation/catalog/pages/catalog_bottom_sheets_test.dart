import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import '../../../helpers/pump_app.dart';

class _MockSearchProductsUseCase extends Mock
    implements SearchProductsUseCase {}

Result<ProductSearchResult> _success() =>
    const Result.success(ProductSearchResult(products: [], page: 1));

ProductSearchParams _lastParams(_MockSearchProductsUseCase useCase) =>
    verify(() => useCase.call(params: captureAny(named: 'params')))
            .captured
            .last
        as ProductSearchParams;

void main() {
  setUpAll(() {
    registerFallbackValue(const ProductSearchParams(query: 'fallback'));
  });

  late _MockSearchProductsUseCase useCase;
  late CatalogCubit cubit;

  setUp(() async {
    useCase = _MockSearchProductsUseCase();
    when(() => useCase.call(params: any(named: 'params')))
        .thenAnswer((_) async => _success());
    cubit = CatalogCubit(useCase);
    await cubit.search('nike');
  });

  Future<void> openSheet(WidgetTester tester, String chipLabel) async {
    await pumpApp(tester, const CatalogView(), cubit: cubit);
    await tester.tap(find.text(chipLabel));
    await tester.pumpAndSettle();
  }

  group('sort bottom sheet', () {
    testWidgets('shows its title and the three options in order, still no name '
        'ordering', (tester) async {
      await openSheet(tester, 'Ordina');

      final texts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(ScalapaySortBottomSheet<ProductSort>),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data)
          .toList();

      expect(texts, [
        'Ordina',
        'Rilevanza',
        'Prezzo crescente',
        'Prezzo decrescente',
      ]);
    });

    testWidgets('relevance is shown as selected before any choice', (
      tester,
    ) async {
      await openSheet(tester, 'Ordina');

      for (final radio in tester.widgetList<ScalapayRadio<ProductSort>>(
        find.byType(ScalapayRadio<ProductSort>),
      )) {
        expect(radio.groupValue, ProductSort.relevance);
      }
    });

    testWidgets('dismissing the sheet changes nothing', (tester) async {
      await openSheet(tester, 'Ordina');
      clearInteractions(useCase);

      // Tap the barrier, well above the sheet.
      await tester.tapAt(const Offset(200, 40));
      await tester.pumpAndSettle();

      expect(cubit.state.sort, ProductSort.relevance);
      verifyNever(() => useCase.call(params: any(named: 'params')));
    });

    testWidgets('choosing an option applies the sort and refreshes results', (
      tester,
    ) async {
      await openSheet(tester, 'Ordina');
      clearInteractions(useCase);

      await tester.tap(find.text('Prezzo crescente'));
      // The sheet's own selection delay before it pops with the choice.
      await tester.pumpAndSettle(const Duration(milliseconds: 350));

      expect(cubit.state.sort, ProductSort.priceAsc);
      expect(_lastParams(useCase).sort, ProductSort.priceAsc);
    });

    testWidgets(
      'choosing relevance again after price asc requests relevance once '
      'more, proving the default is still reachable',
      (tester) async {
        await openSheet(tester, 'Ordina');
        await tester.tap(find.text('Prezzo crescente'));
        await tester.pumpAndSettle(const Duration(milliseconds: 350));
        expect(cubit.state.sort, ProductSort.priceAsc);
        clearInteractions(useCase);

        await tester.tap(find.text('Ordina'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Rilevanza'));
        await tester.pumpAndSettle(const Duration(milliseconds: 350));

        expect(cubit.state.sort, ProductSort.relevance);
        expect(_lastParams(useCase).sort, ProductSort.relevance);
      },
    );
  });

  group('filters bottom sheet', () {
    testWidgets('shows its copy and the applied range prefilled', (
      tester,
    ) async {
      await cubit.applyPriceRange(const PriceRange(min: 10, max: 100));
      await openSheet(tester, 'Filtri');

      expect(find.text('Fascia di prezzo'), findsOneWidget);
      expect(find.text('Minimo'), findsOneWidget);
      expect(find.text('Massimo'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('dismissing the sheet changes nothing', (tester) async {
      await openSheet(tester, 'Filtri');
      clearInteractions(useCase);

      await tester.tapAt(const Offset(200, 40));
      await tester.pumpAndSettle();

      expect(cubit.state.priceRange, PriceRange.none);
      verifyNever(() => useCase.call(params: any(named: 'params')));
    });

    testWidgets('applying a valid range refreshes the results and closes', (
      tester,
    ) async {
      await openSheet(tester, 'Filtri');
      clearInteractions(useCase);

      // The header's search field is also a `TextField`: scope the finder to
      // the sheet so its two price fields are `.at(0)`/`.at(1)`.
      final priceFields = find.descendant(
        of: find.byType(ScalapayFiltersBottomSheet),
        matching: find.byType(TextField),
      );
      await tester.enterText(priceFields.at(0), '10');
      await tester.enterText(priceFields.at(1), '100');
      await tester.tap(find.text('Mostra risultati'));
      await tester.pumpAndSettle();

      expect(cubit.state.priceRange, const PriceRange(min: 10, max: 100));
      expect(
        _lastParams(useCase).priceRange,
        const PriceRange(min: 10, max: 100),
      );
      expect(find.text('Fascia di prezzo'), findsNothing);
    });

    testWidgets(
      'an inverted range keeps the sheet open, shows the message, and '
      'makes no request',
      (tester) async {
        await openSheet(tester, 'Filtri');
        clearInteractions(useCase);

        final priceFields = find.descendant(
          of: find.byType(ScalapayFiltersBottomSheet),
          matching: find.byType(TextField),
        );
        await tester.enterText(priceFields.at(0), '500');
        await tester.enterText(priceFields.at(1), '100');
        await tester.tap(find.text('Mostra risultati'));
        await tester.pumpAndSettle();

        expect(
          find.text('Il minimo non può superare il massimo.'),
          findsOneWidget,
        );
        expect(find.text('Fascia di prezzo'), findsOneWidget);
        expect(cubit.state.priceRange, PriceRange.none);
        verifyNever(() => useCase.call(params: any(named: 'params')));
      },
    );
  });
}
