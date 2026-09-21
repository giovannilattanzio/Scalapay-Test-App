import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Empty', type: ScalapayTextField)
Widget textFieldEmpty(BuildContext context) => Padding(
  padding: EdgeInsets.all(context.tokens.spacing.s),
  child: ScalapayTextField(
    label: context.knobs.string(label: 'Label', initialValue: 'Minimo'),
    keyboardType: TextInputType.number,
  ),
);

@widgetbook.UseCase(name: 'Filled (floated label)', type: ScalapayTextField)
Widget textFieldFilled(BuildContext context) => Padding(
  padding: EdgeInsets.all(context.tokens.spacing.s),
  child: ScalapayTextField(
    label: 'Minimo',
    controller: TextEditingController(text: '150'),
    keyboardType: TextInputType.number,
  ),
);

@widgetbook.UseCase(name: 'Error', type: ScalapayTextField)
Widget textFieldError(BuildContext context) => Padding(
  padding: EdgeInsets.all(context.tokens.spacing.s),
  child: ScalapayTextField(
    label: 'Minimo',
    controller: TextEditingController(text: 'abc'),
    errorText: context.knobs.string(
      label: 'Error',
      initialValue: 'Valore non valido',
    ),
  ),
);
