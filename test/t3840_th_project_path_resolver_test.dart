// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;

void main() {
  group('THProjectPathResolver', () {
    test('resolves relative paths against the including file directory', () {
      final String resolved = THProjectPathResolver.resolve(
        rawPath: 'cave.th',
        includingFileAbsolutePath: '/project/thconfig',
      );

      expect(resolved, p.normalize('/project/cave.th'));
    });

    test('resolves nested relative paths with parent traversal', () {
      final String resolved = THProjectPathResolver.resolve(
        rawPath: '../shared/cave.th',
        includingFileAbsolutePath: '/project/surveys/main.th',
      );

      expect(resolved, p.normalize('/project/shared/cave.th'));
    });

    test('passes absolute paths through unchanged', () {
      final String resolved = THProjectPathResolver.resolve(
        rawPath: '/other/cave.th',
        includingFileAbsolutePath: '/project/thconfig',
      );

      expect(resolved, p.normalize('/other/cave.th'));
    });

    test('appends default extension only when no extension is present', () {
      final String plain = THProjectPathResolver.resolve(
        rawPath: 'cave',
        includingFileAbsolutePath: '/project/thconfig',
        defaultExtension: '.th',
      );
      final String th2 = THProjectPathResolver.resolve(
        rawPath: 'cave.th2',
        includingFileAbsolutePath: '/project/thconfig',
        defaultExtension: '.th',
      );
      final String other = THProjectPathResolver.resolve(
        rawPath: 'cave.v3',
        includingFileAbsolutePath: '/project/thconfig',
        defaultExtension: '.th',
      );

      expect(plain, p.normalize('/project/cave.th'));
      expect(th2, p.normalize('/project/cave.th2'));
      expect(other, p.normalize('/project/cave.v3'));
    });

    test('canonicalizes equivalent paths to the same string', () {
      final String first = THProjectPathResolver.canonicalize(
        '/project/a/../a/cave.th',
      );
      final String second = THProjectPathResolver.canonicalize(
        '/project/a/cave.th',
      );

      expect(first, second);
      expect(
        THProjectPathResolver.canonicalize('/project/b/cave.th'),
        isNot(first),
      );
    });

    test('accepts forward-slash relative paths on the current platform', () {
      final String resolved = THProjectPathResolver.resolve(
        rawPath: 'subfolder/cave.th',
        includingFileAbsolutePath: '/project/thconfig',
      );

      expect(resolved, p.normalize('/project/subfolder/cave.th'));
    });
  });
}
