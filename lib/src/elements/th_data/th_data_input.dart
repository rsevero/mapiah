// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_data/th_data_element.dart';

/// Represents an  directive in a .th file.
class THDataInput extends THDataElement {
  final String rawPath;

  /// Path resolved with default .th extension if omitted.
  String get resolvedPath {
    final int lastSlash = rawPath.lastIndexOf('/');
    final String filename = lastSlash == -1 ? rawPath : rawPath.substring(lastSlash + 1);
    if (filename.contains('.')) {
      return rawPath;
    }
    return '$rawPath.th';
  }

  THDataInput({
    required this.rawPath,
    super.lineNumber,
    super.originalLine,
    super.isModified,
  });
}
