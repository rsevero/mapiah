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

  static String getResolvedPath(String referencePath, String filename) {
    final String resolvedPath = p.canonicalize(
      p.isAbsolute(filename)
          ? filename
          : p.join(p.dirname(referencePath), filename),
    );

    return resolvedPath;
  }

  /// Rewrites a relative asset path so it still points to the same target
  /// after the referencing TH2 file is saved elsewhere.
  static String rebaseRelativePath({
    required String oldReferencePath,
    required String newReferencePath,
    required String filename,
  }) {
    if (p.isAbsolute(filename)) {
      if (!p.isAbsolute(oldReferencePath)) {
        return relativePathFromReferencePath(
          targetPath: filename,
          referencePath: newReferencePath,
        );
      }

      return p.canonicalize(filename);
    }

    final String resolvedPath = getResolvedPath(oldReferencePath, filename);
    final String absoluteResolvedPath = p.isAbsolute(resolvedPath)
        ? p.canonicalize(resolvedPath)
        : p.canonicalize(p.absolute(resolvedPath));

    return relativePathFromReferencePath(
      targetPath: absoluteResolvedPath,
      referencePath: newReferencePath,
    );
  }

  static String relativePathFromReferencePath({
    required String targetPath,
    required String referencePath,
  }) {
    final String normalizedTargetPath = p.posix.canonicalize(
      targetPath.replaceAll('\\', '/'),
    );
    final String normalizedReferenceDirectory = p.posix.canonicalize(
      p.dirname(referencePath).replaceAll('\\', '/'),
    );
    final String rawRelativePath = p.posix.relative(
      normalizedTargetPath,
      from: normalizedReferenceDirectory,
    );

    if (rawRelativePath.startsWith('./') || rawRelativePath.startsWith('../')) {
      return rawRelativePath;
    }

    return './$rawRelativePath';
  }
}
