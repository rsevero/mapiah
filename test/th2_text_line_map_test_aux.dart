// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_endings_aux.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class TH2TextLineMapFakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

/// A parse result together with the parser, whose line starts the parser map
/// tests read.
class TH2TextParsed {
  final TH2File file;
  final bool isSuccessful;
  final List<String> errors;
  final TH2FileParser parser;

  TH2TextParsed(this.file, this.isSuccessful, this.errors, this.parser);

  TH2TextLineMap get parserMap => TH2TextLineMap.fromParserStartLines(
    lineStarts: parser.lineStarts,
    lineCount: parser.parsedLineCount,
    th2File: file,
  );
}

/// Shared helpers of the TH2 text line map tests (t3960–t3963, t3989).
class TH2TextLineMapTestAux {
  static Future<TH2TextParsed> parseBytes(
    Uint8List bytes, {
    String filename = '/tmp/th2_text_line_map_test.th2',
  }) async {
    MPLocator().mpGeneralController.reset();

    final TH2FileParser parser = TH2FileParser();
    final (TH2File file, bool isSuccessful, List<String> errors) = await parser
        .parse(filename, fileBytes: bytes);

    return TH2TextParsed(file, isSuccessful, errors, parser);
  }

  static Future<TH2TextParsed> parseText(
    String text, {
    String filename = '/tmp/th2_text_line_map_test.th2',
  }) {
    return parseBytes(utf8.encode(text), filename: filename);
  }

  /// Writes [file] with Save's options.
  static String asSaved(TH2File file, {bool useOriginalRepresentation = true}) {
    return TH2FileWriter().serialize(
      file,
      includeEmptyLines: true,
      useOriginalRepresentation: useOriginalRepresentation,
    );
  }

  static (String, TH2TextLineMap) asSavedWithLineMap(
    TH2File file, {
    bool useOriginalRepresentation = true,
    String? lineEnding,
  }) {
    return TH2FileWriter().serializeWithLineMap(
      file,
      includeEmptyLines: true,
      useOriginalRepresentation: useOriginalRepresentation,
      lineEnding: lineEnding,
    );
  }

  static Uint8List savedBytes(
    TH2File file, {
    bool useOriginalRepresentation = true,
  }) {
    return TH2FileWriter().toBytes(
      file,
      includeEmptyLines: true,
      useOriginalRepresentation: useOriginalRepresentation,
    );
  }

  static List<File> fixtures() {
    return Directory('test/auxiliary')
        .listSync()
        .whereType<File>()
        .where((File file) => file.path.endsWith('.th2'))
        .toList()
      ..sort((File a, File b) => a.path.compareTo(b.path));
  }

  /// Fixtures that parse cleanly and whose decoded text has no lone `\r`,
  /// parsed.
  static Future<List<(String, TH2TextParsed)>> cleanFixtures() async {
    final List<(String, TH2TextParsed)> clean = <(String, TH2TextParsed)>[];

    for (final File fixture in fixtures()) {
      final Uint8List bytes = fixture.readAsBytesSync();
      final TH2TextParsed parsed = await parseBytes(
        bytes,
        filename: fixture.path,
      );

      if (!parsed.isSuccessful) {
        continue;
      }

      final String text = asSaved(parsed.file);

      if (TH2TextLineEndingsAux.loneCarriageReturnOffset(text) != null) {
        continue;
      }

      clean.add((fixture.path, parsed));
    }

    return clean;
  }

  /// Removes the stored text of every element and option of [file], so the
  /// writer generates every line, as for elements created by commands.
  static void stripStoredText(TH2File file) {
    final List<THElement> elements = file.elements.values.toList();

    for (final THElement element in elements) {
      THElement stripped = element;

      if (element.originalLineInTH2File.isNotEmpty) {
        stripped = element.copyWith(originalLineInTH2File: '');
        file.substituteElement(stripped);
      }

      if (stripped is THHasOptionsMixin) {
        final List<THCommandOption> options = stripped.optionsMap.values
            .toList();

        for (final THCommandOption option in options) {
          if (option.originalLineInTH2File.isNotEmpty) {
            stripped.addUpdateOption(
              option.copyWith(originalLineInTH2File: ''),
            );
          }
        }
      }
    }
  }

  /// Checks the invariants every writer map holds, returning the problems
  /// found.
  static List<String> writerMapProblems(
    String text,
    TH2TextLineMap lineMap,
    TH2File file,
  ) {
    final List<String> problems = <String>[];
    final List<int> lineStarts = TH2TextLineEndingsAux.lineStartOffsets(text);

    if (lineMap.lineCount != lineStarts.length) {
      problems.add(
        'Line count ${lineMap.lineCount} != text lines ${lineStarts.length}',
      );
    }

    for (int line = 0; line < lineStarts.length; line++) {
      final int? owner = lineMap.ownerOfLine(line);

      if (owner == null) {
        problems.add('Line $line has no owner');
      } else if ((owner != file.mpID) && !file.hasElementByMPID(owner)) {
        problems.add('Line $line owner $owner is not in the file');
      }
    }

    return problems;
  }
}
