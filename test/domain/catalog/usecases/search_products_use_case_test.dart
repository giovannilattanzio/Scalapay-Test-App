import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

class _MockProductRepository extends Mock implements IProductRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const ProductSearchParams(query: 'fallback'));
  });

  late _MockProductRepository repository;
  late SearchProductsUseCase useCase;

  setUp(() {
    repository = _MockProductRepository();
    useCase = SearchProductsUseCase(repository);
  });

  const product1 = Product(
    id: '1',
    name: 'a',
    store: 'store',
    brand: 'brand',
    imageUrl: 'url',
    sellingPrice: 10,
    listPrice: 10,
  );
  const product2 = Product(
    id: '2',
    name: 'b',
    store: 'store',
    brand: 'brand',
    imageUrl: 'url',
    sellingPrice: 20,
    listPrice: 20,
  );

  test('ProductSearchParams defaults page, perPage and languageCode', () {
    const params = ProductSearchParams(query: 'x');

    expect(params.page, 1);
    expect(params.perPage, 30);
    expect(params.languageCode, 'it');
  });

  test('passes the params to the repository unchanged', () async {
    const params = ProductSearchParams(query: 'nike');
    const result = Result<ProductSearchResult>.success(
      ProductSearchResult(products: [product1, product2], page: 1),
    );
    when(() => repository.searchProducts(any()))
        .thenAnswer((_) async => result);

    await useCase.call(params: params);

    final captured =
        verify(() => repository.searchProducts(captureAny())).captured.single
            as ProductSearchParams;
    expect(captured, params);
  });

  test('preserves the exact product order from the repository', () async {
    const params = ProductSearchParams(query: 'nike');
    const result = Result<ProductSearchResult>.success(
      ProductSearchResult(products: [product2, product1], page: 1),
    );
    when(() => repository.searchProducts(any()))
        .thenAnswer((_) async => result);

    final actual = await useCase.call(params: params);

    expect(actual.ok!.products, [product2, product1]);
  });

  test('returns a failure result unchanged', () async {
    const params = ProductSearchParams(query: 'nike');
    const failure = ServerFailure(message: 'boom');
    const result = Result<ProductSearchResult>.error(failure);
    when(() => repository.searchProducts(any()))
        .thenAnswer((_) async => result);

    final actual = await useCase.call(params: params);

    expect(actual.isError, isTrue);
    expect(actual.failure, failure);
  });
}
