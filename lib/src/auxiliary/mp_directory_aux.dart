// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class MPDirectoryAux {
  static Directory _rootDirectory = Directory('');
  static bool _rootDirectorySet = false;

  static Future<Directory> get rootDirectory async {
    if (!_rootDirectorySet) {
      _rootDirectory = await getApplicationDocumentsDirectory();
      _rootDirectorySet = true;
    }
    return _rootDirectory;
  }

  static Future<Directory> config() async {
    final Directory rootDir = await rootDirectory;
    final Directory configDirectory = Directory(
      p.join(rootDir.path, mpMainDirectory, mpConfigDirectory),
    );

    await configDirectory.create(recursive: true);

    return configDirectory;
  }

  static Future<Directory> main() async {
    final Directory rootDir = await rootDirectory;
    final Directory mainDirectory = Directory(
      p.join(rootDir.path, mpMainDirectory),
    );

    await mainDirectory.create(recursive: true);

    return mainDirectory;
  }

  static Future<Directory> projects() async {
    final Directory rootDir = await rootDirectory;
    final Directory projectsDirectory = Directory(
      p.join(rootDir.path, mpMainDirectory, mpProjectsDirectory),
    );

    await projectsDirectory.create(recursive: true);

    return projectsDirectory;
  }

  static String getDefaultLineEnding() {
    if (Platform.isWindows) {
      return '\r\n';
    } else {
      return '\n'; // Linux and macOS
    }
  }

  /// Resolves [filename] against the directory of [referencePath] into an
  /// absolute, normalized path.
  ///
  /// Deliberately avoids [p.canonicalize], which lowercases paths on Windows:
  /// resolved paths are opened and rebased into paths written back to TH2
  /// files, so the user's letter case must be kept.
  ///
  /// [pathContext] defaults to the current platform's context; tests pass a
  /// Windows or POSIX context to exercise both styles on any host.
  static String getResolvedPath(
    String referencePath,
    String filename, {
    p.Context? pathContext,
  }) {
    final p.Context context = pathContext ?? p.context;
    final String resolvedPath = context.normalize(
      context.absolute(
        context.isAbsolute(filename)
            ? filename
            : context.join(context.dirname(referencePath), filename),
      ),
    );

    return resolvedPath;
  }

  /// Rewrites a relative asset path so it still points to the same target
  /// after the referencing TH2 file is saved elsewhere.
  ///
  /// An absolute [filename] is returned verbatim when [oldReferencePath] is
  /// absolute, because moving the TH2 file does not change what it points at.
  static String rebaseRelativePath({
    required String oldReferencePath,
    required String newReferencePath,
    required String filename,
    p.Context? pathContext,
  }) {
    final p.Context context = pathContext ?? p.context;

    if (context.isAbsolute(filename)) {
      if (!context.isAbsolute(oldReferencePath)) {
        return relativePathFromReferencePath(
          targetPath: filename,
          referencePath: newReferencePath,
          pathContext: context,
        );
      }

      return filename;
    }

    final String resolvedPath = getResolvedPath(
      oldReferencePath,
      filename,
      pathContext: context,
    );

    return relativePathFromReferencePath(
      targetPath: resolvedPath,
      referencePath: newReferencePath,
      pathContext: context,
    );
  }

  /// Returns [targetPath] relative to the directory of [referencePath], with
  /// `/` separators and a leading `./` or `../`.
  ///
  /// Uses the platform context's [p.Context.relative], which compares paths
  /// case-insensitively on Windows and understands drive letters. When the
  /// target is on a different drive than the reference, no relative path
  /// exists and the absolute target is returned unchanged.
  static String relativePathFromReferencePath({
    required String targetPath,
    required String referencePath,
    p.Context? pathContext,
  }) {
    final p.Context context = pathContext ?? p.context;
    final String normalizedTargetPath = context.normalize(
      context.absolute(targetPath),
    );
    final String normalizedReferenceDirectory = context.dirname(
      context.normalize(context.absolute(referencePath)),
    );
    final String rawRelativePath = context.relative(
      normalizedTargetPath,
      from: normalizedReferenceDirectory,
    );

    if (context.isAbsolute(rawRelativePath)) {
      return rawRelativePath;
    }

    final String relativePath = rawRelativePath.replaceAll('\\', '/');

    if (relativePath.startsWith('./') || relativePath.startsWith('../')) {
      return relativePath;
    }

    return './$relativePath';
  }
}
