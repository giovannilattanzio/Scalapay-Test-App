import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Stand-in for a product photo, from tokens. Real screens pass their own
/// image, for example `Image.network(url, fit: BoxFit.contain)`.
Widget _placeholderImage(BuildContext context) {
  final t = context.tokens;
  return SizedBox(
    width: 130,
    height: 90,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.textPrimary,
        borderRadius: BorderRadius.circular(t.radius.image),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Default (knobs)', type: ScalapayProductCard)
Widget productCardDefault(BuildContext context) {
  final showInstallments = context.knobs.boolean(
    label: 'Show installments',
    initialValue: true,
  );
  final currency = context.knobs.string(label: 'Currency', initialValue: '€');
  return Center(
    child: SizedBox(
      width: 164,
      child: ScalapayProductCard(
        image: _placeholderImage(context),
        name: context.knobs.string(
          label: 'Name',
          initialValue: 'Nike - Revolution 6 Next Nature',
        ),
        store: context.knobs.string(label: 'Store', initialValue: 'Pittarello'),
        price: context.knobs.double.input(label: 'Price', initialValue: 85),
        currency: currency.isEmpty ? null : currency,
        priceConnector: context.knobs.string(
          label: 'Price connector',
          initialValue: 'or',
        ),
        installmentCount: showInstallments
            ? context.knobs.int.input(label: 'Installments', initialValue: 3)
            : null,
        installmentAmount: showInstallments
            ? context.knobs.double.input(
                label: 'Installment amount',
                initialValue: 23.33,
              )
            : null,
        installmentLabel: showInstallments
            ? context.knobs.string(
                label: 'Installments wording',
                initialValue: 'installments of',
              )
            : null,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Long texts', type: ScalapayProductCard)
Widget productCardLongTexts(BuildContext context) => Center(
  child: SizedBox(
    width: 164,
    child: ScalapayProductCard(
      image: _placeholderImage(context),
      name: 'Nike - Revolution 6 Next Nature Triple Black Limited Edition',
      store: 'Pittarello Sport Centro Commerciale Grande',
      price: 1234.5,
      currency: '€',
      priceConnector: 'or',
      installmentCount: 12,
      installmentAmount: 1234.56,
      installmentLabel: 'monthly installments of',
    ),
  ),
);

@widgetbook.UseCase(name: 'No installments', type: ScalapayProductCard)
Widget productCardNoInstallments(BuildContext context) => Center(
  child: SizedBox(
    width: 164,
    child: ScalapayProductCard(
      image: _placeholderImage(context),
      name: 'Nike - Court Vision Low',
      store: 'Pittarello',
      price: 79.99,
      currency: '€',
      priceConnector: 'or',
    ),
  ),
);

@widgetbook.UseCase(name: 'Italian locale', type: ScalapayProductCard)
Widget productCardItalian(BuildContext context) => Center(
  child: SizedBox(
    width: 164,
    child: Localizations.override(
      context: context,
      locale: const Locale('it'),
      child: ScalapayProductCard(
        image: _placeholderImage(context),
        name: 'Nike - Revolution 6 Next Nature',
        store: 'Pittarello',
        price: 1085,
        currency: '€',
        priceConnector: 'oppure',
        installmentCount: 3,
        installmentAmount: 361.67,
        installmentLabel: 'rate da',
      ),
    ),
  ),
);

@widgetbook.UseCase(name: 'Two-column grid', type: ScalapayProductCard)
Widget productCardGrid(BuildContext context) => Padding(
  padding: EdgeInsets.all(context.tokens.spacing.s),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: ScalapayProductCard(
          image: _placeholderImage(context),
          name: 'Nike - Revolution 6 Next Nature Triple Black',
          store: 'Pittarello',
          price: 85,
          currency: '€',
          priceConnector: 'or',
          installmentCount: 3,
          installmentAmount: 23.33,
          installmentLabel: 'installments of',
        ),
      ),
      SizedBox(width: context.tokens.spacing.s),
      Expanded(
        child: ScalapayProductCard(
          image: _placeholderImage(context),
          name: 'Nike - Court Vision Low Next',
          store: 'Pittarello',
          price: 79.99,
          currency: '€',
          priceConnector: 'or',
          installmentCount: 3,
          installmentAmount: 26.66,
          installmentLabel: 'installments of',
        ),
      ),
    ],
  ),
);
