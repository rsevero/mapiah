// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/elements/th_config/th_config_comment.dart';
import 'package:mapiah/src/elements/th_config/th_config_file.dart';
import 'package:mapiah/src/elements/th_config/th_config_input.dart';
import 'package:mapiah/src/elements/th_config/th_config_source.dart';
import 'package:mapiah/src/elements/th_data/th_data_comment.dart';
import 'package:mapiah/src/elements/th_data/th_data_file.dart';
import 'package:mapiah/src/elements/th_data/th_data_input.dart';
import 'package:mapiah/src/elements/th_data/th_import.dart';
import 'package:mapiah/src/elements/th_data/th_survey.dart';
import 'package:mapiah/src/mp_file_read_write/th_config_file_writer.dart';
import 'package:mapiah/src/mp_file_read_write/th_directive_rewrite_aux.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';

void main() {
  group('THDirectiveRewriteAux own-outgoing (config)', () {
    test('rewrites a relative source/input when the file moves directory', () {
      final THConfigFile configFile = THConfigFile(
        lineEnding: '\n',
        elements: [
          THConfigComment(commentText: '# a project', originalLine: '# a project'),
          THConfigSource(filePath: 'mammoth.th', originalLine: 'source mammoth.th'),
          THConfigInput(filePath: 'shared.thconfig', originalLine: 'input shared.thconfig'),
        ],
      );

      final int count = THDirectiveRewriteAux.rewriteOwnOutgoingConfigDirectives(
        configFile: configFile,
        oldAbsolutePath: '/project/cave.thconfig',
        newAbsolutePath: '/project/moved/cave.thconfig',
      );

      expect(count, 2);
      expect((configFile.elements[1] as THConfigSource).filePath, '../mammoth.th');
      expect((configFile.elements[2] as THConfigInput).filePath, '../shared.thconfig');
      // Untouched elements keep their originalLine (byte-for-byte round trip).
      expect(configFile.elements[0].originalLine, '# a project');
      expect(configFile.elements[0].isModified, isFalse);
    });

    test('leaves absolute directive paths untouched', () {
      final THConfigFile configFile = THConfigFile(
        lineEnding: '\n',
        elements: [
          THConfigSource(
            filePath: '/elsewhere/mammoth.th',
            originalLine: 'source /elsewhere/mammoth.th',
          ),
        ],
      );

      final int count = THDirectiveRewriteAux.rewriteOwnOutgoingConfigDirectives(
        configFile: configFile,
        oldAbsolutePath: '/project/cave.thconfig',
        newAbsolutePath: '/project/moved/cave.thconfig',
      );

      expect(count, 0);
      expect(configFile.elements[0].isModified, isFalse);
      expect(
        (configFile.elements[0] as THConfigSource).filePath,
        '/elsewhere/mammoth.th',
      );
    });

    test('does not rewrite a multi-line source block', () {
      final THConfigFile configFile = THConfigFile(
        lineEnding: '\n',
        elements: [
          THConfigSource(
            isMultiLine: true,
            inlineCommands: ['input mammoth.th'],
            originalLine: 'source',
          ),
        ],
      );

      final int count = THDirectiveRewriteAux.rewriteOwnOutgoingConfigDirectives(
        configFile: configFile,
        oldAbsolutePath: '/project/cave.thconfig',
        newAbsolutePath: '/project/moved/cave.thconfig',
      );

      expect(count, 0);
      expect(configFile.elements[0].isModified, isFalse);
    });

    test('reserializes with only the rewritten line changed', () {
      final THConfigFile configFile = THConfigFile(
        lineEnding: '\n',
        elements: [
          THConfigComment(commentText: '# header', originalLine: '# header'),
          THConfigSource(filePath: 'mammoth.th', originalLine: 'source mammoth.th'),
          THConfigComment(commentText: '', originalLine: '', isEmptyLine: true),
          THConfigInput(filePath: 'shared.thconfig', originalLine: 'input shared.thconfig'),
        ],
      );

      THDirectiveRewriteAux.rewriteOwnOutgoingConfigDirectives(
        configFile: configFile,
        oldAbsolutePath: '/project/cave.thconfig',
        newAbsolutePath: '/project/moved/cave.thconfig',
      );

      final String serialized = THConfigFileWriter().serialize(configFile);
      expect(
        serialized,
        '# header\nsource ../mammoth.th\n\ninput ../shared.thconfig',
      );
    });
  });

  group('THDirectiveRewriteAux incoming (config)', () {
    test('rewrites every directive referencing the moved target, ignores others', () {
      final THConfigFile dependentConfigFile = THConfigFile(
        lineEnding: '\n',
        elements: [
          THConfigInput(filePath: 'cave.thconfig', originalLine: 'input cave.thconfig'),
          THConfigInput(filePath: 'unrelated.thconfig', originalLine: 'input unrelated.thconfig'),
          // A second directive reaching the same target via a different spelling.
          THConfigInput(filePath: './cave.thconfig', originalLine: 'input ./cave.thconfig'),
        ],
      );

      final int count = THDirectiveRewriteAux.rewriteIncomingConfigDirectives(
        dependentConfigFile: dependentConfigFile,
        dependentAbsolutePath: '/project/root.thconfig',
        oldTargetCanonicalPath: '/project/cave.thconfig',
        newTargetCanonicalPath: '/project/moved/cave.thconfig',
      );

      expect(count, 2);
      expect(
        (dependentConfigFile.elements[0] as THConfigInput).filePath,
        './moved/cave.thconfig',
      );
      expect(
        (dependentConfigFile.elements[1] as THConfigInput).filePath,
        'unrelated.thconfig',
      );
      expect(dependentConfigFile.elements[1].isModified, isFalse);
      expect(
        (dependentConfigFile.elements[2] as THConfigInput).filePath,
        './moved/cave.thconfig',
      );
    });

    test('keeps an absolute reference to the moved target absolute', () {
      final THConfigFile dependentConfigFile = THConfigFile(
        lineEnding: '\n',
        elements: [
          THConfigInput(
            filePath: '/project/cave.thconfig',
            originalLine: 'input /project/cave.thconfig',
          ),
        ],
      );

      THDirectiveRewriteAux.rewriteIncomingConfigDirectives(
        dependentConfigFile: dependentConfigFile,
        dependentAbsolutePath: '/project/root.thconfig',
        oldTargetCanonicalPath: '/project/cave.thconfig',
        newTargetCanonicalPath: '/project/moved/cave.thconfig',
      );

      expect(
        (dependentConfigFile.elements[0] as THConfigInput).filePath,
        '/project/moved/cave.thconfig',
      );
    });
  });

  group('THDirectiveRewriteAux own-outgoing (data)', () {
    test('rewrites a relative input/import, including inside a nested survey', () {
      final THDataFile dataFile = THDataFile(
        lineEnding: '\n',
        elements: [
          THDataInput(rawPath: 'extra.th', originalLine: 'input extra.th'),
          THSurvey(
            surveyId: 'cave',
            originalLine: 'survey cave',
            endLine: 'endsurvey',
            children: [
              THImport(
                filePath: 'scraps/plan.th2',
                originalLine: 'import scraps/plan.th2',
              ),
            ],
          ),
        ],
      );

      final int count = THDirectiveRewriteAux.rewriteOwnOutgoingDataDirectives(
        dataFile: dataFile,
        oldAbsolutePath: '/project/cave.th',
        newAbsolutePath: '/project/moved/cave.th',
      );

      expect(count, 2);
      expect((dataFile.elements[0] as THDataInput).rawPath, '../extra.th');

      final THSurvey survey = dataFile.elements[1] as THSurvey;
      expect((survey.children[0] as THImport).filePath, '../scraps/plan.th2');
    });
  });

  group('THDirectiveRewriteAux incoming (data)', () {
    test('rewrites a nested import referencing the moved target', () {
      final THDataFile dependentDataFile = THDataFile(
        lineEnding: '\n',
        elements: [
          THSurvey(
            surveyId: 'cave',
            originalLine: 'survey cave',
            endLine: 'endsurvey',
            children: [
              THDataInput(rawPath: 'annex.th', originalLine: 'input annex.th'),
              THDataComment(commentText: '# unrelated', originalLine: '# unrelated'),
            ],
          ),
        ],
      );

      final int count = THDirectiveRewriteAux.rewriteIncomingDataDirectives(
        dependentDataFile: dependentDataFile,
        dependentAbsolutePath: '/project/root.th',
        oldTargetCanonicalPath: '/project/annex.th',
        newTargetCanonicalPath: '/project/moved/annex.th',
      );

      expect(count, 1);

      final THSurvey survey = dependentDataFile.elements[0] as THSurvey;
      expect((survey.children[0] as THDataInput).rawPath, './moved/annex.th');
      expect(survey.children[1].isModified, isFalse);
    });

    test('reserializes a moved-into data file with only the target line changed', () {
      final THDataFile dependentDataFile = THDataFile(
        lineEnding: '\n',
        elements: [
          THDataInput(rawPath: 'annex.th', originalLine: 'input annex.th'),
          THDataComment(commentText: '# unrelated', originalLine: '# unrelated'),
        ],
      );

      THDirectiveRewriteAux.rewriteIncomingDataDirectives(
        dependentDataFile: dependentDataFile,
        dependentAbsolutePath: '/project/root.th',
        oldTargetCanonicalPath: '/project/annex.th',
        newTargetCanonicalPath: '/project/moved/annex.th',
      );

      final String serialized = THFileWriter().serialize(dependentDataFile);
      expect(serialized, 'input ./moved/annex.th\n# unrelated');
    });
  });
}
