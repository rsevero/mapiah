// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'th_test_aux.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp'; // or any fake path
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();
  group('initial', () {
    final file = TH2File();

    test("TH2File", () {
      expect(file.mpID, -1);
      expect(file.elements.length, 0);
    });
  });

  group('line breaks', () {
    var successes = [
      {
        'file': 'th_file_parser-00000-line_breaks.th2',
        'countElements': 3,
        'asFile': """encoding UTF-8
scrap poco_surubim_SCP01
endscrap
""",
      },
      {
        'file': 'th_file_parser-00001-no_linebreak_at_file_end.th2',
        'countElements': 3,
        'asFile': """encoding UTF-8
scrap poco_surubim_SCP01
endscrap
""",
      },
      {
        'file': 'th_file_parser-00002-backslash_ending.th2',
        'countElements': 3,
        'asFile': """encoding UTF-8
scrap poco_surubim_SCP01
endscrap
""",
      },
      {
        'file': 'th_file_parser-00003-long_line_indentation.th2',
        'countElements': 4,
        'asFile': r"""encoding UTF-8
scrap poco_surubim_SCP01
  point 2374 -482 station:fixed -station E15@final_de_semana_31_de_julho_de_2016 \
      -visibility off
endscrap
""",
      },
    ];

    for (var success in successes) {
      test(success['file']!, () async {
        final parser = TH2FileParser();
        final writer = TH2FileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, errors) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<TH2File>());
        expect(file.countElements(), success['countElements']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('xtherion config', () {
    var successes = [
      {
        'file': 'th_file_parser-00020-xtherionsetting_only.th2',
        'countElements': 2,
        'asFile': """encoding UTF-8
##XTHERION## xth_me_area_adjust -164 -2396 4206 1508
""",
      },
      {
        'file': 'th_file_parser-00035-xtherionimagesetting_only.th2',
        'countElements': 2,
        'asFile': """encoding UTF-8
##XTHERION## xth_me_image_insert {-36 1 1} {28 {}} "croquis/croqui-007.jpg" 0 {}
""",
      },
      {
        'file': 'th_file_parser-00040-adding_several_xtherionsettings.th2',
        'countElements': 5,
        'asFile': """encoding UTF-8
##XTHERION## xth_me_area_adjust -164 -2396 4206 1508
##XTHERION## xth_me_area_zoom_to 100
##XTHERION## xth_me_image_insert {1890 1 1} {1380 {}} "croquis/croqui-006.jpg" 0 {}
##XTHERION## xth_me_image_insert {-36 1 1} {28 {}} "croquis/croqui-007.jpg" 0 {}
""",
      },
    ];

    for (var success in successes) {
      test(success['file']!, () async {
        final parser = TH2FileParser();
        final writer = TH2FileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, errors) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(
          isSuccessful,
          true,
          reason: 'Failed to parse ${success['file']}: $errors',
        );
        expect(file, isA<TH2File>());
        expect(file.countElements(), success['countElements']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('mapiah config', () {
    test(
      'parses XTherion raster image inserts into THRasterXTherionImageInsertConfig',
      () async {
        final TH2FileParser parser = TH2FileParser();

        mpLocator.mpGeneralController.reset();

        final (
          TH2File file,
          bool isSuccessful,
          List<String> errors,
        ) = await parser.parse(
          THTestAux.testPath(
            'th_file_parser-00035-xtherionimagesetting_only.th2',
          ),
        );

        expect(isSuccessful, true, reason: 'Failed to parse file: $errors');
        expect(file.countElements(), 2);

        final THElement imageElement = file.elementByMPID(
          file.childrenMPIDs[1],
        );

        expect(imageElement, isA<THRasterXTherionImageInsertConfig>());
        expect(
          (imageElement as THXTherionImageInsertConfig).filename,
          'croquis/croqui-007.jpg',
        );
        expect(imageElement.xx.toString(), '-36');
        expect(imageElement.yy.toString(), '28');
      },
    );

    test('2026-04-07-001-mapiah_image_insert_only.th2', () async {
      final TH2FileParser parser = TH2FileParser();
      final TH2FileWriter writer = TH2FileWriter();

      mpLocator.mpGeneralController.reset();

      final (
        TH2File file,
        bool isSuccessful,
        List<String> errors,
      ) = await parser.parse(
        THTestAux.testPath('2026-04-07-001-mapiah_image_insert_only.th2'),
      );

      expect(
        isSuccessful,
        true,
        reason:
            'Failed to parse 2026-04-07-001-mapiah_image_insert_only.th2: $errors',
      );
      expect(file.countElements(), 3);

      final THElement rasterElement = file.elementByMPID(file.childrenMPIDs[1]);
      final THElement xviElement = file.elementByMPID(file.childrenMPIDs[2]);

      expect(rasterElement, isA<MPRasterImageInsertConfig>());
      expect(
        (rasterElement as MPRasterImageInsertConfig).filename,
        'images/photo.png',
      );
      expect(rasterElement.xx.toString(), '10');
      expect(rasterElement.yy.toString(), '20');

      expect(xviElement, isA<MPXVIImageInsertConfig>());
      expect(
        (xviElement as MPXVIImageInsertConfig).filename,
        'images/survey.xvi',
      );
      expect(xviElement.xviRoot, 'station_A');
      expect(xviElement.xx.toString(), '-36');
      expect(xviElement.yy.toString(), '28');

      final String asFile = writer.serialize(file);

      expect(asFile, """encoding UTF-8
##MAPIAH## image_insert_v1 {format=raster;filename=images%2Fphoto.png;xx=10;yy=20;xScale=1;yScale=1;rotationCenterDx=0;rotationCenterDy=0;rotationDeg=0}
##MAPIAH## image_insert_v1 {format=xvi;filename=images%2Fsurvey.xvi;xx=-36;yy=28;xScale=1;yScale=1;rotationCenterDx=0;rotationCenterDy=0;rotationDeg=0;xviRoot=station_A}
""");
    });

    test('malformed Mapiah image insert reports a parser error', () async {
      final TH2FileParser parser = TH2FileParser();

      mpLocator.mpGeneralController.reset();

      final (
        TH2File file,
        bool isSuccessful,
        List<String> errors,
      ) = await parser.parse(
        THTestAux.testPath('2026-04-07-002-mapiah_image_insert_malformed.th2'),
      );

      expect(isSuccessful, false);
      expect(file.countElements(), 1);
      expect(
        errors.any(
          (String error) =>
              error.contains('Failed to parse Mapiah image insert config'),
        ),
        isTrue,
      );
    });

    test(
      'mixed files containing XTherion and Mapiah image inserts stay readable',
      () async {
        final TH2FileParser parser = TH2FileParser();
        final TH2FileWriter writer = TH2FileWriter();

        mpLocator.mpGeneralController.reset();

        final (
          TH2File file,
          bool isSuccessful,
          List<String> errors,
        ) = await parser.parse(
          THTestAux.testPath('2026-04-07-003-mixed_image_insert_styles.th2'),
        );

        expect(
          isSuccessful,
          true,
          reason: 'Failed to parse mixed file: $errors',
        );
        expect(file.countElements(), 4);

        final THElement firstImage = file.elementByMPID(file.childrenMPIDs[1]);
        final THElement secondImage = file.elementByMPID(file.childrenMPIDs[2]);
        final THElement thirdImage = file.elementByMPID(file.childrenMPIDs[3]);

        expect(firstImage, isA<THXTherionImageInsertConfig>());
        expect(secondImage, isA<MPXVIImageInsertConfig>());
        expect(thirdImage, isA<MPRasterImageInsertConfig>());

        final String asFile = writer.serialize(file);

        expect(asFile, """encoding UTF-8
##XTHERION## xth_me_image_insert {-36 1 1} {28 {}} "croquis/croqui-007.jpg" 0 {}
##MAPIAH## image_insert_v1 {format=xvi;filename=images%2Fsurvey.xvi;xx=100;yy=200;xScale=1.5;yScale=0.5;rotationCenterDx=7;rotationCenterDy=8;rotationDeg=45;xviRoot=station_A}
##MAPIAH## image_insert_v1 {format=raster;filename=images%2Fphoto.png;xx=10;yy=20;xScale=1;yScale=2;rotationCenterDx=3;rotationCenterDy=4;rotationDeg=5}
""");
      },
    );

    test(
      'serializes Mapiah and XTherion image inserts in one ordered config block',
      () async {
        final TH2FileParser parser = TH2FileParser();
        final TH2FileWriter writer = TH2FileWriter();

        mpLocator.mpGeneralController.reset();

        final (
          TH2File file,
          bool isSuccessful,
          List<String> errors,
        ) = await parser.parse(
          THTestAux.testPath('th_file_parser-00000-line_breaks.th2'),
        );

        expect(
          isSuccessful,
          true,
          reason: 'Failed to parse base file: $errors',
        );

        final MPRasterImageInsertConfig mapiahImage = MPRasterImageInsertConfig(
          parentMPID: file.mpID,
          filename: 'images/photo.png',
          xx: 10.0,
          yy: 20.0,
        );
        final THXTherionImageInsertConfig xtherionImage =
            THXTherionImageInsertConfig(
              parentMPID: file.mpID,
              filename: 'croquis/croqui-007.jpg',
              xx: THDoublePart(value: -36.0),
              yy: THDoublePart(value: 28.0),
            );

        file.addElement(mapiahImage);
        file.addElementToParent(mapiahImage, elementPositionInParent: 1);
        file.addElement(xtherionImage);
        file.addElementToParent(
          xtherionImage,
          elementPositionInParent: mpAddChildAtEndOfParentChildrenList,
        );

        final String asFile = writer.serialize(file);

        expect(asFile, """encoding UTF-8
##MAPIAH## image_insert_v1 {format=raster;filename=images%2Fphoto.png;xx=10;yy=20;xScale=1;yScale=1;rotationCenterDx=0;rotationCenterDy=0;rotationDeg=0}
##XTHERION## xth_me_image_insert {-36 1 1} {28 {}} "croquis/croqui-007.jpg" 0 {}
scrap poco_surubim_SCP01
endscrap
""");
      },
    );
  });

  group('xtherion image reorder', () {
    test('reorders images through TH2File children order', () async {
      final TH2FileParser parser = TH2FileParser();
      final TH2FileWriter writer = TH2FileWriter();

      mpLocator.mpGeneralController.reset();

      final (
        TH2File file,
        bool isSuccessful,
        List<String> errors,
      ) = await parser.parse(
        THTestAux.testPath(
          'th_file_parser-00040-adding_several_xtherionsettings.th2',
        ),
      );

      expect(isSuccessful, true, reason: 'Failed to parse file: $errors');
      expect(
        file.imageMPIDs.map((int mpID) => file.imageByMPID(mpID).filename),
        <String>['croquis/croqui-006.jpg', 'croquis/croqui-007.jpg'],
      );

      file.reorderImageMPIDs(oldIndex: 0, newIndex: 1);

      expect(
        file.imageMPIDs.map((int mpID) => file.imageByMPID(mpID).filename),
        <String>['croquis/croqui-007.jpg', 'croquis/croqui-006.jpg'],
      );

      final String asFile = writer.serialize(file);

      expect(asFile, """encoding UTF-8
##XTHERION## xth_me_area_adjust -164 -2396 4206 1508
##XTHERION## xth_me_area_zoom_to 100
##XTHERION## xth_me_image_insert {-36 1 1} {28 {}} "croquis/croqui-007.jpg" 0 {}
##XTHERION## xth_me_image_insert {1890 1 1} {1380 {}} "croquis/croqui-006.jpg" 0 {}
""");
    });
  });

  group('remove elements', () {
    var success = {
      'file': 'th_file_parser-02300-delete_elements.th2',
      'countElements': 26,
      'asFile': r"""encoding UTF-8
comment
The scrap below is really complex.
Take care!!
endcomment
scrap poco_surubim_SCP01 -scale [ -164 -2396 3308 -2396 0 0 88.1888 0 m ]
  point 42.1 -5448.8 guano -id P1 -visibility off
  comment

Another comment block.

But this one is inside a scrap!

This line below is not a scrap, it's a comment.
scrap test
endscrap

And this one also
scrap test2

  endcomment
  point 322.4 431.7 station -station A1
endscrap
""",
      'asFile2': r"""encoding UTF-8
comment
The scrap below is really complex.
Take care!!
endcomment
scrap poco_surubim_SCP01 -scale [ -164 -2396 3308 -2396 0 0 88.1888 0 m ]
  comment

Another comment block.

But this one is inside a scrap!

This line below is not a scrap, it's a comment.
scrap test
endscrap

And this one also
scrap test2

  endcomment
  point 322.4 431.7 station -station A1
endscrap
""",
      'asFile3': r"""encoding UTF-8
comment
The scrap below is really complex.
Take care!!
endcomment
scrap poco_surubim_SCP01 -scale [ -164 -2396 3308 -2396 0 0 88.1888 0 m ]
  point 322.4 431.7 station -station A1
endscrap
""",
      'asFile4': r"""encoding UTF-8
comment
The scrap below is really complex.
Take care!!
endcomment
""",
    };

    test("${success['file']} in parts", () async {
      final parser = TH2FileParser();
      final writer = TH2FileWriter();
      mpLocator.mpGeneralController.reset();
      final (file, isSuccessful, errors) = await parser.parse(
        THTestAux.testPath(success['file'] as String),
      );
      expect(isSuccessful, true);
      expect(file, isA<TH2File>());
      expect(file.countElements(), success['countElements']);

      var asFile = writer.serialize(file);
      expect(asFile, success['asFile']);

      expect(file.hasElementByTHID('poco_surubim_SCP01'), true);
      expect(file.hasElementByTHID('test'), false);

      var pointStation = file.elementByPosition(24);
      expect(pointStation, isA<THPoint>());
      expect((pointStation as THPoint).plaType, 'station');

      pointStation = file.elementByMPID(25);
      expect(pointStation, isA<THPoint>());
      expect((pointStation as THPoint).plaType, 'station');

      final pointGuano = file.elementByTHID('P1');
      expect(pointGuano, isA<THPoint>());
      expect((pointGuano as THPoint).plaType, 'guano');

      var countRemovedElements = 1;
      file.removeElement(pointGuano);
      expect(
        file.countElements(),
        (success['countElements'] as int) - countRemovedElements,
      );
      asFile = writer.serialize(file);
      expect(asFile, success['asFile2']);

      final multilineComment = file.elementByMPID(10);
      expect(multilineComment, isA<THMultiLineComment>());

      countRemovedElements +=
          (multilineComment as THMultiLineComment).childrenMPIDs.length + 1;
      file.removeElement(multilineComment);
      expect(
        file.countElements(),
        (success['countElements'] as int) - countRemovedElements,
      );
      asFile = writer.serialize(file);
      expect(asFile, success['asFile3']);

      var scrap = file.elementByTHID('poco_surubim_SCP01');
      countRemovedElements += (scrap as THScrap).childrenMPIDs.length + 1;
      file.removeElementByTHID('poco_surubim_SCP01');
      expect(
        file.countElements(),
        (success['countElements'] as int) - countRemovedElements,
      );

      file.clear();
      expect(file.countElements(), 0);
    });

    test("${success['file']} as once", () async {
      final parser = TH2FileParser();
      final writer = TH2FileWriter();
      mpLocator.mpGeneralController.reset();
      final (file, isSuccessful, errors) = await parser.parse(
        THTestAux.testPath(success['file'] as String),
        forceNewController: true,
      );
      expect(isSuccessful, true);
      expect(file, isA<TH2File>());
      expect(file.countElements(), success['countElements']);

      var asFile = writer.serialize(file);
      expect(asFile, success['asFile']);

      file.clear();
      expect(file.countElements(), 0);
    });
  });

  group('keep empty lines', () {
    var success = {
      'file': 'th_file_parser-02300-delete_elements.th2',
      'countElements': 26,
      'asFile': r"""encoding UTF-8
comment
The scrap below is really complex.
Take care!!
endcomment

scrap poco_surubim_SCP01 -scale [ -164 -2396 3308 -2396 0 0 88.1888 0 m ]
  point 42.1 -5448.8 guano -id P1 -visibility off

  comment

Another comment block.

But this one is inside a scrap!

This line below is not a scrap, it's a comment.
scrap test
endscrap

And this one also
scrap test2

  endcomment

  point 322.4 431.7 station -station A1
endscrap
""",
    };

    test("${success['file']} as once", () async {
      final parser = TH2FileParser();
      final writer = TH2FileWriter();
      mpLocator.mpGeneralController.reset();
      final (file, isSuccessful, errors) = await parser.parse(
        THTestAux.testPath(success['file'] as String),
        forceNewController: true,
      );
      expect(isSuccessful, true);
      expect(file, isA<TH2File>());
      expect(file.countElements(), success['countElements']);

      final String asFile = writer.serialize(file, includeEmptyLines: true);
      expect(asFile, success['asFile']);
    });
  });

  group('IDs and references with spaces: Mapiah format output', () {
    var successes = {
      {
        'file': '2025-12-07-001-area_border_th_id_with_spaces.th2',
        'length': 13,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area clay
    l85_3732__20
  endarea
  line border -id l85_3732__20 -close on -visibility off
    3592 208
    3539.45 249.03 3447.39 245.1 3392 208
    3233.22 101.65 3066.45 -131.93 3204 -332
    3266.87 -423.45 3365.54 -513.28 3476 -524
    3929.86 -568.03 3743.42 89.77 3592 208
  endline
endscrap
''',
      },
      {
        'file': '2025-12-07-002-area_border_th_id_with_spaces_as_last.th2',
        'length': 13,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area clay
    l85_3732__20
  endarea
  line border -id l85_3732__20 -close on -visibility off
    3592 208
    3539.45 249.03 3447.39 245.1 3392 208
    3233.22 101.65 3066.45 -131.93 3204 -332
    3266.87 -423.45 3365.54 -513.28 3476 -524
    3929.86 -568.03 3743.42 89.77 3592 208
  endline
endscrap
''',
      },
      {
        'file': '2025-12-09-001-scrap_with_name_with_spaces.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras5_2022
endscrap
''',
      },
      {
        'file':
            '2025-12-09-002-scrap_with_name_with_spaces_and_flip_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras5_2022 -flip vertical
endscrap
''',
      },
      {
        'file': '2025-12-09-003-scrap_with_name_with_spaces_and_hyphen.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras-5_2022
endscrap
''',
      },
      {
        'file':
            '2025-12-09-004-scrap_with_name_with_spaces_and_hyphen_and_flip_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras-5_2022 -flip vertical
endscrap
''',
      },
    };

    for (var success in successes) {
      test("$success with Mapiah format output", () async {
        final parser = TH2FileParser();
        final writer = TH2FileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, errors) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        print(errors);
        expect(isSuccessful, true);
        expect(file, isA<TH2File>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final String asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('IDs and references with spaces: original format output', () {
    var successes = {
      {
        'file': '2025-12-07-001-area_border_th_id_with_spaces.th2',
        'length': 13,
        'encoding': 'UTF-8',
        'asFile':
            'encoding utf-8\n'
            'scrap test\n'
            '\tarea clay\n'
            '    l85_3732__20\n'
            '\tendarea\n'
            '  line border -id l85_3732__20 -close on -visibility off\n'
            '\t\t3592 208\n'
            '\t\t3539.45 249.03 3447.39 245.1 3392 208\n'
            '\t\t3233.22 101.65 3066.45 -131.93 3204 -332\n'
            '\t\t3266.87 -423.45 3365.54 -513.28 3476 -524\n'
            '\t\t3929.86 -568.03 3743.42 89.77 3592 208\n'
            '\tendline\n'
            'endscrap\n'
            '',
      },
      {
        'file': '2025-12-07-002-area_border_th_id_with_spaces_as_last.th2',
        'length': 13,
        'encoding': 'UTF-8',
        'asFile':
            'encoding utf-8\n'
            'scrap test\n'
            '\tarea clay\n'
            '    l85_3732__20\n'
            '\tendarea\n'
            '  line border -id l85_3732__20 -close on -visibility off\n'
            '\t\t3592 208\n'
            '\t\t3539.45 249.03 3447.39 245.1 3392 208\n'
            '\t\t3233.22 101.65 3066.45 -131.93 3204 -332\n'
            '\t\t3266.87 -423.45 3365.54 -513.28 3476 -524\n'
            '\t\t3929.86 -568.03 3743.42 89.77 3592 208\n'
            '\tendline\n'
            'endscrap\n'
            '',
      },
      {
        'file': '2025-12-09-001-scrap_with_name_with_spaces.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding utf-8
scrap araras5_2022
endscrap
''',
      },
      {
        'file':
            '2025-12-09-002-scrap_with_name_with_spaces_and_flip_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding utf-8
scrap araras5_2022 -flip vertical
endscrap
''',
      },
      {
        'file': '2025-12-09-003-scrap_with_name_with_spaces_and_hyphen.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding utf-8
scrap araras-5_2022
endscrap
''',
      },
      {
        'file':
            '2025-12-09-004-scrap_with_name_with_spaces_and_hyphen_and_flip_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding utf-8
scrap araras-5_2022 -flip vertical
endscrap
''',
      },
    };

    for (var success in successes) {
      test("$success with original format output", () async {
        final parser = TH2FileParser();
        final writer = TH2FileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, errors) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        print(errors);
        expect(isSuccessful, true);
        expect(file, isA<TH2File>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final String asFile = writer.serialize(
          file,
          useOriginalRepresentation: true,
        );
        expect(asFile, success['asFile']);
      });
    }
  });
}
