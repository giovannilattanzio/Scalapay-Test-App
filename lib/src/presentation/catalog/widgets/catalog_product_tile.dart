import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'catalog_image_placeholder.dart';

/// One product card in [CatalogProductGrid], feeding the domain [Product]
/// into `ScalapayProductCard`.
class CatalogProductTile extends StatelessWidget {
  const CatalogProductTile({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ScalapayProductCard(
      // `ScalapayProductCard` centers `image` inside a padded box with loose
      // constraints, so `LayoutBuilder` reports the image area's width (the
      // constraint `Center` passes down) without needing to know the card's
      // layout. Decoding at that display size — converted to physical pixels
      // through the device pixel ratio — bounds each decoded image to the
      // area's physical width, so larger photos than today's cannot fill the
      // ~100 MB `ImageCache` within a page and force re-downloads on scroll
      // back (a 1000x1000 photo decodes to 4 MB, ~25 fitting the cache, vs.
      // today's 300x300, 360 KB, ~290 fitting it). Today's photos are already
      // smaller than the image area, so this is a safeguard: `ResizeImage`
      // never upscales past the source size. Only the width is passed:
      // `Image.network` resizes through `ResizeImage`, which preserves the
      // source aspect ratio, and `BoxFit.contain` means the area's width
      // already bounds the pixels needed.
      image: LayoutBuilder(
        builder: (context, constraints) => Image.network(
          product.imageUrl,
          fit: BoxFit.contain,
          cacheWidth: _cacheWidth(
            constraints.maxWidth,
            MediaQuery.devicePixelRatioOf(context),
          ),
          loadingBuilder: (context, child, loadingProgress) =>
              loadingProgress == null ? child : const CatalogImagePlaceholder(),
          errorBuilder: (context, error, stackTrace) =>
              const CatalogImagePlaceholder(),
        ),
      ),
      name: product.name,
      store: product.store,
      price: product.sellingPrice,
      currency: 'product.currency'.tr(),
      installmentCount: Product.installmentCount,
      installmentAmount: product.installmentAmount,
      installmentLabel: 'product.installment_connector'.tr(),
    );
  }

  /// Physical width of the image area, or null when the width is unbounded
  /// (the image is then decoded at its source size).
  static int? _cacheWidth(double maxWidth, double devicePixelRatio) =>
      maxWidth.isFinite ? (maxWidth * devicePixelRatio).round() : null;
}
