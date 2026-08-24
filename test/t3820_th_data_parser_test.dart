// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/elements/th_data/th_centreline.dart';
import 'package:mapiah/src/elements/th_data/th_data_file.dart';
import 'package:mapiah/src/elements/th_data/th_data_input.dart';
import 'package:mapiah/src/elements/th_data/th_equate.dart';
import 'package:mapiah/src/elements/th_data/th_import.dart';
import 'package:mapiah/src/elements/th_data/th_join.dart';
import 'package:mapiah/src/elements/th_data/th_map.dart';
import 'package:mapiah/src/elements/th_data/th_survey.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';

void main() {
  group('THFileParser', () {
    late THFileParser parser;

    setUp(() {
      parser = THFileParser();
    });

    test('parses nested surveys with hierarchy', () {
      const String content = '''
survey cave_system -title "Mammoth Cave System"
  survey entrance_section
    survey passage_a
      input passage_a.th2
    endsurvey
  endsurvey
endsurvey
''';

      final THDataFile result = parser.parseString(content);

      expect(result.surveys.length, 1);
      final THSurvey rootSurvey = result.surveys.first;
      expect(rootSurvey.surveyId, 'cave_system');
      expect(rootSurvey.children.length, 1);

      final THSurvey subSurvey = rootSurvey.children.first as THSurvey;
      expect(subSurvey.surveyId, 'entrance_section');
      expect(subSurvey.children.length, 1);

      final THSurvey subSubSurvey = subSurvey.children.first as THSurvey;
      expect(subSubSurvey.surveyId, 'passage_a');
      expect(subSubSurvey.children.length, 1);
      expect(subSubSurvey.children.first, isA<THDataInput>());
      expect((subSubSurvey.children.first as THDataInput).rawPath, 'passage_a.th2');
      expect(result.parseErrors, isEmpty);
    });

    test('parses input directives and resolves .th default extension', () {
      const String content = '''
input passage_one
input "subfolder/passage_two.th"
input passage_three.th2
''';

      final THDataFile result = parser.parseString(content);

      expect(result.inputs.length, 3);
      expect(result.inputs[0].rawPath, 'passage_one');
      expect(result.inputs[0].resolvedPath, 'passage_one.th');

      expect(result.inputs[1].rawPath, 'subfolder/passage_two.th');
      expect(result.inputs[1].resolvedPath, 'subfolder/passage_two.th');

      expect(result.inputs[2].rawPath, 'passage_three.th2');
      expect(result.inputs[2].resolvedPath, 'passage_three.th2');
      expect(result.parseErrors, isEmpty);
    });

    test('parses centreline blocks and shot readings', () {
      const String content = '''
centreline
  date 2026.08.24
  team "Rodrigo Severo"
  data normal from to length bearing gradient
  1 2 10.50 045.0 +02.5
  2 3 15.20 090.0 -05.0
  3 4 08.75 180.0 +00.0
endcentreline
''';

      final THDataFile result = parser.parseString(content);

      expect(result.centrelines.length, 1);
      final THCentreline centreline = result.centrelines.first;
      expect(centreline.shots.length, 3);
      expect(centreline.shots[0].fromStation, '1');
      expect(centreline.shots[0].toStation, '2');
      expect(centreline.shots[0].length, 10.50);
      expect(centreline.shots[1].fromStation, '2');
      expect(centreline.shots[1].toStation, '3');
      expect(centreline.shots[1].length, 15.20);
      expect(result.parseErrors, isEmpty);
    });

    test('parses map blocks with projection and items', () {
      const String content = '''
map cave_plan_map -projection plan
  scrap_1@passage_a
  scrap_2@passage_a
  sub_map_b
endmap
''';

      final THDataFile result = parser.parseString(content);

      expect(result.maps.length, 1);
      final THMap map = result.maps.first;
      expect(map.mapId, 'cave_plan_map');
      expect(map.items.length, 3);
      expect(map.items[0], 'scrap_1@passage_a');
      expect(map.items[1], 'scrap_2@passage_a');
      expect(map.items[2], 'sub_map_b');
      expect(result.parseErrors, isEmpty);
    });

    test('parses equate and join directives', () {
      const String content = '''
equate 1@cave 2@passage 3@chamber
join line1@scrap1 line2@scrap2 -count 2
''';

      final THDataFile result = parser.parseString(content);

      expect(result.equates.length, 1);
      expect(result.equates.first.stations, ['1@cave', '2@passage', '3@chamber']);

      expect(result.joins.length, 1);
      expect(result.joins.first.line1, 'line1@scrap1');
      expect(result.joins.first.line2, 'line2@scrap2');
      expect(result.parseErrors, isEmpty);
    });

    test('parses import directives', () {
      const String content = '''
import "survey_data.3d" -surveys create
''';

      final THDataFile result = parser.parseString(content);

      expect(result.imports.length, 1);
      expect(result.imports.first.filePath, 'survey_data.3d');
      expect(result.parseErrors, isEmpty);
    });

    test('parses complete realistic .th file', () {
      const String content = '''
# Cave Survey Data
encoding UTF-8

survey main_cave
  input passage_1.th
  input passage_2.th
  input passage_1_plan.th2

  centreline
    date 2026.08.24
    team "Rodrigo Severo"
    1 2 12.45 090 0
    2 3 08.20 180 -10
  endcentreline

  equate 1@passage_1 2@passage_2

  map main_plan -projection plan
    scrap1@passage_1_plan
    scrap2@passage_1_plan
  endmap
endsurvey
''';

      final THDataFile result = parser.parseString(content);

      expect(result.encoding, 'UTF-8');
      expect(result.surveys.length, 1);

      final THSurvey survey = result.surveys.first;
      expect(survey.surveyId, 'main_cave');
      expect(survey.children.whereType<THDataInput>().length, 3);
      expect(survey.children.whereType<THCentreline>().length, 1);
      expect(survey.children.whereType<THEquate>().length, 1);
      expect(survey.children.whereType<THMap>().length, 1);
      expect(result.parseErrors, isEmpty);
    });
  });
}
