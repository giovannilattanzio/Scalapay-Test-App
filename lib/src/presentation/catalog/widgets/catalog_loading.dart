import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

/// Centered progress indicator, in the primary brand color, used while the
/// first page of a search is loading.
class CatalogLoading extends StatelessWidget {
  const CatalogLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: context.tokens.colors.primary,
        semanticsLabel: 'catalog.loading'.tr(),
      ),
    );
  }
}
