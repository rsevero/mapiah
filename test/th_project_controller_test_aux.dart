// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_project_reparse_flush_result.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
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

  /// Registers [content] as a pending edit for [filePath] against [controller]
  /// (allocating a revision) and drains the resulting project-level re-parse,
  /// using the controller's current epoch/root. Mirrors what an editor's
  /// two-layer debounce chain does, without waiting on real timers.
  static Future<THProjectReparseFlushResult> editAndFlush(
    THProjectController controller, {
    required String filePath,
    required String content,
  }) {
    final String canonical = THProjectPathResolver.canonicalize(
      p.absolute(filePath),
    );
    final int revision = controller.registerTextContentChange(
      canonicalPath: canonical,
      content: content,
      expectedProjectEpoch: controller.projectEpoch,
      expectedRootPath: controller.rootConfigPath,
    );

    return controller.flushPendingReparse(
      canonicalPath: canonical,
      expectedRevision: revision,
      expectedProjectEpoch: controller.projectEpoch,
      expectedRootPath: controller.rootConfigPath,
    );
  }
}
