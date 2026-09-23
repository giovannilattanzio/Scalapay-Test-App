import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

/// Row of trailing-aligned chips above the results: "Filtri" then "Ordina".
/// Fixed above the scrolling results (see `CatalogView`), not part of them.
class CatalogToolbar extends StatelessWidget {
  const CatalogToolbar({super.key, this.onFiltersPressed, this.onSortPressed});

  final VoidCallback? onFiltersPressed;
  final VoidCallback? onSortPressed;

  // Figma: 58 = 8 padding above and below a 42-high chip row. Kept as a
  // minimum rather than a fixed height: at a large text scale the chip's tap
  // box already grows past 42 to stay at least 44 tall (see
  // `ScalapayFilterChip`), and a fixed height would clip it.
  static const _rowHeight = 58.0;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _rowHeight),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: t.spacing.s),
        // Both chips keep their natural, unscaled-down size so their labels
        // stay readable at any text scale; on a narrow screen at a large
        // scale two of them together no longer fit the available width. A
        // `Wrap` lets "Ordina" move to a second line instead of overflowing
        // (rejected: a horizontal scroll view, which would hide "Filtri" off
        // screen). `alignment: end` keeps a single row trailing-aligned
        // exactly like the previous `Row`'s `MainAxisAlignment.end`;
        // `runAlignment`/`crossAxisAlignment: center` keep that one row (or,
        // wrapped, both rows together) vertically centered in the box
        // `ConstrainedBox` grows to at least 58 for, the same way `Row`'s own
        // default cross-axis centering did within the previous fixed height.
        // Unlike `Row`, `Wrap` never claims the full width on its own (it has
        // no `mainAxisSize`): without `SizedBox(width: double.infinity)`
        // forcing it to, this `Column` child (its default
        // `crossAxisAlignment` is `center`, not `stretch`) would size the
        // `Wrap` to its own content and center *that* horizontally, leaving
        // `alignment: end` nothing to trail against.
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.end,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              ScalapayFilterChip(
                label: 'catalog.filters'.tr(),
                icon: ScalapayIconData.filter,
                onPressed: onFiltersPressed,
              ),
              ScalapayFilterChip(
                label: 'catalog.sort'.tr(),
                icon: ScalapayIconData.order,
                onPressed: onSortPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
