import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Empty', type: ScalapaySearchField)
Widget searchFieldEmpty(BuildContext context) => Padding(
  padding: EdgeInsets.all(context.tokens.spacing.s),
  child: ScalapaySearchField(
    hint: context.knobs.string(
      label: 'Hint',
      initialValue: 'Cerca brand o negozi',
    ),
    onSubmitted: (_) {},
  ),
);

@widgetbook.UseCase(name: 'With text', type: ScalapaySearchField)
Widget searchFieldFilled(BuildContext context) => Padding(
  padding: EdgeInsets.all(context.tokens.spacing.s),
  child: ScalapaySearchField(
    controller: TextEditingController(text: 'Nike'),
    onSubmitted: (_) {},
  ),
);
