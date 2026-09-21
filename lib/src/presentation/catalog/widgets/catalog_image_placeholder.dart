import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

/// Neutral placeholder shown in place of a product image while it loads or if
/// it fails to load, so a slow or broken network image never surfaces
/// Flutter's default spinner or broken-image icon inside the card.
class CatalogImagePlaceholder extends StatelessWidget {
  const CatalogImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: context.tokens.colors.surface);
  }
}
