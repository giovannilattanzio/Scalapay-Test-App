import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'golden_utils.dart';

const _italian = Locale('it');

/// Stand-in for a product photo: no network or assets in goldens.
const _image = SizedBox(
  width: 130,
  height: 90,
  child: DecoratedBox(
    decoration: BoxDecoration(
      color: Color(0xFF272727),
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
  ),
);

void main() {
  setUpAll(loadPoppins);

  testWidgets('with installments and connector', (t) async {
    await expectGolden(
      t,
      const ScalapayProductCard(
        image: _image,
        name: 'Nike - Revolution 6 Next Nature',
        store: 'Pittarello',
        price: 85,
        currency: '€',
        priceConnector: 'oppure',
        installmentCount: 3,
        installmentAmount: 23.33,
        installmentLabel: 'rate da',
      ),
      'product_card_installments',
      width: 164,
      locale: _italian,
    );
  });

  testWidgets('long texts', (t) async {
    await expectGolden(
      t,
      const ScalapayProductCard(
        image: _image,
        name: 'Nike - Revolution 6 Next Nature Triple Black Limited Edition',
        store: 'Pittarello Sport Centro Commerciale Grande',
        price: 1234.5,
        currency: '€',
        priceConnector: 'oppure',
        installmentCount: 12,
        installmentAmount: 1234.56,
        installmentLabel: 'rate mensili da',
      ),
      'product_card_long_texts',
      width: 164,
      locale: _italian,
    );
  });

  testWidgets('without installments', (t) async {
    await expectGolden(
      t,
      const ScalapayProductCard(
        image: _image,
        name: 'Nike - Court Vision Low',
        store: 'Pittarello',
        price: 79.99,
        currency: '€',
        priceConnector: 'oppure',
      ),
      'product_card_no_installments',
      width: 164,
      locale: _italian,
    );
  });
}
