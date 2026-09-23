import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import '../../../helpers/pump_app.dart';

class _MockCatalogCubit extends MockCubit<CatalogState>
    implements CatalogCubit {}

Product _product(String id) => Product(
  id: id,
  name: 'Product $id',
  store: 'Store',
  brand: 'Brand',
  imageUrl: 'https://invalid.invalid/$id.png',
  sellingPrice: 10,
  listPrice: 20,
);

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

  testWidgets('success status with results meets the tap target guidelines and '
      'exposes each product card as one node, in grid order', (tester) async {
    seed(
      CatalogState(
        status: CatalogStatus.success,
        pages: ProductPageAccumulator(
          products: [_product('1'), _product('2'), _product('3')],
          seenIds: const {'1', '2', '3'},
        ),
      ),
    );
    await pumpApp(tester, const CatalogView(), cubit: cubit);

    final cardFinder = find.byType(ScalapayProductCard);
    expect(cardFinder, findsNWidgets(3));

    final cardElements = tester.elementList(cardFinder).toList();
    // Sorted by on-screen position (top-to-bottom, then left-to-right),
    // independent of the order the finder happens to walk the tree in.
    cardElements.sort((a, b) {
      final aTopLeft = (a.renderObject! as RenderBox).localToGlobal(
        Offset.zero,
      );
      final bTopLeft = (b.renderObject! as RenderBox).localToGlobal(
        Offset.zero,
      );
      if (aTopLeft.dy != bTopLeft.dy) return aTopLeft.dy.compareTo(bTopLeft.dy);
      return aTopLeft.dx.compareTo(bTopLeft.dx);
    });

    for (var i = 0; i < cardElements.length; i++) {
      final semantics = tester.getSemantics(
        find.byElementPredicate((element) => element == cardElements[i]),
      );
      expect(semantics.label, startsWith('Product ${i + 1}'));
    }

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  });

  testWidgets('empty status meets the tap target guidelines', (tester) async {
    seed(const CatalogState(status: CatalogStatus.empty, query: 'zzzqqq'));
    await pumpApp(tester, const CatalogView(), cubit: cubit);

    expect(find.text('Nessun risultato per "zzzqqq"'), findsOneWidget);

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  });

  testWidgets('failure status meets the tap target guidelines', (tester) async {
    seed(
      const CatalogState(
        status: CatalogStatus.failure,
        failure: NetworkFailure(message: 'boom'),
      ),
    );
    await pumpApp(tester, const CatalogView(), cubit: cubit);

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  });

  testWidgets('success status with a load-more failure meets the tap target '
      'guidelines', (tester) async {
    seed(
      CatalogState(
        status: CatalogStatus.success,
        loadMoreStatus: LoadMoreStatus.failure,
        pages: ProductPageAccumulator(
          products: [_product('1'), _product('2')],
          seenIds: const {'1', '2'},
        ),
      ),
    );
    await pumpApp(tester, const CatalogView(), cubit: cubit);

    // The footer sliver is only built once scrolled into the viewport.
    await Scrollable.ensureVisible(
      tester.element(find.byType(CatalogGridFooter, skipOffstage: false)),
      alignment: 0.5,
    );
    await tester.pump();

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  });
}
