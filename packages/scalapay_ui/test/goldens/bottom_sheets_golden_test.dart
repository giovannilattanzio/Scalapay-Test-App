import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';
import 'package:flutter/widgets.dart';

import 'golden_utils.dart';

enum _Sort { priceAsc, priceDesc, nameAsc, nameDesc }

const _options = <_Sort, String>{
  _Sort.priceAsc: 'Prezzo crescente',
  _Sort.priceDesc: 'Prezzo decrescente',
  _Sort.nameAsc: 'Nome A-Z',
  _Sort.nameDesc: 'Nome Z-A',
};

ScalapayFiltersBottomSheet _filters({
  TextEditingController? min,
  TextEditingController? max,
  String? priceError,
}) => ScalapayFiltersBottomSheet(
  title: 'Filtri',
  priceTitle: 'Fascia di prezzo',
  minLabel: 'Minimo',
  maxLabel: 'Massimo',
  clearLabel: 'Cancella tutto',
  applyLabel: 'Mostra risultati',
  minController: min,
  maxController: max,
  priceError: priceError,
  onClose: () {},
  onClear: () {},
  onApply: () {},
);

ScalapaySortBottomSheet<_Sort> _sort(_Sort selected) =>
    ScalapaySortBottomSheet<_Sort>(
      title: 'Ordina',
      options: _options,
      selected: selected,
      onChanged: (_) {},
      onClose: () {},
    );

void main() {
  setUpAll(loadPoppins);

  testWidgets('filters empty', (t) async {
    await expectGolden(t, _filters(), 'filters_sheet_empty', width: 375);
  });

  testWidgets('filters filled', (t) async {
    await expectGolden(
      t,
      _filters(
        min: TextEditingController(text: '150'),
        max: TextEditingController(text: '2000'),
      ),
      'filters_sheet_filled',
      width: 375,
    );
  });

  testWidgets('filters with a price error', (t) async {
    await expectGolden(
      t,
      _filters(
        min: TextEditingController(text: '2000'),
        max: TextEditingController(text: '150'),
        priceError: 'Il minimo deve essere inferiore al massimo',
      ),
      'filters_sheet_error',
      width: 375,
    );
  });

  testWidgets('sort with the first option selected', (t) async {
    await expectGolden(
      t,
      _sort(_Sort.priceAsc),
      'sort_sheet_first_selected',
      width: 375,
    );
  });

  testWidgets('sort with another option selected', (t) async {
    await expectGolden(
      t,
      _sort(_Sort.nameAsc),
      'sort_sheet_other_selected',
      width: 375,
    );
  });
}
