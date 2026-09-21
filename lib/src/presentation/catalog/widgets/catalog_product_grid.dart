import 'package:flutter/material.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'catalog_product_tile.dart';

/// Two-column (more on a wide viewport) grid of product cards, as a sliver so
/// it can sit inside the catalog page's `CustomScrollView`.
class CatalogProductGrid extends StatelessWidget {
  const CatalogProductGrid({super.key, required this.products});

  final List<Product> products;

  static const _maxCrossAxisExtent = 220.0;
  static const _crossAxisSpacing = 16.0;

  // Figma's card: a 164-wide, 195-high image area (a fixed proportion of the
  // cell width) followed by a 154-high text block, measured at the default
  // text scale. A delegate with a fixed `childAspectRatio` would scale that
  // text block by the same factor as the image, so raising the system font
  // size would make the text taller than its cell and overflow the card.
  // Deriving `mainAxisExtent` from the actual cell width for the image
  // portion and from `textScaler.scale` for the text portion keeps the two
  // growing independently, matching how the card itself lays out.
  static const _imageAspectRatio = 195 / 164;
  static const _textBlockHeight = 154.0;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: _crossAxisSpacing),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final textScaler = MediaQuery.textScalerOf(context);
          final cellWidth = _cellWidth(constraints.crossAxisExtent);
          // The literal 154 from Figma is a hair short of what the card
          // actually needs once real font metrics are laid out (measured:
          // ~1px short at the base text scale, ~15px short at 1.5x), so a
          // token-sized cushion is folded into the same scaled quantity
          // rather than left as an unscaled fixed addition, which would
          // under-cover it again at a still larger text scale.
          final textBlockHeight = _textBlockHeight + t.spacing.s;
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: _maxCrossAxisExtent,
              crossAxisSpacing: _crossAxisSpacing,
              mainAxisSpacing: 0,
              mainAxisExtent:
                  cellWidth * _imageAspectRatio +
                  textScaler.scale(textBlockHeight),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => CatalogProductTile(product: products[index]),
              childCount: products.length,
            ),
          );
        },
      ),
    );
  }

  /// Mirrors `SliverGridDelegateWithMaxCrossAxisExtent`'s own column count and
  /// cell width formula: the delegate does not expose either, so this is the
  /// only way to know the width a card will actually get before it does.
  double _cellWidth(double crossAxisExtent) {
    final columns =
        (crossAxisExtent / (_maxCrossAxisExtent + _crossAxisSpacing)).ceil();
    final usableExtent = crossAxisExtent - _crossAxisSpacing * (columns - 1);
    return usableExtent / columns;
  }
}
