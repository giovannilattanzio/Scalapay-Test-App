import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

/// Row of trailing-aligned chips above the results: "Filtri" then "Ordina".
/// Fixed above the scrolling results (see `CatalogView`), not part of them.
class CatalogToolbar extends StatelessWidget {
  const CatalogToolbar({super.key, this.onFiltersPressed, this.onSortPressed});

  final VoidCallback? onFiltersPressed;
  final VoidCallback? onSortPressed;

  // Figma: 58 = 8 padding above and below a 42-high chip row.
  static const _rowHeight = 58.0;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      height: _rowHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: t.spacing.s),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ScalapayFilterChip(
              label: 'catalog.filters'.tr(),
              icon: ScalapayIconData.filter,
              onPressed: onFiltersPressed,
            ),
            SizedBox(width: t.spacing.xs),
            ScalapayFilterChip(
              label: 'catalog.sort'.tr(),
              icon: ScalapayIconData.order,
              onPressed: onSortPressed,
            ),
          ],
        ),
      ),
    );
  }
}
