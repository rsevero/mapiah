// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_config/th_config_element.dart';
import 'package:mapiah/src/elements/th_config/th_config_export.dart';
import 'package:mapiah/src/elements/th_config/th_config_input.dart';
import 'package:mapiah/src/elements/th_config/th_config_layout.dart';
import 'package:mapiah/src/elements/th_config/th_config_select.dart';
import 'package:mapiah/src/elements/th_config/th_config_setting.dart';
import 'package:mapiah/src/elements/th_config/th_config_source.dart';

/// Root model representing a parsed Therion configuration (thconfig) file.
class THConfigFile {
  String filename = '';

  String encoding = mpDefaultEncoding;

  String lineEnding = MPDirectoryAux.getDefaultLineEnding();

  final List<THConfigElement> elements = <THConfigElement>[];

  final List<String> parseErrors = <String>[];

  THConfigFile({
    this.filename = '',
    this.encoding = mpDefaultEncoding,
    String? lineEnding,
    List<THConfigElement>? elements,
    List<String>? parseErrors,
  }) {
    if (lineEnding != null) {
      this.lineEnding = lineEnding;
    }
    if (elements != null) {
      this.elements.addAll(elements);
    }
    if (parseErrors != null) {
      this.parseErrors.addAll(parseErrors);
    }
  }

  /// All file paths specified in `source` directives.
  List<String> get sourceFilePaths => elements
      .whereType<THConfigSource>()
      .where((THConfigSource s) => s.filePath.isNotEmpty)
      .map((THConfigSource s) => s.filePath)
      .toList();

  /// All file paths specified in `input` directives.
  List<String> get inputFilePaths => elements
      .whereType<THConfigInput>()
      .where((THConfigInput i) => i.filePath.isNotEmpty)
      .map((THConfigInput i) => i.filePath)
      .toList();

  /// All layout definitions.
  List<THConfigLayout> get layouts =>
      elements.whereType<THConfigLayout>().toList();

  /// All export commands.
  List<THConfigExport> get exports =>
      elements.whereType<THConfigExport>().toList();

  /// All select and unselect commands.
  List<THConfigSelect> get selects =>
      elements.whereType<THConfigSelect>().toList();

  /// All global settings.
  List<THConfigSetting> get settings =>
      elements.whereType<THConfigSetting>().toList();

  /// Whether any element in the file has been modified.
  bool get isDirty => elements.any((THConfigElement e) => e.isModified);
}
