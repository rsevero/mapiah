// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';
import 'package:charset/charset.dart';
import 'package:mapiah/src/elements/th_data/th_centreline.dart';
import 'package:mapiah/src/elements/th_data/th_data_comment.dart';
import 'package:mapiah/src/elements/th_data/th_data_element.dart';
import 'package:mapiah/src/elements/th_data/th_data_file.dart';
import 'package:mapiah/src/elements/th_data/th_data_general.dart';
import 'package:mapiah/src/elements/th_data/th_data_input.dart';
import 'package:mapiah/src/elements/th_data/th_equate.dart';
import 'package:mapiah/src/elements/th_data/th_import.dart';
import 'package:mapiah/src/elements/th_data/th_inline_scrap.dart';
import 'package:mapiah/src/elements/th_data/th_join.dart';
import 'package:mapiah/src/elements/th_data/th_map.dart';
import 'package:mapiah/src/elements/th_data/th_surface.dart';
import 'package:mapiah/src/elements/th_data/th_survey.dart';

/// Serializer for Therion survey data (`.th`) files.
class THFileWriter {
  /// Serializes a [THDataFile] to its string representation.
  String serialize(
    THDataFile dataFile, {
    String? lineEnding,
    bool forceReformat = false,
  }) {
    final String effectiveLineEnding =
        lineEnding ?? dataFile.lineEnding;

    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < dataFile.elements.length; i++) {
      final THDataElement element = dataFile.elements[i];

      if (!forceReformat &&
          element is! THSurvey &&
          !element.isModified &&
          element.originalLine.isNotEmpty) {
        buffer.write(element.originalLine);
      } else {
        buffer.write(_serializeElement(element, effectiveLineEnding, indent: ''));
      }

      if (i < (dataFile.elements.length - 1)) {
        buffer.write(effectiveLineEnding);
      }
    }

    return buffer.toString();
  }

  /// Serializes a [THDataFile] into encoded bytes.
  Uint8List serializeToBytes(
    THDataFile dataFile, {
    String? lineEnding,
    bool forceReformat = false,
  }) {
    final String text = serialize(
      dataFile,
      lineEnding: lineEnding,
      forceReformat: forceReformat,
    );

    final String encodingName = dataFile.encoding.toUpperCase();

    switch (encodingName) {
      case 'UTF-8':
        return Uint8List.fromList(utf8.encode(text));
      case 'ASCII':
        return Uint8List.fromList(ascii.encode(text));
      case 'ISO8859-1':
      case 'ISO-8859-1':
        return Uint8List.fromList(latin1.encode(text));
      default:
        final Encoding? encoder = Charset.getByName(dataFile.encoding);

        if (encoder == null) {
          return Uint8List.fromList(utf8.encode(text));
        } else {
          return Uint8List.fromList(encoder.encode(text));
        }
    }
  }

  String _serializeElement(
    THDataElement element,
    String lineEnding, {
    String indent = '',
  }) {
    if (element is THSurvey) {
      final String startLine = (!element.isModified && element.originalLine.isNotEmpty)
          ? element.originalLine
          : '${indent}survey ${element.surveyId}';
      final String endLine = (!element.isModified && element.endLine.isNotEmpty)
          ? element.endLine
          : '${indent}endsurvey';

      final StringBuffer sb = StringBuffer('$startLine$lineEnding');
      final String nextIndent = '$indent  ';

      for (int i = 0; i < element.children.length; i++) {
        sb.write(_serializeElement(element.children[i], lineEnding, indent: nextIndent));
        sb.write(lineEnding);
      }

      sb.write(endLine);
      return sb.toString();
    }

    if (!element.isModified && element.originalLine.isNotEmpty) {
      return element.originalLine;
    }

    if (element is THDataComment) {
      return element.isEmptyLine ? '' : '$indent${element.commentText}';
    }

    if (element is THCentreline) {
      final StringBuffer sb = StringBuffer('${indent}centreline$lineEnding');
      for (final String line in element.rawDataLines) {
        sb.write('$line$lineEnding');
      }
      sb.write('${indent}endcentreline');
      return sb.toString();
    }

    if (element is THMap) {
      final StringBuffer sb = StringBuffer('${indent}map ${element.mapId}');
      if (element.projection.isNotEmpty) {
        sb.write(' -projection ${element.projection}');
      }
      sb.write(lineEnding);
      for (final String item in element.items) {
        sb.write('$indent  $item$lineEnding');
      }
      sb.write('${indent}endmap');
      return sb.toString();
    }

    if (element is THDataInput) {
      return '${indent}input ${element.rawPath}';
    }

    if (element is THDataGeneral) {
      return element.rawArguments.isEmpty
          ? '$indent${element.keyword}'
          : '$indent${element.keyword} ${element.rawArguments}';
    }

    if (element is THEquate) {
      return '${indent}equate ${element.stations.join(' ')}';
    }

    if (element is THJoin) {
      final StringBuffer sb = StringBuffer('${indent}join ${element.line1} ${element.line2}');
      if (element.rawOptions.isNotEmpty) {
        sb.write(' ${element.rawOptions.join(' ')}');
      }
      return sb.toString();
    }

    if (element is THImport) {
      final StringBuffer sb = StringBuffer('${indent}import ${element.filePath}');
      if (element.rawOptions.isNotEmpty) {
        sb.write(' ${element.rawOptions.join(' ')}');
      }
      return sb.toString();
    }

    if (element is THInlineScrap) {
      final StringBuffer sb = StringBuffer('${indent}scrap ${element.scrapId}$lineEnding');
      for (final String line in element.rawLines) {
        sb.write('$line$lineEnding');
      }
      sb.write('${indent}endscrap');
      return sb.toString();
    }

    if (element is THSurface) {
      final StringBuffer sb = StringBuffer('${indent}surface$lineEnding');
      for (final String line in element.rawLines) {
        sb.write('$line$lineEnding');
      }
      sb.write('${indent}endsurface');
      return sb.toString();
    }

    return element.originalLine;
  }
}
