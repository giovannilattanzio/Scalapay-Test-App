import 'package:flutter/material.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'catalog_product_tile.dart';

/// Grid of product cards, as a sliver so it can sit inside the catalog
/// page's `CustomScrollView`: two columns on a phone (more on a wide
/// viewport) at the default text scale, fewer — down to one on a phone — as
/// the system text scale grows, since the maximum cell width scales with it.
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
  // portion and from a text scale factor for the text portion keeps the two
  // growing independently, matching how the card itself lays out.
  //
  // That scaled estimate alone stopped being enough once the column stayed
  // as narrow as it is at the default scale: at a large text scale the
  // installments line (no `maxLines` of its own in `ScalapayProductCard`)
  // could wrap onto an extra line the estimate did not budget for. Rather
  // than measuring every product's real text — a `TextPainter` layout per
  // product on every scroll frame, cell heights jumping when a page with a
  // longer name or amount arrives, and a copy of the card's paddings, styles
  // and money formatting into the app that drifts silently if the card
  // changes — `maxCrossAxisExtent` itself grows with the text scale instead,
  // so a phone gets one wider column at a large scale and the installments
  // line has the width to stay on one line, the same way it already does at
  // the default scale. `_cellWidth` mirrors this so the height estimate
  // below matches the width a card actually gets.
  static const _imageAspectRatio = 195 / 164;
  static const _textBlockHeight = 154.0;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // `TextScaler.scale` takes a **font size**, not a layout length: on
    // Android 14+ the system scaler is non-linear (small font sizes roughly
    // double, large inputs are barely scaled at all), so calling it directly
    // on `_maxCrossAxisExtent`/`_textBlockHeight` (170-220, well past a font
    // size) used to come back almost unscaled there, while the card's own
    // 12-14px text still roughly doubled — the grid stayed two columns and
    // the card overflowed. A single scale *factor*, derived from how much
    // the scaler actually grows the font sizes `ScalapayProductCard` renders
    // (`t.typography.p3/p4/p2`, the styles its name, store, price and
    // installments lines use), then applied to the layout lengths below,
    // works on both a linear and this non-linear curve: with
    // `TextScaler.linear`, `scale(fontSize) / fontSize` is that same
    // constant factor for every font size, so this is unchanged from before.
    final textScaler = MediaQuery.textScalerOf(context);
    final factor = [t.typography.p3, t.typography.p4, t.typography.p2]
        .map((style) => textScaler.scale(style.fontSize!) / style.fontSize!)
        .reduce((a, b) => a > b ? a : b);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: _crossAxisSpacing),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final maxCrossAxisExtent = _maxCrossAxisExtent * factor;
          final cellWidth = _cellWidth(
            constraints.crossAxisExtent,
            maxCrossAxisExtent,
          );
          // The literal 154 from Figma is a hair short of what the card
          // actually needs once real font metrics are laid out (measured:
          // ~1px short at the base text scale, ~15px short at 1.5x), so a
          // token-sized cushion is folded into the same scaled quantity
          // rather than left as an unscaled fixed addition, which would
          // under-cover it again at a still larger text scale.
          final textBlockHeight = (_textBlockHeight + t.spacing.s) * factor;
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCrossAxisExtent,
              crossAxisSpacing: _crossAxisSpacing,
              mainAxisSpacing: 0,
              mainAxisExtent: cellWidth * _imageAspectRatio + textBlockHeight,
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
  /// [maxCrossAxisExtent] is the (possibly text-scaled) value passed to the
  /// delegate, not the unscaled [_maxCrossAxisExtent] constant.
  double _cellWidth(double crossAxisExtent, double maxCrossAxisExtent) {
    final columns = (crossAxisExtent / (maxCrossAxisExtent + _crossAxisSpacing))
        .ceil();
    final usableExtent = crossAxisExtent - _crossAxisSpacing * (columns - 1);
    return usableExtent / columns;
  }
}
