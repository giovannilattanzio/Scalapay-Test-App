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
      image: Image.network(
        product.imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) =>
            loadingProgress == null ? child : const CatalogImagePlaceholder(),
        errorBuilder: (context, error, stackTrace) =>
            const CatalogImagePlaceholder(),
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
}
