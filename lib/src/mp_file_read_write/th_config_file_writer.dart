// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';
import 'package:charset/charset.dart';
import 'package:mapiah/src/elements/th_config/th_config_comment.dart';
import 'package:mapiah/src/elements/th_config/th_config_element.dart';
import 'package:mapiah/src/elements/th_config/th_config_export.dart';
import 'package:mapiah/src/elements/th_config/th_config_file.dart';
import 'package:mapiah/src/elements/th_config/th_config_input.dart';
import 'package:mapiah/src/elements/th_config/th_config_layout.dart';
import 'package:mapiah/src/elements/th_config/th_config_select.dart';
import 'package:mapiah/src/elements/th_config/th_config_setting.dart';
import 'package:mapiah/src/elements/th_config/th_config_source.dart';

/// Serializer for Therion configuration (`thconfig`) files.
class THConfigFileWriter {
  /// Serializes a [THConfigFile] to its string representation.
  String serialize(
    THConfigFile configFile, {
    String? lineEnding,
    bool forceReformat = false,
  }) {
    final String effectiveLineEnding =
        lineEnding ?? configFile.lineEnding;

    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < configFile.elements.length; i++) {
      final THConfigElement element = configFile.elements[i];

      if (!forceReformat &&
          !element.isModified &&
          element.originalLine.isNotEmpty) {
        buffer.write(element.originalLine);
      } else {
        buffer.write(_serializeElement(element, effectiveLineEnding));
      }

      if (i < (configFile.elements.length - 1)) {
        buffer.write(effectiveLineEnding);
      }
    }

    return buffer.toString();
  }

  /// Serializes a [THConfigFile] into encoded bytes.
  Uint8List serializeToBytes(
    THConfigFile configFile, {
    String? lineEnding,
    bool forceReformat = false,
  }) {
    final String text = serialize(
      configFile,
      lineEnding: lineEnding,
      forceReformat: forceReformat,
    );

    final String encodingName = configFile.encoding.toUpperCase();

    switch (encodingName) {
      case 'UTF-8':
        return Uint8List.fromList(utf8.encode(text));
      case 'ASCII':
        return Uint8List.fromList(ascii.encode(text));
      case 'ISO8859-1':
      case 'ISO-8859-1':
        return Uint8List.fromList(latin1.encode(text));
      default:
        final Encoding? encoder = Charset.getByName(configFile.encoding);

        if (encoder == null) {
          return Uint8List.fromList(utf8.encode(text));
        } else {
          return Uint8List.fromList(encoder.encode(text));
        }
    }
  }

  String _serializeElement(THConfigElement element, String lineEnding) {
    if (element is THConfigComment) {
      return element.isEmptyLine ? '' : element.commentText;
    }

    if (element is THConfigSource) {
      if (element.isMultiLine) {
        final StringBuffer sb = StringBuffer('source$lineEnding');
        for (final String line in element.inlineCommands) {
          sb.write('$line$lineEnding');
        }
        sb.write('endsource');
        return sb.toString();
      }
      return 'source ${element.filePath}';
    }

    if (element is THConfigInput) {
      return 'input ${element.filePath}';
    }

    if (element is THConfigLayout) {
      final StringBuffer sb = StringBuffer('layout ${element.layoutId}$lineEnding');
      for (final String line in element.rawLines) {
        sb.write('$line$lineEnding');
      }
      sb.write('endlayout');
      return sb.toString();
    }

    if (element is THConfigExport) {
      final StringBuffer sb = StringBuffer('export ${element.exportType}');
      if (element.rawOptions.isNotEmpty) {
        sb.write(' ${element.rawOptions.join(' ')}');
      }
      return sb.toString();
    }

    if (element is THConfigSelect) {
      final String cmd = element.isSelect ? 'select' : 'unselect';
      final StringBuffer sb = StringBuffer('$cmd ${element.targetObjectId}');
      if (element.rawOptions.isNotEmpty) {
        sb.write(' ${element.rawOptions.join(' ')}');
      }
      return sb.toString();
    }

    if (element is THConfigSetting) {
      final StringBuffer sb = StringBuffer(element.keyword);
      if (element.arguments.isNotEmpty) {
        sb.write(' ${element.arguments.join(' ')}');
      }
      return sb.toString();
    }

    return element.originalLine;
  }
}
