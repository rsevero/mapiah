// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_config/th_config_element.dart';

/// Represents an `input <file-path>` directive in a thconfig file.
class THConfigInput extends THConfigElement {
  final String filePath;

  THConfigInput({
    required this.filePath,
    super.lineNumber,
    super.originalLine,
    super.isModified,
  });
}
