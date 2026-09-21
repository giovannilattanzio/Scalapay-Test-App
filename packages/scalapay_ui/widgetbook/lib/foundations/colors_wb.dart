import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Tokens whose value is not (yet) confirmed by the Figma file.
const _placeholders = {'error', 'textDisabled'};

@widgetbook.UseCase(name: 'All colors', type: ScalapayColors)
Widget colorsUseCase(BuildContext context) {
  final t = context.tokens;
  return ListView(
    padding: EdgeInsets.all(t.spacing.s),
    children: [
      for (final entry in t.colors.entries.entries)
        Padding(
          padding: EdgeInsets.only(bottom: t.spacing.xs),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: entry.value,
                  borderRadius: BorderRadius.circular(t.radius.child),
                  border: Border.all(color: t.colors.border),
                ),
              ),
              SizedBox(width: t.spacing.s),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: t.typography.p3.copyWith(
                      color: t.colors.textPrimary,
                    ),
                  ),
                  Text(
                    '#${entry.value.toARGB32().toRadixString(16).substring(2).toUpperCase()}'
                    '${_placeholders.contains(entry.key) ? '  (placeholder)' : ''}',
                    style: t.typography.p4.copyWith(
                      color: t.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    ],
  );
}
