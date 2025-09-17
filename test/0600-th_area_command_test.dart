import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:test/test.dart';
import 'th_test_aux.dart';

final MPLocator mpLocator = MPLocator();

void main() {
  group('area', () {
    const successes = [
      {
        'file': 'th_file_parser-00090-area_only.th2',
        'length': 6,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area clay -clip on
  endarea
endscrap
''',
      },
      {
        'file': 'th_file_parser-00091-area_with_line_id.th2',
        'length': 6,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area clay -clip on
    l85-3732--20
  endarea
endscrap
''',
      },
      {
        'file': 'th_file_parser-00092-area_with_line_id_and_line.th2',
        'length': 14,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area clay -clip on
    l85-3732--20
  endarea
  line border -id l85-3732--20 -close on -visibility off
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
        'file': '2025-09-17-001-line_included_in_area_without_id.th2',
        'length': 12,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap poco_surubim_SCP03 -projection plan -scale [ -164 -2396 3308 -2396 0 0 \
    88.1888 0 m ]
  line wall -close on
    2057.2 -718
    1924.4 -828.8
    2072.7 -924.1
    2197.1 -822
  endline
  area water -id area1
    area1-line1
  endarea
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

  group('area unknown type', () {
    const successes = [
      {
        'file': 'th_file_parser-00093-area_unknown_type.th2',
        'length': 6,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area pool -clip on
  endarea
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

  group('area -clip', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03230-area_with_clip_option.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area clay -clip off
  endarea
endscrap
''',
      },
      {
        'file': 'th_file_parser-03231-area_with_command_like_clip_option.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area clay -clip off
  endarea
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

  group('area -clip failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-03232-area_with_invalid_command_like_clip_option-failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(
          THTestAux.testPath(failure),
        );
        expect(isSuccessful, false);
      });
    }
  });

  group('area -context', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03250-area_with_context_option.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area water -context point anchor
  endarea
endscrap
''',
      },
      {
        'file':
            'th_file_parser-03251-area_with_command_like_context_option.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area water -context point anchor
  endarea
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

  group('area -id', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03260-area_with_id.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area water -id area51
  endarea
endscrap
''',
      },
      {
        'file': 'th_file_parser-03261-area_with_command_like_id.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area water -id area51
  endarea
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

  group('area -place', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03220-area_with_place_option.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area clay -place top
  endarea
endscrap
''',
      },
      {
        'file': 'th_file_parser-03221-area_with_command_like_place_option.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area clay -place top
  endarea
endscrap
''',
      },
      {
        'file':
            'th_file_parser-03223-area_with_command_like_place_option_and_same_line_comment.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area clay -place top # With a same line comment in the command like option
  endarea
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

  group('area -place failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-03222-area_with_invalid_command_like_place_option-failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(
          THTestAux.testPath(failure),
        );
        expect(isSuccessful, false);
      });
    }
  });

  group('area -visibility', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03240-area_with_visibility_option.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area clay -visibility off
  endarea
endscrap
''',
      },
      {
        'file':
            'th_file_parser-03241-area_with_command_like_visibility_option.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  area clay -visibility off
  endarea
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

  group('area -visibility failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-03242-area_with_invalid_command_like_visibility_option-failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(
          THTestAux.testPath(failure),
        );
        expect(isSuccessful, false);
      });
    }
  });
}
