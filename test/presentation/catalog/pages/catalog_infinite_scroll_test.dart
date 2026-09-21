import 'dart:async';

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

// The real cubit marks a page short of `perPage` (30, the state's default)
// as the end, so every page here carries exactly 30 products: only distinct
// ids decide whether the accumulator sees it as new or as the end.
const _perPage = 30;

List<Product> _products(Iterable<String> ids) => [
  for (final id in ids)
    Product(
      id: id,
      name: 'Product $id',
      store: 'Store',
      brand: 'Brand',
      imageUrl: 'https://invalid.invalid/$id.png',
      sellingPrice: 10,
      listPrice: 20,
    ),
];

List<String> _ids(int start, int count) =>
    List.generate(count, (i) => '${start + i}');

Result<ProductSearchResult> _pageResult(
  List<String> ids, {
  required int page,
}) => Result.success(ProductSearchResult(products: _products(ids), page: page));

/// Drags the `CustomScrollView` to its very end. A drag distance far larger
/// than the scrollable content clamps at `maxScrollExtent` in one gesture,
/// and (unlike a programmatic `jumpTo`) goes through the same pointer-driven
/// path a user's scroll does, so it reliably dispatches the
/// `ScrollUpdateNotification`s the page listens for.
Future<void> _scrollToEnd(WidgetTester tester) async {
  await tester.drag(find.byType(CustomScrollView), const Offset(0, -100000));
  await tester.pump();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const ProductSearchParams(query: 'fallback'));
  });

  late _MockSearchProductsUseCase useCase;
  late CatalogCubit cubit;

  setUp(() {
    useCase = _MockSearchProductsUseCase();
    cubit = CatalogCubit(useCase);
  });

  Future<void> pumpWithFirstPage(WidgetTester tester) async {
    when(() => useCase.call(params: any(named: 'params')))
        .thenAnswer((_) async => _pageResult(_ids(0, _perPage), page: 1));
    await cubit.search('nike');
    await pumpApp(tester, const CatalogView(), cubit: cubit);
  }

  testWidgets('scrolling near the end triggers exactly one loadMore call', (
    tester,
  ) async {
    await pumpWithFirstPage(tester);
    clearInteractions(useCase);

    // A single `drag` already delivers more than one scroll notification (it
    // is a down/slop-move/move/up sequence); resolving the mock immediately
    // would let a later notification within the same gesture start a second,
    // legitimate append once the first already completed. Holding the
    // response open isolates what this test actually checks: one *trigger*,
    // independent of how many notifications the gesture happens to emit.
    final completer = Completer<Result<ProductSearchResult>>();
    when(() => useCase.call(params: any(named: 'params')))
        .thenAnswer((_) => completer.future);

    await _scrollToEnd(tester);

    verify(() => useCase.call(params: any(named: 'params'))).called(1);

    completer.complete(_pageResult(_ids(_perPage, _perPage), page: 2));
    await tester.pump();
    await tester.pump();
  });

  testWidgets('a burst of scroll notifications still triggers only one '
      'request', (tester) async {
    await pumpWithFirstPage(tester);
    clearInteractions(useCase);

    final completer = Completer<Result<ProductSearchResult>>();
    when(() => useCase.call(params: any(named: 'params')))
        .thenAnswer((_) => completer.future);

    // Several notifications in a row before the first request resolves: the
    // widget does not gate itself, so without `canLoadMore` this would fire
    // once per jump.
    await _scrollToEnd(tester);
    await _scrollToEnd(tester);
    await _scrollToEnd(tester);

    verify(() => useCase.call(params: any(named: 'params'))).called(1);

    completer.complete(_pageResult(_ids(_perPage, _perPage), page: 2));
    await tester.pump();
    await tester.pump();
  });

  testWidgets(
    'the footer shows the spinner while appending, and the retry button on '
    'failure, while the grid stays visible',
    (tester) async {
      await pumpWithFirstPage(tester);

      final completer = Completer<Result<ProductSearchResult>>();
      when(() => useCase.call(params: any(named: 'params')))
          .thenAnswer((_) => completer.future);

      await _scrollToEnd(tester);
      await tester.pump();

      // The footer sliver only exists once the grid's own maxScrollExtent
      // (fixed at the moment of the trigger) grows to include it, so it
      // starts right at the current viewport edge with zero paint extent —
      // invisible to the default finder, which skips offstage widgets, so
      // it must be looked up with `skipOffstage: false` before
      // `ensureVisible` can scroll it fully into view.
      await Scrollable.ensureVisible(
        tester.element(find.byType(CatalogGridFooter, skipOffstage: false)),
        alignment: 0.5,
      );
      await tester.pump();

      expect(find.byType(CatalogProductGrid), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(const Result.error(ServerFailure(message: 'boom')));
      await tester.pump();
      await tester.pump();

      expect(find.byType(CatalogProductGrid), findsOneWidget);
      expect(find.text('Caricamento non riuscito. Riprova.'), findsOneWidget);

      when(
        () => useCase.call(params: any(named: 'params')),
      ).thenAnswer((_) async => _pageResult(_ids(_perPage, _perPage), page: 2));
      await Scrollable.ensureVisible(
        tester.element(find.text('Riprova')),
        alignment: 0.5,
      );
      await tester.pump();
      await tester.tap(find.text('Riprova'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Caricamento non riuscito. Riprova.'), findsNothing);
    },
  );

  testWidgets(
    'reaching the end shows no footer and stops triggering further requests',
    (tester) async {
      await pumpWithFirstPage(tester);

      // A page with no id the accumulator has not already seen: the service's
      // own signal that there is nothing further to fetch.
      when(() => useCase.call(params: any(named: 'params')))
          .thenAnswer((_) async => _pageResult(_ids(0, _perPage), page: 1));

      await _scrollToEnd(tester);
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ScalapayButton), findsNothing);

      clearInteractions(useCase);
      await _scrollToEnd(tester);
      await tester.pump();

      verifyNever(() => useCase.call(params: any(named: 'params')));
    },
  );

  testWidgets('the scroll position is preserved when a page is appended', (
    tester,
  ) async {
    await pumpWithFirstPage(tester);

    when(
      () => useCase.call(params: any(named: 'params')),
    ).thenAnswer((_) async => _pageResult(_ids(_perPage, _perPage), page: 2));

    await _scrollToEnd(tester);
    final beforeAppend = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .pixels;
    await tester.pump();
    await tester.pump();

    final afterAppend = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .pixels;
    expect(afterAppend, beforeAppend);
  });
}
