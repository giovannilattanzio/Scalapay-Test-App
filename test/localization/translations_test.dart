// The two translation files are hand-maintained JSON, so nothing stops one
// language from drifting out of sync with the other when a key is added,
// renamed or removed. This test compares the flattened key sets both ways and
// names the exact keys missing on either side, so a future omission is
// reported by name instead of surfacing later as a silent fallback string or
// a missing-translation crash.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Recursively flattens nested JSON into dotted keys, e.g.
/// `{"catalog": {"title": "..."}}` becomes `{"catalog.title"}`.
Set<String> _flattenKeys(Map<String, dynamic> json, [String prefix = '']) {
  final keys = <String>{};
  json.forEach((key, value) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map<String, dynamic>) {
      keys.addAll(_flattenKeys(value, path));
    } else {
      keys.add(path);
    }
  });
  return keys;
}

/// Returns the dotted keys whose value is empty (or blank).
Set<String> _emptyValueKeys(Map<String, dynamic> json, [String prefix = '']) {
  final empty = <String>{};
  json.forEach((key, value) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map<String, dynamic>) {
      empty.addAll(_emptyValueKeys(value, path));
    } else if (value is String && value.trim().isEmpty) {
      empty.add(path);
    }
  });
  return empty;
}

Map<String, dynamic> _loadJson(String path) {
  final content = File(path).readAsStringSync();
  return jsonDecode(content) as Map<String, dynamic>;
}

void main() {
  final it = _loadJson('assets/translations/it.json');
  final en = _loadJson('assets/translations/en.json');

  test('it.json and en.json define exactly the same set of keys', () {
    final itKeys = _flattenKeys(it);
    final enKeys = _flattenKeys(en);

    final missingInEn = itKeys.difference(enKeys);
    final missingInIt = enKeys.difference(itKeys);

    expect(
      missingInEn,
      isEmpty,
      reason:
          'These keys exist in it.json but not in en.json: '
          '${missingInEn.join(', ')}',
    );
    expect(
      missingInIt,
      isEmpty,
      reason:
          'These keys exist in en.json but not in it.json: '
          '${missingInIt.join(', ')}',
    );
  });

  test('no translation value is empty', () {
    final emptyInIt = _emptyValueKeys(it);
    final emptyInEn = _emptyValueKeys(en);

    expect(
      emptyInIt,
      isEmpty,
      reason:
          'These keys have an empty value in it.json: ${emptyInIt.join(', ')}',
    );
    expect(
      emptyInEn,
      isEmpty,
      reason:
          'These keys have an empty value in en.json: ${emptyInEn.join(', ')}',
    );
  });
}
