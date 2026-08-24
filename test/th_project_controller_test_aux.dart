// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'package:path/path.dart' as p;

/// Test helpers for `THProjectController` tests that need a writable copy of
/// a fixture project, since `reparseFile`/`saveProjectFile` can write to
/// disk and must not mutate the checked-in fixtures under
/// `test/auxiliary/th_project/`.
class THProjectControllerTestAux {
  /// Copies every file in `test/auxiliary/th_project/[fixtureName]` into a
  /// fresh temporary directory and returns it. Callers must delete the
  /// returned directory when done.
  static Directory copyFixtureToTemp(String fixtureName) {
    final String fixtureDir = p.join(
      Directory.current.path,
      'test',
      'auxiliary',
      'th_project',
      fixtureName,
    );
    final Directory tempDir = Directory.systemTemp.createTempSync(
      'mapiah_th_project_controller_test_',
    );

    for (final FileSystemEntity entity in Directory(
      fixtureDir,
    ).listSync()) {
      if (entity is File) {
        entity.copySync(p.join(tempDir.path, p.basename(entity.path)));
      }
    }

    return tempDir;
  }
}
