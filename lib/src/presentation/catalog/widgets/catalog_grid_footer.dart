import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import '../cubit/catalog_state.dart';

/// Sliver shown below the product grid while appending further pages.
///
/// Figma has no footer at all: a spinner appears only while a page is being
/// fetched, a message and a retry button only if that fetch failed, and
/// nothing whatsoever while idle or once the catalogue is exhausted (an
/// "end of list" banner was not asked for).
class CatalogGridFooter extends StatelessWidget {
  const CatalogGridFooter({super.key, required this.status, this.onRetry});

  final LoadMoreStatus status;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final child = switch (status) {
      LoadMoreStatus.loading => Padding(
        padding: EdgeInsets.all(t.spacing.s),
        child: Center(
          child: CircularProgressIndicator(
            color: t.colors.primary,
            semanticsLabel: 'catalog.loading'.tr(),
          ),
        ),
      ),
      LoadMoreStatus.failure => Padding(
        padding: EdgeInsets.all(t.spacing.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                'catalog.load_more_error'.tr(),
                textAlign: TextAlign.center,
                style: t.typography.p4.copyWith(color: t.colors.textSecondary),
              ),
            ),
            SizedBox(height: t.spacing.xs),
            ScalapayButton(label: 'catalog.retry'.tr(), onPressed: onRetry),
          ],
        ),
      ),
      LoadMoreStatus.idle ||
      LoadMoreStatus.exhausted => const SizedBox.shrink(),
    };
    // This sliver, not the grid's, is the one that actually ends the
    // scrolling area in the success state (it always follows the grid, even
    // when it renders nothing of its own), so the bottom system inset is
    // reserved here so the grid's last row can still be scrolled fully above
    // the home indicator instead of ending up permanently under it.
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: child,
      ),
    );
  }
}
