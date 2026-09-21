// The generated backend client is an implementation detail of the data layer.
// Keeping it there is what makes regenerating it safe: a renamed field in
// openapi/catalog-api.yaml must reach exactly one place, the mapper, and never
// a widget or an entity. A comment saying so would be forgotten, so this fails
// the build instead.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Layers that must not know the generated client exists.
const _forbiddenIn = ['lib/src/domain', 'lib/src/presentation'];
const _forbiddenImport = 'package:catalog_api';

Iterable<File> _dartFilesIn(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) return const [];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
}

void main() {
  test('neither domain nor presentation imports the generated API client', () {
    final offenders = <String>[];

    for (final layer in _forbiddenIn) {
      for (final file in _dartFilesIn(layer)) {
        final importsClient = file
            .readAsLinesSync()
            .where((line) => line.trimLeft().startsWith('import '))
            .any((line) => line.contains(_forbiddenImport));
        if (importsClient) offenders.add(file.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'These files import $_forbiddenImport, which only the data layer may '
          'do. Map the generated type to a domain entity in '
          'lib/src/data/catalog/mappers/ and depend on that instead:\n'
          '${offenders.join('\n')}',
    );
  });

  test('the layers this guards actually exist, so it cannot pass vacuously', () {
    // Without this, deleting or renaming a layer directory would turn the test
    // above into a green no-op.
    expect(
      Directory('lib/src/domain').existsSync(),
      isTrue,
      reason: 'lib/src/domain is missing: the boundary check above is vacuous',
    );
    expect(
      _dartFilesIn('lib/src/domain'),
      isNotEmpty,
      reason: 'lib/src/domain has no Dart files to check',
    );
  });
}
