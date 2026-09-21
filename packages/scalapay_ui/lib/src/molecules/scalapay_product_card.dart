import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/theme.dart';

/// Product card: an image area followed by the product name, the store, the
/// price and, optionally, an installments line.
///
/// Every value comes from the caller. The card only formats money (price and
/// installment amount, two decimals, number conventions of the surrounding
/// app's locale, [currency] as the symbol) and composes the installments line
/// as `<installmentCount> <installmentLabel> <installmentAmount>`.
///
/// [installmentCount] and [installmentAmount] come together, and
/// [installmentLabel] is required when both are given. [priceConnector] (for
/// example "or") follows the price only when the installments line is shown.
class ScalapayProductCard extends StatelessWidget {
  const ScalapayProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.store,
    required this.price,
    this.currency,
    this.priceConnector,
    this.installmentCount,
    this.installmentAmount,
    this.installmentLabel,
  }) : assert(
         (installmentCount == null) == (installmentAmount == null),
         'installmentCount and installmentAmount must be provided together',
       ),
       assert(
         installmentCount == null || installmentLabel != null,
         'installmentLabel is required when installmentCount and '
         'installmentAmount are provided',
       );

  /// Image shown centered in the rounded area (for example `Image.network`
  /// with `BoxFit.contain`). The area clips it.
  final Widget image;
  final String name;
  final String store;
  final double price;

  /// Currency symbol used for [price] and [installmentAmount]. Without it the
  /// amounts are plain numbers.
  final String? currency;

  /// Text after the price, shown only with the installments line.
  final String? priceConnector;
  final int? installmentCount;
  final double? installmentAmount;
  final String? installmentLabel;

  // Proportion of the image area in the design (164 x 195).
  static const _imageAspectRatio = 164 / 195;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final locale = Localizations.localeOf(context).toString();
    final money = currency == null
        ? NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 2)
        : NumberFormat.currency(
            locale: locale,
            symbol: currency,
            decimalDigits: 2,
          );

    final count = installmentCount;
    final amount = installmentAmount;
    final hasInstallments = count != null && amount != null;
    final connector = priceConnector;
    final priceLine = hasInstallments && connector != null
        ? '${money.format(price)} $connector'
        : money.format(price);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: _imageAspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(t.radius.image),
            child: ColoredBox(
              color: t.colors.surface,
              child: Padding(
                padding: EdgeInsets.all(t.spacing.xs),
                child: Center(child: image),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            t.spacing.xs,
            t.spacing.xs * 1.5,
            t.spacing.xs,
            t.spacing.xs * 1.5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.typography.p3.copyWith(color: t.colors.textPrimary),
              ),
              SizedBox(height: t.spacing.xs / 2),
              Text(
                store,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.typography.p4.copyWith(color: t.colors.textStoreName),
              ),
              SizedBox(height: t.spacing.xs),
              Text(
                priceLine,
                style: t.typography.p4.copyWith(color: t.colors.textSecondary),
              ),
              if (hasInstallments)
                Text(
                  '$count ${installmentLabel ?? ''} ${money.format(amount)}',
                  style: t.typography.p2.copyWith(color: t.colors.primary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
