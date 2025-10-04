import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
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
  group('scrap -author', () {
    const successes = [
      {
        'file': 'th_file_parser-00260-scrap_with_author_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras5 -author 2022.02.13@11:27:32 "Rodrigo Severo"
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00261-scrap_with_author_option_with_fractional_seconds.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras6 -author 2022.02.13@11:27:32.12 "Rodrigo Severo"
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00262-scrap_with_author_option_with_date_range.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras7 -author 2022.02.13@11:27:32 - 2022.02.13@11:58:00 "Rodrigo Severo"
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00263-scrap_with_author_option_with_quoted_name.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras8 -author 2022.02.13@11:58:00 "Rodrigo Severo/Cambará"
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00264-scrap_with_author_option_with_date_range_without_spaces.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras7 -author 2022.02.13@11:27:32 - 2022.02.13@11:58:00 "Rodrigo Severo"
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00265-scrap_with_author_option_with_empty_date_range.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras7 -author - "Rodrigo Severo"
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('scrap -copyright', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-00270-scrap_with_copyright_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras9 -copyright 2022.02.13@14:50:52 \
    "Todos os diretos reservados pra mim®"
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00271-scrap_with_copyright_option_with_embeded_quotes.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras9 -copyright 2022.02.13 \
    "Todos os diretos reservados pra ""Rodrigo Severo""®"
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('scrap -cs', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-00220-scrap_with_cs_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras1 -cs long-lat
endscrap
''',
      },
      {
        'file': 'th_file_parser-02073-scrap_and_endscrap_cs.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap poco_surubim_SCP01 -cs EPSG:3857
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('scrap -flip', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-00280-scrap_with_flip_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras10 -flip horizontal
endscrap
''',
      },
      {
        'file':
            'th_file_parser-02100-scrap_with_multiple_flip_options_failure.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap poco_surubim_SCP01 -flip vertical -projection [ elevation 10 ] -sketch \
    ./FrozenDeep_p.xvi 12 32
endscrap
''',
      },
      {
        'file':
            'th_file_parser-02101-scrap_with_multiple_identical_flip_options_failure.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap poco_surubim_SCP01 -flip horizontal -projection [ elevation 10 ] -sketch \
    ./FrozenDeep_p.xvi 12 32
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
          // trace: true,
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }

    var failures = [
      'th_file_parser-00281-scrap_with_flip_empty_option_failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, errors) = await parser.parse(
          THTestAux.testPath(failure),
        );
        expect(isSuccessful, false);
      });
    }
  });

  group('scrap -projection', () {
    const successes = [
      {
        'file': 'th_file_parser-00070-scrap_and_endscrap_projection_none.th2',
        'length': 2,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap poco_surubim_SCP01 -projection none
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00071-scrap_and_endscrap_projection_elevation_complete.th2',
        'length': 2,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap poco_surubim_SCP01 -projection [ elevation 10 deg ]
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00072-scrap_and_endscrap_projection_elevation_semi_complete.th2',
        'length': 2,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap poco_surubim_SCP01 -projection [ elevation 10 ]
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00073-scrap_and_endscrap_projection_extended_with_index.th2',
        'length': 2,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap poco_surubim_SCP01 -projection extended:strange_index
endscrap
''',
      },
      {
        'file': 'th_file_parser-00290-scrap_with_projection_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras12 -projection none
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00291-scrap_with_projection_option_with_index.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras13 -projection plan:main
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00292-scrap_with_projection_option_with_elevation_with_direction.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras14 -projection [ elevation:alternative 273 grad ]
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('scrap -scale', () {
    const successes = [
      {
        'file': 'th_file_parser-00012-encoding_with_trailing_comment.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFile': 'encoding UTF-8 # end of line comment\n',
      },
      {
        'file': 'th_file_parser-00061-scrap_and_endscrap.th2',
        'length': 2,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap poco_surubim_SCP01 -scale [ -164 -2396 3308 -2396 0 0 88.1888 0 m ]
endscrap
''',
      },
      {
        'file': 'th_file_parser-00064-scrap_and_endscrap_simplier_scale.th2',
        'length': 2,
        'encoding': 'UTF-8',
        'asFile': '''encoding UTF-8
scrap poco_surubim_SCP01 -scale [ -164 -2396 m ]
endscrap
''',
      },
      {
        'file': 'th_file_parser-00065-scrap_and_endscrap_simpliest_scale.th2',
        'length': 2,
        'encoding': 'UTF-8',
        'asFile': '''encoding UTF-8
scrap poco_surubim_SCP01 -scale [ 231.27 m ]
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('scrap -sketch', () {
    const successes = [
      {
        'file': 'th_file_parser-00300-scrap_with_sketch_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras15 -sketch ./FrozenDeep_p.xvi 12 32
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('scrap -station-names', () {
    const successes = [
      {
        'file': 'th_file_parser-00310-scrap_with_station-names_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras16 -station-names [] 2021-12-28.reveillon2021
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('scrap -stations', () {
    const successes = [
      {
        'file': 'th_file_parser-00230-scrap_with_stations_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras2 -stations a2,c4
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('scrap -title', () {
    const successes = [
      {
        'file': 'th_file_parser-00240-scrap_with_title_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras3 -title "Buraco das Araras - Salão Seco"
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('scrap -walls', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-00250-scrap_with_walls_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras4 -walls off
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('scrap MULTIPLE OPTIONS', () {
    const successes = [
      {
        'file':
            'th_file_parser-02075-scrap_and_endscrap_projection_flip_sketch.th2',
        'length': 3,
        'encoding': 'ISO8859-15',
        'asFile': r'''encoding ISO8859-15
scrap poco_surubim_SCP01 -flip horizontal -projection [ elevation 10 ] -sketch \
    ./FrozenDeep_p.xvi 12 32
endscrap
''',
      },
      {
        'file':
            '2025-01-09-th_file_parser-scrap_with_projection_author_scale.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap s8-1p -author 2016.05.29 "Adolpho Milhommen" -projection plan -scale [ 0 0 \
    96 0 0 0 200 0 in ]
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, success['encoding']);
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('scrap NO OPTIONS', () {
    const successes = [
      {
        'file': 'th_file_parser-02077-scrap_with_no_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras10
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('scrap failures', () {
    const failures = [
      'th_file_parser-00062-scrap_with_encoding_inside-failure.th2',
      'th_file_parser-00063-scrap_with_another_scrap_inside-failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final parser = THFileParser();
        mpLocator.mpGeneralController.reset();
        final (_, isSuccessful, error) = await parser.parse(
          THTestAux.testPath(failure),
        );
        expect(isSuccessful, false);
      });
    }
  });
}
