import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import '../cubit/catalog_cubit.dart';
import '../cubit/catalog_state.dart';
import '../widgets/catalog_grid_footer.dart';
import '../widgets/catalog_header.dart';
import '../widgets/catalog_loading.dart';
import '../widgets/catalog_message.dart';
import '../widgets/catalog_product_grid.dart';
import '../widgets/catalog_toolbar.dart';

/// Entry point of the catalog screen: provides the `CatalogCubit` and wraps
/// [CatalogView], which owns the actual layout.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Built here rather than registered: this cubit belongs to this page
      // alone and has a single dependency, so a registration would only hide
      // that dependency behind a lookup.
      create: (_) => CatalogCubit(injector<SearchProductsUseCase>()),
      child: const CatalogView(),
    );
  }
}

/// Fixed header (title, search field and the filter/sort toolbar) plus a
/// scrolling area holding only the results. A control that changes *what*
/// the results are — not how far into them you are — stays reachable at any
/// scroll position, unlike in the Figma frame this groups the chip row with
/// the scrolling content, but a static mockup cannot show scroll behaviour.
///
/// A `StatefulWidget` only for the lifecycle objects it owns (the search
/// field's controller and the scroll controller) and for `didChangeDependencies`,
/// which is how an inherited-widget-driven value like the current locale is
/// meant to be read exactly once per dependency change.
class CatalogView extends StatefulWidget {
  const CatalogView({super.key});

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  // Owned for the lifetime of the view, not created per sheet open: the
  // bottom sheet's own closing transition still reads them for a moment
  // after `Navigator.pop`, since that future resolves as soon as the pop is
  // requested and not once the reverse animation finishes, so disposing them
  // right after `await`ing the sheet would dispose a controller a still
  // on-screen `TextField` is listening to.
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<CatalogCubit>().setLanguage(context.locale.languageCode);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  /// The listener only reports "the end is near"; whether that is allowed to
  /// start a request is entirely `CatalogState.canLoadMore`'s decision. A
  /// fling produces a burst of `ScrollUpdateNotification`s well before the
  /// first response can flip `loadMoreStatus` away from `idle`, so if this
  /// widget gated itself on some local flag it would still race the cubit;
  /// letting the cubit be the single source of truth removes the race
  /// instead of narrowing it.
  bool _handleScroll(
    ScrollUpdateNotification notification,
    CatalogCubit cubit,
  ) {
    final metrics = notification.metrics;
    final remaining = metrics.maxScrollExtent - metrics.pixels;
    if (remaining < metrics.viewportDimension) {
      cubit.loadMore();
    }
    return false;
  }

  Future<void> _openSort(CatalogCubit cubit) async {
    final currentSort = cubit.state.sort;
    final options = {
      for (final option in ProductSort.sheetOptions) option: _sortLabel(option),
    };
    final selected = await ScalapaySortBottomSheet.show<ProductSort>(
      context,
      title: 'sort.title'.tr(),
      options: options,
      selected: currentSort,
    );
    if (selected != null) cubit.changeSort(selected);
  }

  // Enumerated explicitly (no catch-all default) so a future sheet option
  // without a mapping fails loudly here instead of silently falling back.
  String _sortLabel(ProductSort sort) {
    if (sort == ProductSort.relevance) return 'sort.relevance'.tr();
    if (sort == ProductSort.priceAsc) return 'sort.price_asc'.tr();
    if (sort == ProductSort.priceDesc) return 'sort.price_desc'.tr();
    throw ArgumentError('No label for sort option: $sort');
  }

  /// `ScalapayFiltersBottomSheet.show` pops the sheet unconditionally right
  /// after calling the given `onApply`, so it cannot keep the sheet open to
  /// show an invalid range's error: the modal is driven directly through the
  /// design system's own `showScalapayModalSheet` (the same presentation
  /// `show` builds on) instead, popping only when the range is valid.
  Future<void> _openFilters(CatalogCubit cubit) async {
    final range = cubit.state.priceRange;
    final minController = _minPriceController..text = _formatBound(range.min);
    final maxController = _maxPriceController..text = _formatBound(range.max);

    await showScalapayModalSheet<void>(
      context,
      builder: (sheetContext) {
        String? errorMessage;
        return StatefulBuilder(
          builder: (context, setSheetState) => ScalapayFiltersBottomSheet(
            title: 'filters.title'.tr(),
            priceTitle: 'filters.price_title'.tr(),
            minLabel: 'filters.min'.tr(),
            maxLabel: 'filters.max'.tr(),
            clearLabel: 'filters.clear'.tr(),
            applyLabel: 'filters.apply'.tr(),
            minController: minController,
            maxController: maxController,
            priceError: errorMessage,
            onClose: () => Navigator.of(sheetContext).pop(),
            onClear: () => setSheetState(() {
              minController.clear();
              maxController.clear();
              errorMessage = null;
            }),
            onApply: () {
              final requested = PriceRange(
                min: double.tryParse(minController.text),
                max: double.tryParse(maxController.text),
              );
              if (requested.isInverted) {
                setSheetState(
                  () => errorMessage = 'filters.inverted_range'.tr(),
                );
                return;
              }
              cubit.applyPriceRange(requested);
              Navigator.of(sheetContext).pop();
            },
          ),
        );
      },
    );
  }

  String _formatBound(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  String _failureMessage(Failure? failure) => switch (failure) {
    NetworkFailure() => 'catalog.error_network'.tr(),
    ServerFailure() => 'catalog.error_server'.tr(),
    SerializationFailure() => 'catalog.error_parsing'.tr(),
    _ => 'catalog.error_generic'.tr(),
  };

  List<Widget> _resultSlivers(CatalogState state, CatalogCubit cubit) {
    switch (state.status) {
      case CatalogStatus.initial:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: CatalogMessage(message: 'catalog.initial'.tr()),
          ),
        ];
      case CatalogStatus.loading:
        return const [
          SliverFillRemaining(hasScrollBody: false, child: CatalogLoading()),
        ];
      case CatalogStatus.empty:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: CatalogMessage(
              message: 'catalog.empty'.tr(namedArgs: {'query': state.query}),
            ),
          ),
        ];
      case CatalogStatus.failure:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: CatalogMessage(
              message: _failureMessage(state.failure),
              actionLabel: 'catalog.retry'.tr(),
              onAction: cubit.retry,
            ),
          ),
        ];
      case CatalogStatus.success:
        return [
          CatalogProductGrid(products: state.products),
          CatalogGridFooter(status: state.loadMoreStatus, onRetry: cubit.retry),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CatalogCubit>();
    final state = context.watch<CatalogCubit>().state;

    return Scaffold(
      // Only the top inset stays on `SafeArea`: at the bottom, the platform
      // convention is for scrollable content to pass under the translucent
      // home indicator rather than stop above it, so that inset is handed to
      // the scrolling content instead (see `CatalogGridFooter`), which can
      // turn it into trailing space the last row still scrolls past.
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CatalogHeader(
              searchController: _searchController,
              onSearch: cubit.search,
            ),
            CatalogToolbar(
              onFiltersPressed: () => _openFilters(cubit),
              onSortPressed: () => _openSort(cubit),
            ),
            Expanded(
              child: NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) =>
                    _handleScroll(notification, cubit),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: _resultSlivers(state, cubit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
