import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ScalapayFilterChip)
Widget filterChipDefault(BuildContext context) => Center(
  child: ScalapayFilterChip(
    label: context.knobs.string(label: 'Label', initialValue: 'Filtri'),
    icon: context.knobs.object.dropdown(
      label: 'Icon',
      options: ScalapayIconData.values,
      initialOption: ScalapayIconData.filter,
      labelBuilder: (icon) => icon.name,
    ),
    onPressed: () {},
  ),
);

@widgetbook.UseCase(name: 'Filtri and Ordina', type: ScalapayFilterChip)
Widget filterChipPair(BuildContext context) {
  final t = context.tokens;
  return Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScalapayFilterChip(
          label: 'Filtri',
          icon: ScalapayIconData.filter,
          onPressed: () {},
        ),
        SizedBox(width: t.spacing.xs),
        ScalapayFilterChip(
          label: 'Ordina',
          icon: ScalapayIconData.order,
          onPressed: () {},
        ),
      ],
    ),
  );
}
