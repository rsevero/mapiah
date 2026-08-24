// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/elements/th_data/th_centreline.dart';
import 'package:mapiah/src/elements/th_data/th_data_file.dart';
import 'package:mapiah/src/elements/th_data/th_data_input.dart';
import 'package:mapiah/src/elements/th_data/th_survey.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';

void main() {
  group('THFileWriter', () {
    late THFileParser parser;
    late THFileWriter writer;

    setUp(() {
      parser = THFileParser();
      writer = THFileWriter();
    });

    test('preserves exact content on unmodified round-trip', () {
      const String original = '''# Survey data
encoding UTF-8

survey cave_system
  input passage_a.th
  input passage_b.th

  centreline
    date 2026.08.24
    1 2 10.5 045 0
    2 3 12.0 090 -5
  endcentreline

  map plan_map -projection plan
    scrap1@passage_a
    scrap2@passage_b
  endmap
endsurvey
''';

      final THDataFile parsed = parser.parseString(original);
      final String serialized = writer.serialize(parsed);

      expect(serialized, original);
    });

    test('correctly serializes programmatically created nested surveys', () {
      final THDataFile dataFile = THDataFile(lineEnding: '\n');

      final THSurvey rootSurvey = THSurvey(
        surveyId: 'mammoth_cave',
        isModified: true,
      );

      rootSurvey.children.add(
        THDataInput(rawPath: 'entrance.th2', isModified: true),
      );

      final THCentreline centreline = THCentreline(
        rawDataLines: ['1 2 15.0 090 0'],
        isModified: true,
      );
      rootSurvey.children.add(centreline);

      dataFile.elements.add(rootSurvey);

      final String serialized = writer.serialize(dataFile);
      const String expected = '''survey mammoth_cave
  input entrance.th2
  centreline
1 2 15.0 090 0
  endcentreline
endsurvey''';

      expect(serialized, expected);
    });

    test('preserves CRLF line endings when requested', () {
      const String original = "survey cave\r\n  input p1.th\r\nendsurvey";

      final THDataFile parsed = parser.parseString(original);
      final String serialized = writer.serialize(parsed, lineEnding: '\r\n');

      expect(serialized, original);
    });

    test('serializes to bytes with correct encoding', () {
      const String original = '''encoding UTF-8
# Special characters: àáâãç
survey cave
endsurvey''';

      final THDataFile parsed = parser.parseString(original);
      final Uint8List bytes = writer.serializeToBytes(parsed);
      final String decoded = utf8.decode(bytes);

      expect(decoded, original);
    });
  });
}
