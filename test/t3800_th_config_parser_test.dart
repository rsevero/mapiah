// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/elements/th_config/th_config_comment.dart';
import 'package:mapiah/src/elements/th_config/th_config_export.dart';
import 'package:mapiah/src/elements/th_config/th_config_file.dart';
import 'package:mapiah/src/elements/th_config/th_config_input.dart';
import 'package:mapiah/src/elements/th_config/th_config_layout.dart';
import 'package:mapiah/src/elements/th_config/th_config_select.dart';
import 'package:mapiah/src/elements/th_config/th_config_setting.dart';
import 'package:mapiah/src/elements/th_config/th_config_source.dart';
import 'package:mapiah/src/mp_file_read_write/th_config_file_parser.dart';

void main() {
  group('THConfigFileParser', () {
    late THConfigFileParser parser;

    setUp(() {
      parser = THConfigFileParser();
    });

    test('parses empty lines and comments', () {
      const String content = '''# Top level comment
   # Indented comment

# Another comment''';

      final THConfigFile result = parser.parseString(content);

      expect(result.elements.length, 4);
      expect(result.elements[0], isA<THConfigComment>());
      expect((result.elements[0] as THConfigComment).commentText, '# Top level comment');
      expect((result.elements[1] as THConfigComment).commentText, '# Indented comment');
      expect((result.elements[2] as THConfigComment).isEmptyLine, isTrue);
      expect(result.parseErrors, isEmpty);
    });

    test('parses single-line and multi-line source directives', () {
      const String content = '''source cave.th
source "sub folder/survey.th"
source
  survey test
  endsurvey
endsource''';

      final THConfigFile result = parser.parseString(content);

      expect(result.elements.length, 3);
      expect(result.sourceFilePaths, ['cave.th', 'sub folder/survey.th']);

      final THConfigSource multiSource = result.elements[2] as THConfigSource;
      expect(multiSource.isMultiLine, isTrue);
      expect(multiSource.inlineCommands.length, 2);
      expect(multiSource.inlineCommands[0].trim(), 'survey test');
      expect(multiSource.inlineCommands[1].trim(), 'endsurvey');
      expect(result.parseErrors, isEmpty);
    });

    test('parses input directives', () {
      const String content = '''input layouts.cfg
input "shared/common_config.cfg"''';

      final THConfigFile result = parser.parseString(content);

      expect(result.elements.length, 2);
      expect(result.inputFilePaths, ['layouts.cfg', 'shared/common_config.cfg']);
      expect(result.elements[0], isA<THConfigInput>());
      expect((result.elements[0] as THConfigInput).filePath, 'layouts.cfg');
      expect(result.parseErrors, isEmpty);
    });

    test('parses layout blocks', () {
      const String content = '''layout my_layout
  scale 1 500
  base-scale 1 1000
  rotate 15
  units metric
  symbol-set UIS
  color map-bg [90 90 90]
endlayout''';

      final THConfigFile result = parser.parseString(content);

      expect(result.layouts.length, 1);
      final THConfigLayout layout = result.layouts.first;
      expect(layout.layoutId, 'my_layout');
      expect(layout.rawLines.length, 6);
      expect(layout.rawLines[0].trim(), 'scale 1 500');
      expect(result.parseErrors, isEmpty);
    });

    test('parses export commands with options', () {
      const String content = '''export map -output "cave_plan.pdf" -layout my_layout
export model -o cave.lox
export atlas -projection plan -layout atlas_layout''';

      final THConfigFile result = parser.parseString(content);

      expect(result.exports.length, 3);

      final THConfigExport exp1 = result.exports[0];
      expect(exp1.exportType, 'map');
      expect(exp1.outputFilePath, 'cave_plan.pdf');
      expect(exp1.layoutId, 'my_layout');

      final THConfigExport exp2 = result.exports[1];
      expect(exp2.exportType, 'model');
      expect(exp2.outputFilePath, 'cave.lox');

      final THConfigExport exp3 = result.exports[2];
      expect(exp3.exportType, 'atlas');
      expect(exp3.projection, 'plan');
      expect(exp3.layoutId, 'atlas_layout');
      expect(result.parseErrors, isEmpty);
    });

    test('parses select and unselect directives', () {
      const String content = '''select cave_system@main -recursive on
unselect passage_b''';

      final THConfigFile result = parser.parseString(content);

      expect(result.selects.length, 2);

      final THConfigSelect sel1 = result.selects[0];
      expect(sel1.isSelect, isTrue);
      expect(sel1.targetObjectId, 'cave_system@main');
      expect(sel1.rawOptions, ['-recursive', 'on']);

      final THConfigSelect sel2 = result.selects[1];
      expect(sel2.isSelect, isFalse);
      expect(sel2.targetObjectId, 'passage_b');
      expect(result.parseErrors, isEmpty);
    });

    test('parses global settings and encoding header', () {
      const String content = '''encoding UTF-8
cs UTM33N
language en_GB
system "echo compilation finished"
maps on
scrap-sort off
sketch-warp plaquette''';

      final THConfigFile result = parser.parseString(content);

      expect(result.encoding, 'UTF-8');
      expect(result.settings.length, 7);

      final THConfigSetting csSetting = result.settings[1];
      expect(csSetting.keyword, 'cs');
      expect(csSetting.argumentString, 'UTM33N');

      final THConfigSetting langSetting = result.settings[2];
      expect(langSetting.keyword, 'language');
      expect(langSetting.argumentString, 'en_GB');

      final THConfigSetting systemSetting = result.settings[3];
      expect(systemSetting.keyword, 'system');
      expect(systemSetting.argumentString, '"echo compilation finished"');
      expect(result.parseErrors, isEmpty);
    });

    test('handles line continuations with backslash', () {
      const String content = r'''export map \
  -output cave_plan.pdf \
  -layout my_layout''';

      final THConfigFile result = parser.parseString(content);

      expect(result.exports.length, 1);
      expect(result.exports.first.outputFilePath, 'cave_plan.pdf');
      expect(result.exports.first.layoutId, 'my_layout');
      expect(result.parseErrors, isEmpty);
    });

    test('parses complete real-world thconfig file', () {
      const String content = '''# Therion configuration for Mammoth Cave
encoding UTF-8
cs UTM33N

source mammoth.th

layout cave_layout
  scale 1 1000
  base-scale 1 1000
  rotate 0
  units metric
  symbol-set UIS
  legend on
  color map-bg [100 100 100]
endlayout

select cave_system -recursive on

export map -o mammoth_plan.pdf -layout cave_layout
export model -o mammoth.lox''';

      final THConfigFile result = parser.parseString(content);

      expect(result.sourceFilePaths, ['mammoth.th']);
      expect(result.layouts.length, 1);
      expect(result.layouts.first.layoutId, 'cave_layout');
      expect(result.selects.length, 1);
      expect(result.exports.length, 2);
      expect(result.exports[0].outputFilePath, 'mammoth_plan.pdf');
      expect(result.exports[1].outputFilePath, 'mammoth.lox');
      expect(result.parseErrors, isEmpty);
    });
  });
}
