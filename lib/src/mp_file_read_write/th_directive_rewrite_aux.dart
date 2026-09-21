// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/elements/th_config/th_config_file.dart';
import 'package:mapiah/src/elements/th_config/th_config_input.dart';
import 'package:mapiah/src/elements/th_config/th_config_source.dart';
import 'package:mapiah/src/elements/th_data/th_data_element.dart';
import 'package:mapiah/src/elements/th_data/th_data_file.dart';
import 'package:mapiah/src/elements/th_data/th_data_input.dart';
import 'package:mapiah/src/elements/th_data/th_import.dart';
import 'package:mapiah/src/elements/th_data/th_survey.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;

/// Rewrites the relative directive paths of Therion config (`thconfig`) and
/// data (`.th`) files so they keep resolving to the same targets across a
/// Save As move (Phase 10). Two independent operations:
///
/// - "own outgoing": the containing file itself moved; every one of its
///   *relative* `source`/`input`/`import` directives is recomputed against
///   its new directory, regardless of what it points at. An absolute
///   directive is unaffected by the containing file's own move and is left
///   untouched.
/// - "incoming": some other file the containing file references moved;
///   every directive (relative or absolute) whose *resolved* target equals
///   the old canonical path is rewritten to reach the new one. An absolute
///   directive stays absolute (mirrors `MPDirectoryAux.rebaseRelativePath`'s
///   existing absolute-stays-absolute precedent); a relative directive
///   becomes a new relative path.
///
/// `THConfigSource.filePath`, `THConfigInput.filePath`,
/// `THDataInput.rawPath`, and `THImport.filePath` are all `final`, so a
/// rewrite always replaces the element instance at its index rather than
/// mutating a field; every other element (comments, blanks, unrelated
/// directives) is left byte-for-byte untouched because its `originalLine`
/// is never cleared.
///
/// Multi-line `source ... endsource` blocks are not rewritten: their
/// per-line paths live in `THConfigSource.inlineCommands` as raw strings,
/// not in the typed `filePath` field, and reconstructing them safely is out
/// of scope for Phase 10 — a known, documented limitation.
class THDirectiveRewriteAux {
  const THDirectiveRewriteAux._();

  /// Rewrites [configFile]'s own relative `source`/`input` directives after
  /// the file itself moves from [oldAbsolutePath] to [newAbsolutePath].
  /// Returns the number of elements rewritten.
  static int rewriteOwnOutgoingConfigDirectives({
    required THConfigFile configFile,
    required String oldAbsolutePath,
    required String newAbsolutePath,
  }) {
    int rewrittenCount = 0;

    for (int i = 0; i < configFile.elements.length; i++) {
      final element = configFile.elements[i];

      if (element is THConfigSource &&
          !element.isMultiLine &&
          element.filePath.isNotEmpty &&
          !p.isAbsolute(element.filePath)) {
        final String target = THProjectPathResolver.resolve(
          rawPath: element.filePath,
          includingFileAbsolutePath: oldAbsolutePath,
          defaultExtension: '.th',
        );
        final String newRawPath = MPDirectoryAux.relativePathFromReferencePath(
          targetPath: target,
          referencePath: newAbsolutePath,
        );

        configFile.elements[i] = THConfigSource(
          filePath: newRawPath,
          lineNumber: element.lineNumber,
          isModified: true,
        );
        rewrittenCount++;
      } else if (element is THConfigInput &&
          element.filePath.isNotEmpty &&
          !p.isAbsolute(element.filePath)) {
        final String target = THProjectPathResolver.resolve(
          rawPath: element.filePath,
          includingFileAbsolutePath: oldAbsolutePath,
        );
        final String newRawPath = MPDirectoryAux.relativePathFromReferencePath(
          targetPath: target,
          referencePath: newAbsolutePath,
        );

        configFile.elements[i] = THConfigInput(
          filePath: newRawPath,
          lineNumber: element.lineNumber,
          isModified: true,
        );
        rewrittenCount++;
      }
    }

    return rewrittenCount;
  }

  /// Rewrites every directive in [dependentConfigFile] (located at
  /// [dependentAbsolutePath], unmoved) whose resolved target equals
  /// [oldTargetCanonicalPath], retargeting it to
  /// [newTargetCanonicalPath]. Returns the number of elements rewritten.
  static int rewriteIncomingConfigDirectives({
    required THConfigFile dependentConfigFile,
    required String dependentAbsolutePath,
    required String oldTargetCanonicalPath,
    required String newTargetCanonicalPath,
  }) {
    int rewrittenCount = 0;

    for (int i = 0; i < dependentConfigFile.elements.length; i++) {
      final element = dependentConfigFile.elements[i];

      if (element is THConfigSource &&
          !element.isMultiLine &&
          element.filePath.isNotEmpty) {
        final String target = THProjectPathResolver.resolve(
          rawPath: element.filePath,
          includingFileAbsolutePath: dependentAbsolutePath,
          defaultExtension: '.th',
        );

        if (target != oldTargetCanonicalPath) {
          continue;
        }

        dependentConfigFile.elements[i] = THConfigSource(
          filePath: _rebasedRawPath(
            oldRawPath: element.filePath,
            dependentAbsolutePath: dependentAbsolutePath,
            newTargetCanonicalPath: newTargetCanonicalPath,
          ),
          lineNumber: element.lineNumber,
          isModified: true,
        );
        rewrittenCount++;
      } else if (element is THConfigInput && element.filePath.isNotEmpty) {
        final String target = THProjectPathResolver.resolve(
          rawPath: element.filePath,
          includingFileAbsolutePath: dependentAbsolutePath,
        );

        if (target != oldTargetCanonicalPath) {
          continue;
        }

        dependentConfigFile.elements[i] = THConfigInput(
          filePath: _rebasedRawPath(
            oldRawPath: element.filePath,
            dependentAbsolutePath: dependentAbsolutePath,
            newTargetCanonicalPath: newTargetCanonicalPath,
          ),
          lineNumber: element.lineNumber,
          isModified: true,
        );
        rewrittenCount++;
      }
    }

    return rewrittenCount;
  }

  /// Rewrites [dataFile]'s own relative `input`/`import` directives
  /// (including any nested inside `survey ... endsurvey` blocks) after the
  /// file itself moves from [oldAbsolutePath] to [newAbsolutePath]. Returns
  /// the number of elements rewritten.
  static int rewriteOwnOutgoingDataDirectives({
    required THDataFile dataFile,
    required String oldAbsolutePath,
    required String newAbsolutePath,
  }) {
    return _rewriteOwnOutgoingDataElements(
      elements: dataFile.elements,
      oldAbsolutePath: oldAbsolutePath,
      newAbsolutePath: newAbsolutePath,
    );
  }

  static int _rewriteOwnOutgoingDataElements({
    required List<THDataElement> elements,
    required String oldAbsolutePath,
    required String newAbsolutePath,
  }) {
    int rewrittenCount = 0;

    for (int i = 0; i < elements.length; i++) {
      final element = elements[i];

      if (element is THSurvey) {
        rewrittenCount += _rewriteOwnOutgoingDataElements(
          elements: element.children,
          oldAbsolutePath: oldAbsolutePath,
          newAbsolutePath: newAbsolutePath,
        );
      } else if (element is THDataInput &&
          element.rawPath.isNotEmpty &&
          !p.isAbsolute(element.rawPath)) {
        final String target = THProjectPathResolver.resolve(
          rawPath: element.rawPath,
          includingFileAbsolutePath: oldAbsolutePath,
          defaultExtension: '.th',
        );
        final String newRawPath = MPDirectoryAux.relativePathFromReferencePath(
          targetPath: target,
          referencePath: newAbsolutePath,
        );

        elements[i] = THDataInput(
          rawPath: newRawPath,
          lineNumber: element.lineNumber,
          isModified: true,
        );
        rewrittenCount++;
      } else if (element is THImport &&
          element.filePath.isNotEmpty &&
          !p.isAbsolute(element.filePath)) {
        final String target = THProjectPathResolver.resolve(
          rawPath: element.filePath,
          includingFileAbsolutePath: oldAbsolutePath,
        );
        final String newRawPath = MPDirectoryAux.relativePathFromReferencePath(
          targetPath: target,
          referencePath: newAbsolutePath,
        );

        elements[i] = THImport(
          filePath: newRawPath,
          rawOptions: element.rawOptions,
          parsedOptions: element.parsedOptions,
          lineNumber: element.lineNumber,
          isModified: true,
        );
        rewrittenCount++;
      }
    }

    return rewrittenCount;
  }

  /// Rewrites every directive in [dependentDataFile] (located at
  /// [dependentAbsolutePath], unmoved, including nested `survey` blocks)
  /// whose resolved target equals [oldTargetCanonicalPath], retargeting it
  /// to [newTargetCanonicalPath]. Returns the number of elements rewritten.
  static int rewriteIncomingDataDirectives({
    required THDataFile dependentDataFile,
    required String dependentAbsolutePath,
    required String oldTargetCanonicalPath,
    required String newTargetCanonicalPath,
  }) {
    return _rewriteIncomingDataElements(
      elements: dependentDataFile.elements,
      dependentAbsolutePath: dependentAbsolutePath,
      oldTargetCanonicalPath: oldTargetCanonicalPath,
      newTargetCanonicalPath: newTargetCanonicalPath,
    );
  }

  static int _rewriteIncomingDataElements({
    required List<THDataElement> elements,
    required String dependentAbsolutePath,
    required String oldTargetCanonicalPath,
    required String newTargetCanonicalPath,
  }) {
    int rewrittenCount = 0;

    for (int i = 0; i < elements.length; i++) {
      final element = elements[i];

      if (element is THSurvey) {
        rewrittenCount += _rewriteIncomingDataElements(
          elements: element.children,
          dependentAbsolutePath: dependentAbsolutePath,
          oldTargetCanonicalPath: oldTargetCanonicalPath,
          newTargetCanonicalPath: newTargetCanonicalPath,
        );
      } else if (element is THDataInput && element.rawPath.isNotEmpty) {
        final String target = THProjectPathResolver.resolve(
          rawPath: element.rawPath,
          includingFileAbsolutePath: dependentAbsolutePath,
          defaultExtension: '.th',
        );

        if (target != oldTargetCanonicalPath) {
          continue;
        }

        elements[i] = THDataInput(
          rawPath: _rebasedRawPath(
            oldRawPath: element.rawPath,
            dependentAbsolutePath: dependentAbsolutePath,
            newTargetCanonicalPath: newTargetCanonicalPath,
          ),
          lineNumber: element.lineNumber,
          isModified: true,
        );
        rewrittenCount++;
      } else if (element is THImport && element.filePath.isNotEmpty) {
        final String target = THProjectPathResolver.resolve(
          rawPath: element.filePath,
          includingFileAbsolutePath: dependentAbsolutePath,
        );

        if (target != oldTargetCanonicalPath) {
          continue;
        }

        elements[i] = THImport(
          filePath: _rebasedRawPath(
            oldRawPath: element.filePath,
            dependentAbsolutePath: dependentAbsolutePath,
            newTargetCanonicalPath: newTargetCanonicalPath,
          ),
          rawOptions: element.rawOptions,
          parsedOptions: element.parsedOptions,
          lineNumber: element.lineNumber,
          isModified: true,
        );
        rewrittenCount++;
      }
    }

    return rewrittenCount;
  }

  /// An absolute directive stays absolute (canonicalized); a relative one
  /// is recomputed relative to the unmoved referencing file.
  static String _rebasedRawPath({
    required String oldRawPath,
    required String dependentAbsolutePath,
    required String newTargetCanonicalPath,
  }) {
    if (p.isAbsolute(oldRawPath)) {
      return THProjectPathResolver.canonicalize(newTargetCanonicalPath);
    }

    return MPDirectoryAux.relativePathFromReferencePath(
      targetPath: newTargetCanonicalPath,
      referencePath: dependentAbsolutePath,
    );
  }
}
