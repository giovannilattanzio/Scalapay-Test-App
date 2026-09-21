import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';

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

  testWidgets('initial status shows the initial message', (tester) async {
    seed(const CatalogState());
    await pumpApp(tester, const CatalogView(), cubit: cubit);

    expect(
      find.text('Cerca un brand o un negozio per iniziare'),
      findsOneWidget,
    );
  });

  testWidgets('loading status shows the loading indicator', (tester) async {
    seed(const CatalogState(status: CatalogStatus.loading));
    await pumpApp(tester, const CatalogView(), cubit: cubit);

    expect(find.byType(CatalogLoading), findsOneWidget);
  });

  testWidgets('success status shows the product grid', (tester) async {
    seed(
      CatalogState(
        status: CatalogStatus.success,
        pages: ProductPageAccumulator(
          products: [_product('1'), _product('2')],
          seenIds: const {'1', '2'},
        ),
      ),
    );
    await pumpApp(tester, const CatalogView(), cubit: cubit);

    expect(find.byType(CatalogProductGrid), findsOneWidget);
    expect(find.byType(CatalogProductTile), findsNWidgets(2));
  });

  testWidgets('empty status shows the empty message with the query', (
    tester,
  ) async {
    seed(const CatalogState(status: CatalogStatus.empty, query: 'nike'));
    await pumpApp(tester, const CatalogView(), cubit: cubit);

    expect(find.text('Nessun risultato per "nike"'), findsOneWidget);
  });

  testWidgets('failure status shows the mapped message and a retry control', (
    tester,
  ) async {
    seed(
      const CatalogState(
        status: CatalogStatus.failure,
        failure: NetworkFailure(message: 'boom'),
      ),
    );
    await pumpApp(tester, const CatalogView(), cubit: cubit);

    expect(
      find.text('Controlla la tua connessione e riprova.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Riprova'));
    verify(() => cubit.retry()).called(1);
  });

  testWidgets('a server failure maps to the server error copy', (tester) async {
    seed(
      const CatalogState(
        status: CatalogStatus.failure,
        failure: ServerFailure(message: 'boom'),
      ),
    );
    await pumpApp(tester, const CatalogView(), cubit: cubit);

    expect(
      find.text('Il servizio non è al momento disponibile. Riprova più tardi.'),
      findsOneWidget,
    );
  });

  testWidgets('a serialization failure maps to the parsing error copy', (
    tester,
  ) async {
    seed(
      const CatalogState(
        status: CatalogStatus.failure,
        failure: SerializationFailure(message: 'boom'),
      ),
    );
    await pumpApp(tester, const CatalogView(), cubit: cubit);

    expect(
      find.text('Non siamo riusciti a leggere i risultati. Riprova più tardi.'),
      findsOneWidget,
    );
  });

  testWidgets('any other failure maps to the generic error copy', (
    tester,
  ) async {
    seed(
      const CatalogState(
        status: CatalogStatus.failure,
        failure: UnknownFailure(message: 'boom'),
      ),
    );
    await pumpApp(tester, const CatalogView(), cubit: cubit);

    expect(find.text('Qualcosa è andato storto. Riprova.'), findsOneWidget);
  });

  testWidgets('submitting the search field calls cubit.search', (tester) async {
    seed(const CatalogState());
    await pumpApp(tester, const CatalogView(), cubit: cubit);

    await tester.enterText(find.byType(TextField), 'nike');
    await tester.testTextInput.receiveAction(TextInputAction.search);

    verify(() => cubit.search('nike')).called(1);
  });
}
