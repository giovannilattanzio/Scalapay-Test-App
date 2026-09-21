import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Selected', type: ScalapayRadio)
Widget radioSelected(BuildContext context) => Padding(
  padding: EdgeInsets.all(context.tokens.spacing.s),
  child: ScalapayRadio<int>(
    value: 1,
    groupValue: 1,
    label: 'Prezzo crescente',
    onChanged: (_) {},
  ),
);

@widgetbook.UseCase(name: 'Unselected', type: ScalapayRadio)
Widget radioUnselected(BuildContext context) => Padding(
  padding: EdgeInsets.all(context.tokens.spacing.s),
  child: ScalapayRadio<int>(
    value: 2,
    groupValue: 1,
    label: 'Prezzo decrescente',
    onChanged: (_) {},
  ),
);

@widgetbook.UseCase(name: 'Group', type: ScalapayRadio)
Widget radioGroup(BuildContext context) => const _RadioGroupDemo();

class _RadioGroupDemo extends StatefulWidget {
  const _RadioGroupDemo();

  @override
  State<_RadioGroupDemo> createState() => _RadioGroupDemoState();
}

class _RadioGroupDemoState extends State<_RadioGroupDemo> {
  static const _options = [
    'Prezzo crescente',
    'Prezzo decrescente',
    'Nome A-Z',
    'Nome Z-A',
  ];
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.tokens.spacing.s),
      child: Column(
        children: [
          for (var i = 0; i < _options.length; i++) ...[
            ScalapayRadio<int>(
              value: i,
              groupValue: _selected,
              label: _options[i],
              onChanged: (v) => setState(() => _selected = v),
            ),
            if (i < _options.length - 1) const ScalapayDivider(),
          ],
        ],
      ),
    );
  }
}
