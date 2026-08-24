// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/elements/th_config/th_config_export.dart';
import 'package:mapiah/src/elements/th_config/th_config_file.dart';
import 'package:mapiah/src/elements/th_config/th_config_source.dart';
import 'package:mapiah/src/mp_file_read_write/th_config_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_config_file_writer.dart';

void main() {
  group('THConfigFileWriter', () {
    late THConfigFileParser parser;
    late THConfigFileWriter writer;

    setUp(() {
      parser = THConfigFileParser();
      writer = THConfigFileWriter();
    });

    test('preserves exact content on unmodified round-trip', () {
      const String original = '''# Therion configuration
encoding UTF-8
cs UTM33N

source mammoth.th
source "passages/chamber.th"

layout cave_layout
  scale 1 500
  units metric
  symbol-set UIS
endlayout

select cave_system -recursive on
unselect old_passage

export map -o mammoth_plan.pdf -layout cave_layout
export model -o mammoth.lox
''';

      final THConfigFile parsed = parser.parseString(original);
      final String serialized = writer.serialize(parsed);

      expect(serialized, original);
    });

    test('correctly serializes newly added elements', () {
      final THConfigFile configFile = THConfigFile(lineEnding: '\n');

      configFile.elements.add(
        THConfigSource(filePath: 'new_cave.th', isModified: true),
      );
      configFile.elements.add(
        THConfigExport(
          exportType: 'map',
          rawOptions: ['-o', 'output.pdf', '-layout', 'main_layout'],
          isModified: true,
        ),
      );

      final String serialized = writer.serialize(configFile);
      const String expected = '''source new_cave.th
export map -o output.pdf -layout main_layout''';

      expect(serialized, expected);
    });

    test('correctly serializes modified elements among unmodified ones', () {
      const String original = '''source cave1.th
source cave2.th
export map -o output.pdf''';

      final THConfigFile parsed = parser.parseString(original);
      expect(parsed.elements.length, 3);

      // Modify the second source
      parsed.elements[1] = THConfigSource(
        filePath: 'cave2_renamed.th',
        isModified: true,
      );

      final String serialized = writer.serialize(parsed);
      const String expected = '''source cave1.th
source cave2_renamed.th
export map -o output.pdf''';

      expect(serialized, expected);
    });

    test('preserves CRLF line endings when requested', () {
      const String original = "source cave.th\r\nexport map -o out.pdf";

      final THConfigFile parsed = parser.parseString(original);
      final String serialized = writer.serialize(parsed, lineEnding: '\r\n');

      expect(serialized, original);
    });

    test('serializes to bytes with correct encoding', () {
      const String original = '''encoding UTF-8
# Special characters: àáâãç
source cave.th''';

      final THConfigFile parsed = parser.parseString(original);
      final Uint8List bytes = writer.serializeToBytes(parsed);
      final String decoded = utf8.decode(bytes);

      expect(decoded, original);
    });
  });
}
