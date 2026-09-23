import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

/// Fixed top section of the catalog screen: title then search field. Stays in
/// place while the results below it scroll.
class CatalogHeader extends StatelessWidget {
  const CatalogHeader({super.key, this.searchController, this.onSearch});

  final TextEditingController? searchController;
  final ValueChanged<String>? onSearch;

  /// The Figma frame reserves this much space between the status bar and the
  /// title for a back arrow, but the catalog screen is the app root and hides
  /// it. The slot still occupies the layout, so it is kept as its own named
  /// constant with this comment rather than a bare `SizedBox`, so nobody
  /// "fixes" it by deleting the gap.
  static const _hiddenBackArrowSlot = 57.0;

  // Measured on the Figma frame; neither has a spacing token.
  static const _titleHorizontalPadding = 26.0;
  static const _titleToSearchGap = 10.0;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: _hiddenBackArrowSlot),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _titleHorizontalPadding,
          ),
          child: Semantics(
            header: true,
            child: Text(
              'catalog.title'.tr(),
              style: t.typography.h2.copyWith(color: t.colors.textPrimary),
            ),
          ),
        ),
        const SizedBox(height: _titleToSearchGap),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: t.spacing.s),
          child: ScalapaySearchField(
            controller: searchController,
            hint: 'catalog.search_hint'.tr(),
            onSubmitted: onSearch,
          ),
        ),
      ],
    );
  }
}
