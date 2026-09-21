import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

enum _Sort { priceAsc, priceDesc, nameAsc, nameDesc }

const _sortOptions = <_Sort, String>{
  _Sort.priceAsc: 'Prezzo crescente',
  _Sort.priceDesc: 'Prezzo decrescente',
  _Sort.nameAsc: 'Nome A-Z',
  _Sort.nameDesc: 'Nome Z-A',
};

ScalapayFiltersBottomSheet _filters(
  BuildContext context, {
  TextEditingController? min,
  TextEditingController? max,
}) {
  // Empty means "no error" (null): the knob has no dedicated on/off toggle,
  // so an empty string is how this use case represents the caller passing
  // no message at all.
  final priceError = context.knobs.string(
    label: 'Price error',
    initialValue: '',
  );
  return ScalapayFiltersBottomSheet(
    title: context.knobs.string(label: 'Title', initialValue: 'Filtri'),
    priceTitle: context.knobs.string(
      label: 'Price title',
      initialValue: 'Fascia di prezzo',
    ),
    minLabel: context.knobs.string(label: 'Min label', initialValue: 'Minimo'),
    maxLabel: context.knobs.string(label: 'Max label', initialValue: 'Massimo'),
    clearLabel: context.knobs.string(
      label: 'Clear label',
      initialValue: 'Cancella tutto',
    ),
    applyLabel: context.knobs.string(
      label: 'Apply label',
      initialValue: 'Mostra risultati',
    ),
    minController: min,
    maxController: max,
    priceError: priceError.isEmpty ? null : priceError,
    onClose: () {},
    onClear: () {},
    onApply: () {},
  );
}

@widgetbook.UseCase(name: 'Empty', type: ScalapayFiltersBottomSheet)
Widget filtersEmpty(BuildContext context) =>
    Align(alignment: Alignment.bottomCenter, child: _filters(context));

@widgetbook.UseCase(name: 'Filled', type: ScalapayFiltersBottomSheet)
Widget filtersFilled(BuildContext context) => Align(
  alignment: Alignment.bottomCenter,
  child: _filters(
    context,
    min: TextEditingController(text: '150'),
    max: TextEditingController(text: '2000'),
  ),
);

@widgetbook.UseCase(name: 'Open as modal', type: ScalapayFiltersBottomSheet)
Widget filtersModal(BuildContext context) => Center(
  child: ScalapayButton(
    label: 'Open filters',
    onPressed: () => ScalapayFiltersBottomSheet.show(
      context,
      title: 'Filtri',
      priceTitle: 'Fascia di prezzo',
      minLabel: 'Minimo',
      maxLabel: 'Massimo',
      clearLabel: 'Cancella tutto',
      applyLabel: 'Mostra risultati',
      onClear: () {},
      onApply: () {},
    ),
  ),
);

@widgetbook.UseCase(name: 'Selected option', type: ScalapaySortBottomSheet)
Widget sortSelected(BuildContext context) => Align(
  alignment: Alignment.bottomCenter,
  child: ScalapaySortBottomSheet<_Sort>(
    title: context.knobs.string(label: 'Title', initialValue: 'Ordina'),
    options: _sortOptions,
    selected: context.knobs.object.dropdown<_Sort>(
      label: 'Selected',
      options: _Sort.values,
      initialOption: _Sort.priceAsc,
      labelBuilder: (value) => _sortOptions[value]!,
    ),
    onChanged: (_) {},
    onClose: () {},
  ),
);

@widgetbook.UseCase(name: 'Open as modal', type: ScalapaySortBottomSheet)
Widget sortModal(BuildContext context) => Center(
  child: ScalapayButton(
    label: 'Open sort',
    onPressed: () => ScalapaySortBottomSheet.show<_Sort>(
      context,
      title: 'Ordina',
      options: _sortOptions,
      selected: _Sort.priceAsc,
    ),
  ),
);
