import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_file_aux/th_file_parser.dart';
import 'package:mapiah/src/th_file_aux/th_file_writer.dart';
import 'package:mapiah/src/th_file_aux/th_grammar.dart';
import 'package:test/test.dart';

void main() {
  group('scrap -author', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-00260-scrap_with_author_option.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras5 -author 2022.02.13@11:27:32 Rodrigo Severo
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00261-scrap_with_author_option_with_fractional_seconds.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras6 -author 2022.02.13@11:27:32.12 Rodrigo Severo
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00262-scrap_with_author_option_with_date_range.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras7 -author 2022.02.13@11:27:32 - 2022.02.13@11:58:00 Rodrigo Severo
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
scrap araras7 -author 2022.02.13@11:27:32 - 2022.02.13@11:58:00 Rodrigo Severo
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00265-scrap_with_author_option_with_empty_date_range.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap araras7 -author - Rodrigo Severo
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) =
            await parser.parse((success['file'] as String));
        // final (file, isSuccessful, errors) = await parser.parse((success['file'] as String),
        //     startParser: grammar.start());
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
    // final grammar = THGrammar();
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
        final (file, isSuccessful, _) =
            await parser.parse((success['file'] as String));
        // final (file, isSuccessful, errors) = await parser.parse((success['file'] as String),
        //     startParser: grammar.start());
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
    // final grammar = THGrammar();
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
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) =
            await parser.parse((success['file'] as String));
        // final (file, isSuccessful, errors) = await parser.parse((success['file'] as String),
        //     startParser: grammar.start());
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
        final (_, isSuccessful, errors) = await parser.parse(failure);
        // final (file, isSuccessful, errors) =
        //     await parser.parse(success, startParser: grammar.start());
        expect(isSuccessful, false);
        // print(errors.toString());
      });
    }
  });

  group('scrap -projection', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

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
scrap poco_surubim_SCP01 -projection [elevation 10 deg]
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00072-scrap_and_endscrap_projection_elevation_semi_complete.th2',
        'length': 2,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap poco_surubim_SCP01 -projection [elevation 10]
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
scrap araras14 -projection [elevation:alternative 273 grad]
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) =
            await parser.parse((success['file'] as String));
        // final (file, isSuccessful, errors) = await parser.parse((success['file'] as String),
        //     startParser: grammar.start());
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
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

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
scrap poco_surubim_SCP01 -scale [ -164.0 -2396.0 3308.0 -2396.0 0.0 0.0 88.1888 \
    0.0 m ]
endscrap
''',
      },
      {
        'file': 'th_file_parser-00064-scrap_and_endscrap_simplier_scale.th2',
        'length': 2,
        'encoding': 'UTF-8',
        'asFile': '''encoding UTF-8
scrap poco_surubim_SCP01 -scale [ -164.0 -2396.0 m ]
endscrap
''',
      },
      {
        'file': 'th_file_parser-00065-scrap_and_endscrap_simpliest_scale.th2',
        'length': 2,
        'encoding': 'UTF-8',
        'asFile': '''encoding UTF-8
scrap poco_surubim_SCP01 -scale 231.27
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) =
            await parser.parse((success['file'] as String));
        // final (file, isSuccessful, errors) = await parser.parse((success['file'] as String),
        //     startParser: grammar.start());
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
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

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
        final (file, isSuccessful, _) =
            await parser.parse((success['file'] as String));
        // final (file, isSuccessful, errors) = await parser.parse((success['file'] as String),
        //     startParser: grammar.start());
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
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

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
        final (file, isSuccessful, _) =
            await parser.parse((success['file'] as String));
        // final (file, isSuccessful, errors) = await parser.parse((success['file'] as String),
        //     startParser: grammar.start());
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
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

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
        final (file, isSuccessful, _) =
            await parser.parse((success['file'] as String));
        // final (file, isSuccessful, errors) = await parser.parse((success['file'] as String),
        //     startParser: grammar.start());
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
    // final grammar = THGrammar();
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
        final (file, isSuccessful, _) =
            await parser.parse((success['file'] as String));
        // final (file, isSuccessful, errors) = await parser.parse((success['file'] as String),
        //     startParser: grammar.start());
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });
}
