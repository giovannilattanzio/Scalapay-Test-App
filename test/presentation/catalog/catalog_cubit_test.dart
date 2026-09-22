import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';

class _MockSearchProductsUseCase extends Mock
    implements SearchProductsUseCase {}

Product _product(String id) => Product(
  id: id,
  name: 'name $id',
  store: 'store',
  brand: 'brand',
  imageUrl: 'url',
  sellingPrice: 10,
  listPrice: 10,
);

Result<ProductSearchResult> _success(List<Product> products, {int page = 1}) =>
    Result.success(ProductSearchResult(products: products, page: page));

const _failure = ServerFailure(message: 'boom');

void main() {
  setUpAll(() {
    registerFallbackValue(const ProductSearchParams(query: 'fallback'));
  });

  late _MockSearchProductsUseCase useCase;

  setUp(() {
    useCase = _MockSearchProductsUseCase();
  });

  void mockCall(Result<ProductSearchResult> result) {
    when(() => useCase.call(params: any(named: 'params')))
        .thenAnswer((_) async => result);
  }

  ProductSearchParams captured() =>
      verify(() => useCase.call(params: captureAny(named: 'params')))
              .captured
              .last
          as ProductSearchParams;

  group('search', () {
    blocTest<CatalogCubit, CatalogState>(
      'a blank query emits nothing and never calls the use case',
      build: () => CatalogCubit(useCase),
      act: (cubit) => cubit.search(''),
      expect: () => <CatalogState>[],
      verify: (_) =>
          verifyNever(() => useCase.call(params: any(named: 'params'))),
    );

    blocTest<CatalogCubit, CatalogState>(
      'a whitespace-only query emits nothing and never calls the use case',
      build: () => CatalogCubit(useCase),
      act: (cubit) => cubit.search('   '),
      expect: () => <CatalogState>[],
      verify: (_) =>
          verifyNever(() => useCase.call(params: any(named: 'params'))),
    );

    blocTest<CatalogCubit, CatalogState>(
      'a successful search emits loading then success with the products',
      build: () {
        mockCall(_success([_product('1'), _product('2')]));
        return CatalogCubit(useCase);
      },
      act: (cubit) => cubit.search('nike'),
      expect: () => [
        isA<CatalogState>()
            .having((s) => s.status, 'status', CatalogStatus.loading)
            .having((s) => s.query, 'query', 'nike'),
        isA<CatalogState>()
            .having((s) => s.status, 'status', CatalogStatus.success)
            .having((s) => s.products.map((p) => p.id), 'products', ['1', '2']),
      ],
    );

    blocTest<CatalogCubit, CatalogState>(
      'a result with no products emits loading then empty',
      build: () {
        mockCall(_success(const []));
        return CatalogCubit(useCase);
      },
      act: (cubit) => cubit.search('nike'),
      expect: () => [
        isA<CatalogState>().having(
          (s) => s.status,
          'status',
          CatalogStatus.loading,
        ),
        isA<CatalogState>()
            .having((s) => s.status, 'status', CatalogStatus.empty)
            .having((s) => s.products, 'products', isEmpty),
      ],
    );

    blocTest<CatalogCubit, CatalogState>(
      'a first-page failure emits loading then failure carrying the failure',
      build: () {
        when(() => useCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => const Result.error(_failure));
        return CatalogCubit(useCase);
      },
      act: (cubit) => cubit.search('nike'),
      expect: () => [
        isA<CatalogState>().having(
          (s) => s.status,
          'status',
          CatalogStatus.loading,
        ),
        isA<CatalogState>()
            .having((s) => s.status, 'status', CatalogStatus.failure)
            .having((s) => s.failure, 'failure', _failure),
      ],
    );

    blocTest<CatalogCubit, CatalogState>(
      'changing the query after several pages discards accumulated products '
      'and restarts at page 1',
      build: () {
        mockCall(_success([_product('9')]));
        return CatalogCubit(useCase);
      },
      seed: () => const CatalogState(
        status: CatalogStatus.success,
        query: 'old',
        pages: ProductPageAccumulator(
          products: [],
          seenIds: {'a', 'b'},
          nextPage: 4,
        ),
      ),
      act: (cubit) => cubit.search('new'),
      expect: () => [
        isA<CatalogState>()
            .having((s) => s.status, 'status', CatalogStatus.loading)
            .having((s) => s.pages.nextPage, 'nextPage', kDefaultPage)
            .having((s) => s.pages.products, 'products', isEmpty),
        isA<CatalogState>()
            .having((s) => s.status, 'status', CatalogStatus.success)
            .having((s) => s.products.map((p) => p.id), 'products', ['9']),
      ],
      verify: (_) {
        final params = captured();
        expect(params.page, kDefaultPage);
        expect(params.query, 'new');
      },
    );
  });

  group('changeSort', () {
    blocTest<CatalogCubit, CatalogState>(
      'an unchanged sort emits nothing',
      build: () => CatalogCubit(useCase),
      act: (cubit) => cubit.changeSort(ProductSort.relevance),
      expect: () => <CatalogState>[],
      verify: (_) =>
          verifyNever(() => useCase.call(params: any(named: 'params'))),
    );

    blocTest<CatalogCubit, CatalogState>(
      'a changed sort resets the accumulator and reloads page 1',
      build: () {
        mockCall(_success([_product('1')]));
        return CatalogCubit(useCase);
      },
      seed: () => const CatalogState(
        status: CatalogStatus.success,
        query: 'nike',
        pages: ProductPageAccumulator(
          products: [],
          seenIds: {'a', 'b', 'c'},
          nextPage: 3,
        ),
      ),
      act: (cubit) => cubit.changeSort(ProductSort.priceAsc),
      expect: () => [
        isA<CatalogState>()
            .having((s) => s.status, 'status', CatalogStatus.loading)
            .having((s) => s.sort, 'sort', ProductSort.priceAsc)
            .having((s) => s.pages.nextPage, 'nextPage', kDefaultPage),
        isA<CatalogState>()
            .having((s) => s.status, 'status', CatalogStatus.success)
            .having((s) => s.products.map((p) => p.id), 'products', ['1']),
      ],
      verify: (_) => expect(captured().sort, ProductSort.priceAsc),
    );
  });

  group('applyPriceRange', () {
    blocTest<CatalogCubit, CatalogState>(
      'an inverted range emits nothing at all and never calls the use case',
      build: () => CatalogCubit(useCase),
      act: (cubit) =>
          cubit.applyPriceRange(const PriceRange(min: 100, max: 10)),
      expect: () => <CatalogState>[],
      verify: (_) =>
          verifyNever(() => useCase.call(params: any(named: 'params'))),
    );

    blocTest<CatalogCubit, CatalogState>(
      'a valid range resets the accumulator and reloads page 1',
      build: () {
        mockCall(_success([_product('1')]));
        return CatalogCubit(useCase);
      },
      seed: () => const CatalogState(
        status: CatalogStatus.success,
        query: 'nike',
        pages: ProductPageAccumulator(
          products: [],
          seenIds: {'a', 'b'},
          nextPage: 3,
        ),
      ),
      act: (cubit) =>
          cubit.applyPriceRange(const PriceRange(min: 10, max: 100)),
      expect: () => [
        isA<CatalogState>()
            .having((s) => s.status, 'status', CatalogStatus.loading)
            .having(
              (s) => s.priceRange,
              'priceRange',
              const PriceRange(min: 10, max: 100),
            )
            .having((s) => s.pages.nextPage, 'nextPage', kDefaultPage),
        isA<CatalogState>().having(
          (s) => s.status,
          'status',
          CatalogStatus.success,
        ),
      ],
    );
  });

  group('loadMore', () {
    blocTest<CatalogCubit, CatalogState>(
      'appends the next page and advances nextPage',
      build: () {
        mockCall(_success([_product('3'), _product('4')]));
        return CatalogCubit(useCase);
      },
      seed: () => CatalogState(
        status: CatalogStatus.success,
        query: 'nike',
        perPage: 2,
        pages: ProductPageAccumulator(
          products: [_product('1'), _product('2')],
          seenIds: const {'1', '2'},
          nextPage: 2,
        ),
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        isA<CatalogState>().having(
          (s) => s.loadMoreStatus,
          'loadMoreStatus',
          LoadMoreStatus.loading,
        ),
        isA<CatalogState>()
            .having(
              (s) => s.loadMoreStatus,
              'loadMoreStatus',
              LoadMoreStatus.idle,
            )
            .having((s) => s.products.map((p) => p.id), 'products', [
              '1',
              '2',
              '3',
              '4',
            ])
            .having((s) => s.pages.nextPage, 'nextPage', 3),
      ],
      verify: (_) => expect(captured().page, 2),
    );

    blocTest<CatalogCubit, CatalogState>(
      'is a no-op while one is already in flight',
      build: () => CatalogCubit(useCase),
      seed: () => const CatalogState(
        status: CatalogStatus.success,
        loadMoreStatus: LoadMoreStatus.loading,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => <CatalogState>[],
      verify: (_) =>
          verifyNever(() => useCase.call(params: any(named: 'params'))),
    );

    blocTest<CatalogCubit, CatalogState>(
      'is a no-op after the end is reached',
      build: () => CatalogCubit(useCase),
      seed: () => const CatalogState(
        status: CatalogStatus.success,
        pages: ProductPageAccumulator(hasReachedEnd: true),
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => <CatalogState>[],
      verify: (_) =>
          verifyNever(() => useCase.call(params: any(named: 'params'))),
    );

    blocTest<CatalogCubit, CatalogState>(
      'a page of already-seen products sets exhausted and leaves the '
      'product list byte-identical',
      build: () {
        mockCall(_success([_product('1'), _product('2')]));
        return CatalogCubit(useCase);
      },
      seed: () => CatalogState(
        status: CatalogStatus.success,
        pages: ProductPageAccumulator(
          products: [_product('1'), _product('2')],
          seenIds: const {'1', '2'},
          nextPage: 2,
        ),
      ),
      act: (cubit) => cubit.loadMore(),
      verify: (cubit) {
        expect(cubit.state.loadMoreStatus, LoadMoreStatus.exhausted);
        expect(cubit.state.status, CatalogStatus.success);
        expect(cubit.state.products.map((p) => p.id), ['1', '2']);
      },
    );

    blocTest<CatalogCubit, CatalogState>(
      'a failure while appending emits loadMoreStatus failure while status '
      'stays success and products are unchanged',
      build: () {
        when(() => useCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => const Result.error(_failure));
        return CatalogCubit(useCase);
      },
      seed: () => CatalogState(
        status: CatalogStatus.success,
        pages: ProductPageAccumulator(
          products: [_product('1'), _product('2')],
          seenIds: const {'1', '2'},
          nextPage: 2,
        ),
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        isA<CatalogState>().having(
          (s) => s.loadMoreStatus,
          'loadMoreStatus',
          LoadMoreStatus.loading,
        ),
        isA<CatalogState>()
            .having(
              (s) => s.loadMoreStatus,
              'loadMoreStatus',
              LoadMoreStatus.failure,
            )
            .having((s) => s.status, 'status', CatalogStatus.success)
            .having((s) => s.products.map((p) => p.id), 'products', ['1', '2']),
      ],
    );
  });

  group('retry', () {
    blocTest<CatalogCubit, CatalogState>(
      'resumes the first-page search after a first-page failure',
      build: () {
        mockCall(_success([_product('1')]));
        return CatalogCubit(useCase);
      },
      seed: () => const CatalogState(
        status: CatalogStatus.failure,
        query: 'nike',
        failure: _failure,
      ),
      act: (cubit) => cubit.retry(),
      expect: () => [
        isA<CatalogState>()
            .having((s) => s.status, 'status', CatalogStatus.loading)
            .having((s) => s.failure, 'failure', isNull),
        isA<CatalogState>()
            .having((s) => s.status, 'status', CatalogStatus.success)
            .having((s) => s.products.map((p) => p.id), 'products', ['1']),
      ],
      verify: (_) {
        final params = captured();
        expect(params.query, 'nike');
        expect(params.page, kDefaultPage);
      },
    );

    blocTest<CatalogCubit, CatalogState>(
      'resumes loadMore for the same page after an append failure',
      build: () {
        mockCall(_success([_product('3')]));
        return CatalogCubit(useCase);
      },
      seed: () => CatalogState(
        status: CatalogStatus.success,
        loadMoreStatus: LoadMoreStatus.failure,
        query: 'nike',
        perPage: 1,
        pages: ProductPageAccumulator(
          products: [_product('1'), _product('2')],
          seenIds: const {'1', '2'},
          nextPage: 2,
        ),
      ),
      act: (cubit) => cubit.retry(),
      expect: () => [
        isA<CatalogState>().having(
          (s) => s.loadMoreStatus,
          'loadMoreStatus',
          LoadMoreStatus.loading,
        ),
        isA<CatalogState>()
            .having(
              (s) => s.loadMoreStatus,
              'loadMoreStatus',
              LoadMoreStatus.idle,
            )
            .having((s) => s.products.map((p) => p.id), 'products', [
              '1',
              '2',
              '3',
            ]),
      ],
      verify: (_) => expect(captured().page, 2),
    );
  });

  group('setLanguage', () {
    blocTest<CatalogCubit, CatalogState>(
      'the same code emits nothing',
      build: () => CatalogCubit(useCase),
      act: (cubit) => cubit.setLanguage(kDefaultLanguageCode),
      expect: () => <CatalogState>[],
    );

    blocTest<CatalogCubit, CatalogState>(
      'a different code updates the language without issuing a request',
      build: () => CatalogCubit(useCase),
      act: (cubit) => cubit.setLanguage('en'),
      expect: () => [
        isA<CatalogState>().having((s) => s.languageCode, 'languageCode', 'en'),
      ],
      verify: (_) =>
          verifyNever(() => useCase.call(params: any(named: 'params'))),
    );
  });

  // Ordering-sensitive: two overlapping requests must resolve in a chosen
  // order, which a single blocTest `act` cannot express against a use case
  // mocked to resolve immediately. These use a plain `test()` with one
  // `Completer` per call, queued in call order, so each request's result is
  // released independently.
  group('superseded requests', () {
    void mockSequence(List<Completer<Result<ProductSearchResult>>> queue) {
      final pending = List.of(queue);
      when(() => useCase.call(params: any(named: 'params')))
          .thenAnswer((_) => pending.removeAt(0).future);
    }

    test(
      'a late search result is dropped once a newer search has started',
      () async {
        final completerA = Completer<Result<ProductSearchResult>>();
        final completerB = Completer<Result<ProductSearchResult>>();
        mockSequence([completerA, completerB]);

        final cubit = CatalogCubit(useCase);
        addTearDown(cubit.close);
        final states = <CatalogState>[];
        final subscription = cubit.stream.listen(states.add);
        addTearDown(subscription.cancel);

        final futureA = cubit.search('a');
        final futureB = cubit.search('b');

        // The stale request resolves first, after the newer one is already
        // in flight.
        completerA.complete(_success([_product('a1')]));
        await futureA;

        completerB.complete(_success([_product('b1')]));
        await futureB;

        expect(cubit.state.status, CatalogStatus.success);
        expect(cubit.state.products.map((p) => p.id), ['b1']);
        expect(
          states.any((s) => s.products.map((p) => p.id).contains('a1')),
          isFalse,
          reason: "'a's late products must never appear, even transiently",
        );
      },
    );

    test('a late search failure is dropped once a newer search already '
        'succeeded', () async {
      final completerA = Completer<Result<ProductSearchResult>>();
      final completerB = Completer<Result<ProductSearchResult>>();
      mockSequence([completerA, completerB]);

      final cubit = CatalogCubit(useCase);
      addTearDown(cubit.close);
      final states = <CatalogState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);

      final futureA = cubit.search('a');
      final futureB = cubit.search('b');

      completerB.complete(_success([_product('b1')]));
      await futureB;

      // The stale request fails after the newer one already succeeded.
      completerA.complete(const Result.error(_failure));
      await futureA;

      expect(cubit.state.status, CatalogStatus.success);
      expect(cubit.state.products.map((p) => p.id), ['b1']);
      expect(
        states.any((s) => s.status == CatalogStatus.failure),
        isFalse,
        reason: 'a superseded failure must never surface',
      );
    });

    test('a late loadMore result is dropped once a sort change restarted the '
        'results', () async {
      final completerFirst = Completer<Result<ProductSearchResult>>();
      final completerLoadMore = Completer<Result<ProductSearchResult>>();
      final completerSort = Completer<Result<ProductSearchResult>>();
      mockSequence([completerFirst, completerLoadMore, completerSort]);

      final cubit = CatalogCubit(useCase);
      addTearDown(cubit.close);

      final searchFuture = cubit.search('nike');
      // A full page (perPage products) so `hasReachedEnd` stays false and
      // `loadMore` is allowed to run.
      final firstPage = List.generate(kDefaultPerPage, (i) => _product('$i'));
      completerFirst.complete(_success(firstPage));
      await searchFuture;

      final loadMoreFuture = cubit.loadMore();
      expect(cubit.state.loadMoreStatus, LoadMoreStatus.loading);

      final sortFuture = cubit.changeSort(ProductSort.priceAsc);
      // changeSort already resets loadMoreStatus to idle for the new
      // ordering, before the stale loadMore result ever arrives.
      expect(cubit.state.loadMoreStatus, LoadMoreStatus.idle);

      completerLoadMore.complete(_success([_product('3')], page: 2));
      await loadMoreFuture;

      expect(
        cubit.state.loadMoreStatus,
        LoadMoreStatus.idle,
        reason: 'the dropped result must not overwrite the reset status',
      );
      expect(cubit.state.products.any((p) => p.id == '3'), isFalse);

      completerSort.complete(_success([_product('9')]));
      await sortFuture;

      expect(cubit.state.status, CatalogStatus.success);
      expect(cubit.state.products.map((p) => p.id), ['9']);
    });
  });
}
