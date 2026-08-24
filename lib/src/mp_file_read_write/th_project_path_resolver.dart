// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:path/path.dart' as p;

/// Shared path-resolution helpers for Therion project directives.
class THProjectPathResolver {
  /// Resolves [rawPath] against the directory of
  /// [includingFileAbsolutePath], applying [defaultExtension] when the raw
  /// path has no extension.
  static String resolve({
    required String rawPath,
    required String includingFileAbsolutePath,
    String? defaultExtension,
  }) {
    if (rawPath.isEmpty) {
      return p.normalize(p.dirname(includingFileAbsolutePath));
    }

    final String joinedPath = p.isAbsolute(rawPath)
        ? rawPath
        : p.join(p.dirname(includingFileAbsolutePath), rawPath);

    final String normalizedPath = p.normalize(joinedPath);

    if ((defaultExtension != null) &&
        p.extension(rawPath).isEmpty &&
        !rawPath.endsWith(p.separator)) {
      return '$normalizedPath$defaultExtension';
    }

    return normalizedPath;
  }

  /// Canonicalizes an absolute path for cycle detection and dependency maps.
  ///
  /// Deliberately uses [p.normalize] instead of resolving symlinks, because
  /// missing-file targets may not exist on disk.
  static String canonicalize(String absolutePath) {
    return p.normalize(absolutePath);
  }
}
