import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
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
    final file = THFile();

    test("THFile", () {
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
  point 2374 -482 station:fixed -name E15@final_de_semana_31_de_julho_de_2016 \
      -visibility off
endscrap
""",
      },
    ];

    for (var success in successes) {
      test(success['file']!, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, errors) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
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
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, errors) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(
          isSuccessful,
          true,
          reason: 'Failed to parse ${success['file']}: $errors',
        );
        expect(file, isA<THFile>());
        expect(file.countElements(), success['countElements']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
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
  point 322.4 431.7 station -name A1
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
  point 322.4 431.7 station -name A1
endscrap
""",
      'asFile3': r"""encoding UTF-8
comment
The scrap below is really complex.
Take care!!
endcomment
scrap poco_surubim_SCP01 -scale [ -164 -2396 3308 -2396 0 0 88.1888 0 m ]
  point 322.4 431.7 station -name A1
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
      final parser = THFileParser();
      final writer = THFileWriter();
      mpLocator.mpGeneralController.reset();
      final (file, isSuccessful, errors) = await parser.parse(
        THTestAux.testPath(success['file'] as String),
      );
      expect(isSuccessful, true);
      expect(file, isA<THFile>());
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
      final parser = THFileParser();
      final writer = THFileWriter();
      mpLocator.mpGeneralController.reset();
      final (file, isSuccessful, errors) = await parser.parse(
        THTestAux.testPath(success['file'] as String),
        forceNewController: true,
      );
      expect(isSuccessful, true);
      expect(file, isA<THFile>());
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

  point 322.4 431.7 station -name A1
endscrap
""",
    };

    test("${success['file']} as once", () async {
      final parser = THFileParser();
      final writer = THFileWriter();
      mpLocator.mpGeneralController.reset();
      final (file, isSuccessful, errors) = await parser.parse(
        THTestAux.testPath(success['file'] as String),
        forceNewController: true,
      );
      expect(isSuccessful, true);
      expect(file, isA<THFile>());
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
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, errors) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        print(errors);
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
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
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, errors) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        print(errors);
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
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
