import 'package:bloc/bloc.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

import 'catalog_state.dart';

/// Drives the catalog screen: runs searches, tracks the applied sort and
/// price filter, and appends further pages as the user scrolls.
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._searchProducts) : super(const CatalogState());

  final SearchProductsUseCase _searchProducts;

  /// Called from the widget tree on every dependency change, so it must stay
  /// cheap and a no-op when the language has not actually changed. Does not
  /// re-run the current search: a language switch is applied to the next
  /// request the user triggers.
  void setLanguage(String languageCode) {
    if (languageCode == state.languageCode) return;
    emit(state.copyWith(languageCode: languageCode));
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    emit(
      state.copyWith(
        query: trimmed,
        status: CatalogStatus.loading,
        pages: const ProductPageAccumulator(),
        loadMoreStatus: LoadMoreStatus.idle,
        failure: null,
      ),
    );
    await _loadFirstPage();
  }

  Future<void> changeSort(ProductSort sort) async {
    if (sort == state.sort) return;

    emit(
      state.copyWith(
        sort: sort,
        status: CatalogStatus.loading,
        pages: const ProductPageAccumulator(),
        loadMoreStatus: LoadMoreStatus.idle,
        failure: null,
      ),
    );
    await _loadFirstPage();
  }

  /// An inverted range is left for the filter sheet to show; validating it
  /// here (rather than in the sheet) is what keeps that organism
  /// content-only, so no request leaves the app for a range the service
  /// would just misinterpret.
  Future<void> applyPriceRange(PriceRange range) async {
    if (range.isInverted) return;

    emit(
      state.copyWith(
        priceRange: range,
        status: CatalogStatus.loading,
        pages: const ProductPageAccumulator(),
        loadMoreStatus: LoadMoreStatus.idle,
        failure: null,
      ),
    );
    await _loadFirstPage();
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore) return;
    await _appendNextPage();
  }

  /// Resumes whichever request failed, with the same query, sort and price
  /// filter: a first-page failure redoes the search, an append failure
  /// redoes `loadMore` for the same page.
  Future<void> retry() async {
    if (state.status == CatalogStatus.failure) {
      emit(state.copyWith(status: CatalogStatus.loading, failure: null));
      await _loadFirstPage();
    } else if (state.loadMoreStatus == LoadMoreStatus.failure) {
      await _appendNextPage();
    }
  }

  Future<void> _loadFirstPage() async {
    final result = await _searchProducts(params: _paramsFor(kDefaultPage));
    result.fold(
      (searchResult) {
        final pages = state.pages.append(
          searchResult.products,
          perPage: state.perPage,
        );
        emit(
          state.copyWith(
            status: pages.products.isEmpty
                ? CatalogStatus.empty
                : CatalogStatus.success,
            pages: pages,
          ),
        );
      },
      (failure) =>
          emit(state.copyWith(status: CatalogStatus.failure, failure: failure)),
    );
  }

  /// The accumulator, not this method, decides whether the fetched page was
  /// new or a repeat of one already seen (the service's only end-of-list
  /// signal, see `ProductPageAccumulator`). A failure here only ever touches
  /// `loadMoreStatus`, leaving `status` and the product list already on
  /// screen untouched.
  Future<void> _appendNextPage() async {
    emit(state.copyWith(loadMoreStatus: LoadMoreStatus.loading));
    final result = await _searchProducts(
      params: _paramsFor(state.pages.nextPage),
    );
    result.fold(
      (searchResult) {
        final pages = state.pages.append(
          searchResult.products,
          perPage: state.perPage,
        );
        emit(
          state.copyWith(
            pages: pages,
            loadMoreStatus: pages.hasReachedEnd
                ? LoadMoreStatus.exhausted
                : LoadMoreStatus.idle,
          ),
        );
      },
      (failure) => emit(state.copyWith(loadMoreStatus: LoadMoreStatus.failure)),
    );
  }

  ProductSearchParams _paramsFor(int page) => ProductSearchParams(
    query: state.query,
    sort: state.sort,
    priceRange: state.priceRange,
    languageCode: state.languageCode,
    page: page,
    perPage: state.perPage,
  );
}
