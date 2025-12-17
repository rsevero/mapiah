import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
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

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
  });
  group('line', () {
    const successes = [
      {
        'file': 'th_file_parser-00080-line_only.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
endscrap
''',
      },
      {
        'file': 'th_file_parser-00081-line_with_last_line_with_spaces_only.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
endscrap
''',
      },
      {
        'file':
            'th_file_parser-02373-line_with_only_straight_line_segments.th2',
        'length': 8,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap scrap1
  line wall
    355 1065
    291 499
    450 600
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-02372-line_with_segment_and_bezier_curve.th2',
        'length': 8,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap scrap1 -scale [ 0 0 1600 0 0 0 40.64 0 m ]
  line wall
    355 1065
    291 499
    450 600 589.72 521.11 650 600
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-02370-line_with_segments_and_bezier_curves.th2',
        'length': 32,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap scrap1 -scale [ 0 0 1600 0 0 0 40.64 0 m ]
  line wall
    355 1065
    291 499
    1124 503
    1139 1079
    355 1065
  endline
  point 1050 900 station -name a2
  point 450 900 station -name a1
  line chimney
    450 900
    450 600
    450 600 589.72 521.11 650 600
    731 706 649 898 649 898
    649 898 751 930 850 900
    774 854 850 600 850 600
    1050 600
    1050 900
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-02374-line_with_comment_in_data_line.th2',
        'length': 8,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap scrap1
  line wall
    355 1065 # Comment on data line
    450 600 589.72 521.11 650 600 # Comment on another data line
    291 499
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-02375-line_with_comment_in_line_option_in_line_data.th2',
        'length': 8,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap scrap1
  line slope -border on
    355 1065 # Comment on data line
    450 600 589.72 521.11 650 600 # Comment that Mapiah will move to the data line above
    291 499
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-02376-line_with_comment_in_line_option_in_line_data_to_join.th2',
        'length': 8,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap scrap1
  line slope -border on
    355 1065 # Comment on data line
    450 600 589.72 521.11 650 600 # Comment on another data line | Comment that Mapiah will join with the comment on the line above
    291 499
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00083-line_with_valid_straight_line_segment_as_first_line_segment.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line floor-step
    650 900
    650 900 827.81 933.28 850 900
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00085-line_with_valid_bezier_curve_as_first_line_segment.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line floor-step
    650 900 827.81 933.28 850 900
    650 900
  endline
endscrap
''',
      },
      {
        'file': '2025-11-28-001-line_walkway_type.th2',
        'length': 18,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap Bonita-1R1-1p
  line walkway
    111.95 -11.92
    104.54 -8.07
    98.77 -0.55
    93.29 6.6
    84.33 10.41
    78.4 15.76
    69.99 19.88
    61.64 26.23
    55.24 31.43
    47.76 37.91
    41.35 44.56
    35.24 50.04
    29.86 58.14
  endline
endscrap
''',
      },
      {
        'file':
            '2025-12-01-003-line_with_line_segment_option_at_last_line_segment.th2',
        'length': 9,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap Bonita-1R1-1p -projection plan -scale [ 0 0 39.3701 0 0 0 1 0 m ]
  line slope -id option_at_last_segment
    -46.89 31.54
    -36.66 36.61
    -29.52 41
    -19.68 45.42
      l-size 20
  endline
endscrap
''',
      },
      {
        'file': '2025-11-28-001-line_walkway_type.th2',
        'length': 18,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap Bonita-1R1-1p
  line walkway
    111.95 -11.92
    104.54 -8.07
    98.77 -0.55
    93.29 6.6
    84.33 10.41
    78.4 15.76
    69.99 19.88
    61.64 26.23
    55.24 31.43
    47.76 37.91
    41.35 44.56
    35.24 50.04
    29.86 58.14
  endline
endscrap
''',
      },
      {
        'file': '2025-12-05-001-line_with_repeated_points.th2',
        'length': 6,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap Janelao_3R1-1p
  # This file has a line with repeated points that should be automatically \
      removed by the parser.
  # This line is the sole border of an area which should also be removed by the \
      parser.
  # After parsed, this file should produce an empty scrap with these comments.
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

        final String asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('line original representation', () {
    const successes = [
      {
        'file': 'th_file_parser-00080-line_only.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
endscrap''',
      },
      {
        'file': 'th_file_parser-00081-line_with_last_line_with_spaces_only.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFile': r'''encoding utf-8
scrap test
endscrap
''',
      },
      {
        'file':
            'th_file_parser-02373-line_with_only_straight_line_segments.th2',
        'length': 8,
        'encoding': 'UTF-8',
        'asFile': r'''encoding  utf-8
scrap scrap1
line wall
  355.0 1065.0
  291.0 499.0
  450.0 600.0
endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-02372-line_with_segment_and_bezier_curve.th2',
        'length': 8,
        'encoding': 'UTF-8',
        'asFile': r'''encoding  utf-8
scrap scrap1 -scale [0 0 1600 0 0.0 0.0 40.64 0.0 m]
line wall
  355.0 1065.0
  291.0 499.0
450.0 600.0 589.72 521.11 650.0 600.0
endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-02370-line_with_segments_and_bezier_curves.th2',
        'length': 32,
        'encoding': 'UTF-8',
        'asFile':
            'encoding  utf-8\n'
            'scrap scrap1 -scale [0 0 1600 0 0.0 0.0 40.64 0.0 m]\n'
            'line wall\n'
            '  355.0 1065.0\n'
            '  291.0 499.0\n'
            '  1124.0 503.0\n'
            '  1139.0 1079.0\n'
            '  355.0 1065.0\n'
            'endline\n'
            'point 1050.0 900.0 station -name a2\n'
            'point 450.0 900.0 station -name a1\n'
            'line chimney\n'
            '  450.0 900.0\n'
            '  450.0 600.0\n'
            '  450.0 600.0 589.72 521.11 650.0 600.0\n'
            '  731.0 706.0 649.0 898.0 649.0 898.0\n'
            '  649.0 898.0 751.0 930.0 850.0 900.0\n'
            '  774.0 854.0 850.0 600.0 850.0 600.0\n'
            '  1050.0 600.0\n'
            '  1050.0 900.0\n'
            'endline\n'
            'endscrap\n'
            '',
      },
      {
        'file': 'th_file_parser-02374-line_with_comment_in_data_line.th2',
        'length': 8,
        'encoding': 'UTF-8',
        'asFile':
            'encoding  utf-8\n'
            'scrap scrap1\n'
            'line wall\n'
            '  355.0 1065.0 # Comment on data line\n'
            '  450.0 600.0 589.72 521.11 650.0 600.0 # Comment on another data line\n'
            '291.0 499.0\n'
            'endline\n'
            'endscrap\n'
            '',
      },
      {
        'file':
            'th_file_parser-02375-line_with_comment_in_line_option_in_line_data.th2',
        'length': 8,
        'encoding': 'UTF-8',
        'asFile':
            'encoding  utf-8\n'
            'scrap scrap1\n'
            '  line slope -border on\n'
            '  355.0 1065.0 # Comment on data line\n'
            '  450.0 600.0 589.72 521.11 650.0 600.0\n'
            '291.0 499.0\n'
            'endline\n'
            'endscrap\n'
            '',
      },
      {
        'file':
            'th_file_parser-02376-line_with_comment_in_line_option_in_line_data_to_join.th2',
        'length': 8,
        'encoding': 'UTF-8',
        'asFile':
            'encoding  utf-8\n'
            'scrap scrap1\n'
            '  line slope -border on\n'
            '  355.0 1065.0 # Comment on data line\n'
            '  450.0 600.0 589.72 521.11 650.0 600.0 # Comment on another data line\n'
            '291.0 499.0\n'
            'endline\n'
            'endscrap\n'
            '',
      },
      {
        'file':
            'th_file_parser-00083-line_with_valid_straight_line_segment_as_first_line_segment.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile':
            'encoding UTF-8\n'
            'scrap test\n'
            '\tline floor-step\n'
            '  650.0 900.0\n'
            '  650.0 900.0 827.81 933.28 850.0 900.0\n'
            '\tendline\n'
            'endscrap',
      },
      {
        'file':
            'th_file_parser-00085-line_with_valid_bezier_curve_as_first_line_segment.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile':
            'encoding UTF-8\n'
            'scrap test\n'
            '\tline floor-step\n'
            '  650.0 900.0 827.81 933.28 850.0 900.0\n'
            '  650.0 900.0\n'
            '\tendline\n'
            'endscrap',
      },
      {
        'file': '2025-11-28-001-line_walkway_type.th2',
        'length': 18,
        'encoding': 'UTF-8',
        'asFile':
            'encoding utf-8\n'
            'scrap Bonita-1R1-1p\n'
            '\tline walkway\n'
            '\t\t111.95 -11.92\n'
            '\t\t104.54 -8.07\n'
            '\t\t98.77 -0.55\n'
            '\t\t93.29 6.60\n'
            '\t\t84.33 10.41\n'
            '\t\t78.40 15.76\n'
            '\t\t69.99 19.88\n'
            '\t\t61.64 26.23\n'
            '\t\t55.24 31.43\n'
            '\t\t47.76 37.91\n'
            '\t\t41.35 44.56\n'
            '\t\t35.24 50.04\n'
            '\t\t29.86 58.14\n'
            '\tendline\n'
            'endscrap\n'
            '',
      },
      {
        'file':
            '2025-12-01-003-line_with_line_segment_option_at_last_line_segment.th2',
        'length': 9,
        'encoding': 'UTF-8',
        'asFile':
            'encoding utf-8\n'
            'scrap Bonita-1R1-1p -projection plan -scale [0 0 39.3701 0 0 0 1 0 m]\n'
            '\tline slope -id option_at_last_segment\n'
            '\t\t-46.89 31.54\n'
            '\t\t-36.66 36.61\n'
            '\t\t-29.52 41.00\n'
            '\t\t-19.68 45.42\n'
            '\t\tl-size 20\n'
            '\tendline\n'
            'endscrap\n'
            '',
      },
      {
        'file': '2025-12-09-005-line_with_anchors_option_as_line_data.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding utf-8
scrap test
  line rope -anchors on
1758 -1030
2147.74 -1120.48
endline
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

        final String asFile = writer.serialize(
          file,
          useOriginalRepresentation: true,
        );
        expect(asFile, success['asFile']);
      });
    }
  });

  group('line unknown type', () {
    const successes = [
      {
        'file': 'th_file_parser-00082-line_unknown_type.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line cable
    650 900
    650 900 827.81 933.28 850 900
  endline
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

  group('linepoint -adjust', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03080-linepoint_with_adjust_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line arrow
    1758 -1030
      adjust horizontal
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('linepoint -adjust failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-03081-line_with_adjust_option_invalid-failure.th2',
      'th_file_parser-03082-linepoint_with_invalid_adjust_option-failure.th2',
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

  group('linepoint -altitude', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file':
            'th_file_parser-03130-wall_line_with_altitude_linepoint_option_with_hyphen.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line wall
    0 0
      altitude NaN
    100 100
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03131-linepoint_with_altitude_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line wall
    1758 -1030
      altitude [ 4 m ]
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-03132-linepoint_with_altitude_option_with_invalid_line_type-failure.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line overhang
    1758 -1030
      altitude [ 4 m ]
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-03133-linepoint_with_altitude_option_with_fix.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line wall
    1758 -1030
      altitude [ fix 1510 ft ]
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-03134-altitude_point_with_value_option_set_as_nan.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line wall
    1758 -1030
      altitude NaN
    123 432
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-03135-linepoint_with_altitude_option_set_as_nan.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line wall
    1758 -1030
      altitude NaN
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-03136-altitude_point_with_value_option_with_fix.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line wall
    0 0
      altitude [ fix 1300 m ]
    100 100
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -anchors', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-02393-line_with_anchors_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line rope -anchors on
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': '2025-12-09-005-line_with_anchors_option_as_line_data.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line rope -anchors on
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -anchors failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-02395-line_with_invalid_anchors_option-failure.th2',
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

  group('linepoint -anchors', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-02390-linepoint_with_anchors_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line rope -anchors on
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('linepoint -anchors failures', () {
    final parser = THFileParser();

    const failures = [
      // 'th_file_parser-02391-linepoint_with_anchors_option_invalid_line_type-failure.th2',
      'th_file_parser-02392-linepoint_with_invalid_anchors_option-failure.th2',
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

  group('line -border', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03003-line_with_border_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line slope -border off
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-03006-linepoint_with_border_option_before_first_point.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line slope -border on
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -border failures', () {
    final parser = THFileParser();

    const failures = [
      // 'th_file_parser-03004-line_with_border_option_invalid_line_type-failure.th2',
      'th_file_parser-03005-line_with_invalid_border_option-failure.th2',
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

  group('linepoint -border', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03000-linepoint_with_border_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line slope -border on
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('linepoint -border failures', () {
    final parser = THFileParser();

    const failures = [
      // 'th_file_parser-03001-linepoint_with_border_option_invalid_line_type-failure.th2',
      'th_file_parser-03002-linepoint_with_invalid_border_option-failure.th2',
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

  group('line -clip', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03020-line_with_clip_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line moonmilk -clip off
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -clip failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-03021-line_with_invalid_clip_option-failure.th2',
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

  group('linepoint -clip', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03025-linepoint_with_clip_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line moonmilk -clip off
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('linepoint -clip failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-03026-linepoint_with_invalid_clip_option-failure.th2',
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

  group('line -close', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-02380-line_with_close_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line contour -close off
    2802 -969
    3804 3512
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -close failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-02381-line_with_invalid_close_option-failure.th2',
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

  group('linepoint -close', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03010-linepoint_with_close_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line contour -close off
    2802 -969
    3804 3512
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('linepoint -close failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-03011-linepoint_with_invalid_close_option-failure.th2',
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

  group('line -context', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03120-line_with_context_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line water-flow -context area water
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('linepoint -context', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03121-linepoint_with_context_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line water-flow -context area water
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -direction', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03070-line_with_direction_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line section -direction begin
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -direction failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-03072-line_with_direction_option_set_to_point_invalid-failure.th2',
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

  group('linepoint -direction', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03071-linepoint_with_direction_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line section -direction begin
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-03073-linepoint_with_direction_option_set_to_point.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line section
    1758 -1030
      direction point
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-03075-linepoint_with_direction_option_last_point.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line section
    1758 -1030
    2147.74 -1120.48
      direction point
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-03077-linepoint_with_direction_option_before_first_point_valid.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line section -direction both
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, errors) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('linepoint -direction failures', () {
    final parser = THFileParser();

    const failures = [
      // 'th_file_parser-03074-linepoint_with_direction_option_unsupported_line_type-failure.th2',
      'th_file_parser-03076-linepoint_with_direction_option_before_first_point_invalid-failure.th2',
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

  group('line -head', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03030-line_with_head_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line arrow -head both
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03031-linepoint_with_head_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line arrow -head both
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -height', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03180-line_with_height_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line pit -height 7
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03181-linepoint_with_height_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line pit -height 7
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -id', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03190-line_with_id_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line label -id buraco_das_araras
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03191-linepoint_with_id_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line label -id buraco_das_araras
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -id failures', () {
    final parser = THFileParser();

    const failures = ['th_file_parser-03192-line_with_invalid_id-failure.th2'];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(
          THTestAux.testPath(failure),
        );
        expect(isSuccessful, false);
      });
    }
  });

  group('linepoint l-size', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03140-linepoint_with_lsize_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line slope
    1758 -1030
      l-size 12
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03142-linepoint_with_size_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line slope
    1758 -1030
      l-size 12
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('linepoint l-size failures', () {
    final parser = THFileParser();

    const failures = [
      // 'th_file_parser-03141-linepoint_with_lsize_option_on_non_slope-failure.th2',
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

  group('linepoint -mark', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03110-linepoint_with_mark_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line water-flow
    1758 -1030
    2147.74 -1120.48
      mark test_mark
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('linepoint -mark failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-03111-linepoint_with_invalid_mark_option-failure.th2',
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

  group('linepoint orientation', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03150-linepoint_with_orientation_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line slope
    1758 -1030
      orientation 173.01
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-03151-linepoint_with_orientation_and_lsize_options.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line slope
    1758 -1030
      l-size 12
      orientation 173.01
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('linepoint orientation failures', () {
    final parser = THFileParser();

    const failures = [
      // 'th_file_parser-03152-linepoint_with_invalid_orientation_option-failure.th2',
      // 'th_file_parser-03153-linepoint_with_orientation_option_on_non-slope_line-failure.th2',
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

  group('line -outline', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03210-line_with_outline_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line slope -outline none
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03211-linepoint_with_outline_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line slope -outline none
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -outline failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-03212-linepoint_with_invalid_outline_option-failure.th2',
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

  group('line -place', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03200-line_with_place_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line slope -place top
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03201-linepoint_with_place_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line slope -place top
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -place failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-03202-linepoint_with_invalid_place_option-failure.th2',
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

  group('line -rebelays', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03060-line_with_rebelays_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line rope -rebelays on
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03061-linepoint_with_rebelays_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line rope -rebelays on
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -reverse', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03040-line_with_reverse_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line arrow -reverse on
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03041-linepoint_with_reverse_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line arrow -reverse on
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('linepoint -smooth', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03090-linepoint_with_adjust_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line arrow
    1758 -1030
      smooth on
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('linepoint -smooth failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-03091-line_with_smooth_option_invalid-failure.th2',
      'th_file_parser-03092-linepoint_with_invalid_smooth_option-failure.th2',
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

  group('line -scale', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03160-line_with_scale_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line label -scale xs
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03161-linepoint_with_scale_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line label -scale xs
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03164-linepoint_with_numeric_scale_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line label -scale 13
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -scale failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-03163-linepoint_with_text_scale_option-failure.th2',
      // 'th_file_parser-03165-linepoint_with_scale_option_and_invalid_line_type-failure.th2',
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

  group('linepoint -subtype', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03100-linepoint_with_subtype_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line water-flow:conjectural
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03105-line_with_subtype_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line water-flow:conjectural
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03106-line_with_subtype_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line water-flow:conjectural
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': '2025-06-21-line_point_subtype.th2',
        'length': 25,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap 141c-TradePlan-s1 -projection plan
  line wall
    5903 1247
    5898.5 1232 5895.5 1221.5 5894.5 1206.5
    5893.5 1191.5 5894.5 1188 5890 1179
    5885.5 1170 5881.5 1169 5883 1161
    5884.5 1153 5885.5 1149 5892 1137
    5898.5 1125 5905.5 1131.5 5903.5 1117
    5901.5 1102.5 5895.5 1094 5900.5 1081.5
    5905.5 1069 5908.5 1058.5 5907 1052
    5905.5 1045.5 5905.5 1049.5 5904.5 1035
    5903.5 1020.5 5906 1017 5905.5 1008.5
      subtype unsurveyed
    5904.41 990.02 5893.5 964.5 5912.5 962
    5931.5 959.5 5928 959.5 5933 969.5
    5938 979.5 5939.5 994 5938 1007
      subtype bedrock
    5936.5 1020 5934.5 1030 5935.5 1045.5
      altitude NaN
    5936.5 1061 5936.5 1063.5 5938 1078.5
    5939.5 1093.5 5941 1108 5937 1119
    5933 1130 5928.5 1129.5 5924.5 1140.5
    5920.5 1151.5 5909 1155 5917.5 1165
    5926 1175 5921.5 1171.5 5931 1182.5
    5940.5 1193.5 5951.5 1211 5953 1213.5
      smooth off
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final String asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('linepoint -subtype with original output', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': '2025-12-14-001-multiple_line_subtypes.th2',
        'length': 16,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap multiple_line_subtypes
  line wall:flowstone
    2453.75 130.25
    2453.53 132.37 2465.37 139.16 2467.28 140.67
    2469.53 142.45 2474.14 144.17 2477.56 147.45
    2479.19 149.01 2490.51 153.21 2495.08 157.43
      subtype blocks
    2497.43 159.62 2514.29 170.72 2517.54 172.57
    2521.01 174.55 2522.25 179.49 2531.62 182.14
    2536.21 183.43 2546.87 192.05 2554.51 192.60
    2561.82 193.14 2558.26 194.70 2565.80 191.48
      subtype presumed
    2567.18 190.89 2579.90 193.34 2583.76 193.34
    2593.01 193.34 2596.27 195.59 2604.14 195.59
    2605.40 195.59 2612.47 195.25 2615.00 195.25
  endline
endscrap
''',
      },
      {
        'file': '2025-12-15-001-multiple_subtypes_after_first_line_point.th2',
        'length': 16,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap multiple_line_subtypes
  line wall:presumed
    2453.75 130.25
    2453.53 132.37 2465.37 139.16 2467.28 140.67
    subtype debris
    2469.53 142.45 2474.14 144.17 2477.56 147.45
    2479.19 149.01 2490.51 153.21 2495.08 157.43
    2497.43 159.62 2514.29 170.72 2517.54 172.57
    2521.01 174.55 2522.25 179.49 2531.62 182.14
    2536.21 183.43 2546.87 192.05 2554.51 192.60
    2561.82 193.14 2558.26 194.70 2565.80 191.48
    2567.18 190.89 2579.90 193.34 2583.76 193.34
    2593.01 193.34 2596.27 195.59 2604.14 195.59
    2605.40 195.59 2612.47 195.25 2615.00 195.25
  endline
endscrap
''',
      },
      {
        'file': '2025-12-15-002-multiple_subtypes_before_first_line_point.th2',
        'length': 16,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap multiple_line_subtypes
  line wall:blocks
    2453.75 130.25
    2453.53 132.37 2465.37 139.16 2467.28 140.67
    subtype debris
    2469.53 142.45 2474.14 144.17 2477.56 147.45
    2479.19 149.01 2490.51 153.21 2495.08 157.43
    2497.43 159.62 2514.29 170.72 2517.54 172.57
    2521.01 174.55 2522.25 179.49 2531.62 182.14
    2536.21 183.43 2546.87 192.05 2554.51 192.60
    2561.82 193.14 2558.26 194.70 2565.80 191.48
    2567.18 190.89 2579.90 193.34 2583.76 193.34
    2593.01 193.34 2596.27 195.59 2604.14 195.59
    2605.40 195.59 2612.47 195.25 2615.00 195.25
  endline
endscrap
''',
      },
      {
        'file': '2025-12-15-003-multiple_subtypes_no_first_line_point.th2',
        'length': 16,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap multiple_line_subtypes
  line wall:flowstone
    2453.75 130.25
    2453.53 132.37 2465.37 139.16 2467.28 140.67
    subtype debris
    2469.53 142.45 2474.14 144.17 2477.56 147.45
    2479.19 149.01 2490.51 153.21 2495.08 157.43
    2497.43 159.62 2514.29 170.72 2517.54 172.57
    2521.01 174.55 2522.25 179.49 2531.62 182.14
    2536.21 183.43 2546.87 192.05 2554.51 192.60
    2561.82 193.14 2558.26 194.70 2565.80 191.48
    2567.18 190.89 2579.90 193.34 2583.76 193.34
    2593.01 193.34 2596.27 195.59 2604.14 195.59
    2605.40 195.59 2612.47 195.25 2615.00 195.25
  endline
endscrap
''',
      },
      {
        'file':
            'th_file_parser-03104-linepoint_with_subtype_option_as_first_line_data.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding utf-8
scrap test
  line water-flow:conjectural
    1758 -1030
    2147.74 -1120.48
endline
endscrap''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
        );
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

  group('linepoint -subtype manipulation', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': '2025-06-21-line_point_subtype.th2',
        'length': 25,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap 141c-TradePlan-s1 -projection plan
  line wall
    5903 1247
    5898.5 1232 5895.5 1221.5 5894.5 1206.5
    5893.5 1191.5 5894.5 1188 5890 1179
    5885.5 1170 5881.5 1169 5883 1161
    5884.5 1153 5885.5 1149 5892 1137
    5898.5 1125 5905.5 1131.5 5903.5 1117
    5901.5 1102.5 5895.5 1094 5900.5 1081.5
    5905.5 1069 5908.5 1058.5 5907 1052
    5905.5 1045.5 5905.5 1049.5 5904.5 1035
    5903.5 1020.5 5906 1017 5905.5 1008.5
      subtype unsurveyed
    5904.41 990.02 5893.5 964.5 5912.5 962
    5931.5 959.5 5928 959.5 5933 969.5
    5938 979.5 5939.5 994 5938 1007
      subtype bedrock
    5936.5 1020 5934.5 1030 5935.5 1045.5
      altitude NaN
    5936.5 1061 5936.5 1063.5 5938 1078.5
    5939.5 1093.5 5941 1108 5937 1119
    5933 1130 5928.5 1129.5 5924.5 1140.5
    5920.5 1151.5 5909 1155 5917.5 1165
    5926 1175 5921.5 1171.5 5931 1182.5
    5940.5 1193.5 5951.5 1211 5953 1213.5
      smooth off
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final String asFile = writer.serialize(file);
        expect(asFile, success['asFile']);

        final THLine line = file.getScraps().first.getLines(file).first;

        expect(MPCommandOptionAux.getSubtype(line), isNull);
        expect(line.subtypeLineSegmentMPIDsByLineSegmentIndex.length, 2);

        final THSubtypeCommandOption option1 = THSubtypeCommandOption(
          parentMPID: line.mpID,
          subtype: 'presumed',
          originalLineInTH2File: '',
        );

        line.addUpdateOption(option1);
        expect(MPCommandOptionAux.getSubtype(line), 'presumed');
        expect(line.subtypeLineSegmentMPIDsByLineSegmentIndex.length, 2);

        final THLineSegment lineSegment0 = line.getLineSegments(file).first;
        final THSubtypeCommandOption option2 = THSubtypeCommandOption(
          parentMPID: lineSegment0.mpID,
          subtype: 'sand',
          originalLineInTH2File: '',
        );

        lineSegment0.addUpdateOption(option2);
        expect(MPCommandOptionAux.getSubtype(line), 'sand');
        expect(MPCommandOptionAux.getSubtype(lineSegment0), isNull);
        expect(line.subtypeLineSegmentMPIDsByLineSegmentIndex.length, 2);

        final THLineSegment lineSegment4 = line.getLineSegments(file)[4];
        final THSubtypeCommandOption option3 = THSubtypeCommandOption(
          parentMPID: lineSegment4.mpID,
          subtype: 'blocks',
          originalLineInTH2File: '',
        );

        lineSegment4.addUpdateOption(option3);
        expect(MPCommandOptionAux.getSubtype(line), 'sand');
        expect(MPCommandOptionAux.getSubtype(lineSegment4), 'blocks');
        expect(line.subtypeLineSegmentMPIDsByLineSegmentIndex.length, 3);

        final entries = line.subtypeLineSegmentMPIDsByLineSegmentIndex.entries
            .toList();

        for (final entry in entries) {
          final THLineSegment lineSegment = file.lineSegmentByMPID(entry.value);

          lineSegment.removeOption(THCommandOptionType.subtype);
        }
        expect(MPCommandOptionAux.getSubtype(line), 'sand');
        expect(line.subtypeLineSegmentMPIDsByLineSegmentIndex.length, 0);
      });
    }
  });

  group('line -text', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03170-line_with_text_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line label -text "Buraco das Araras - Salão Seco"
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03173-line_with_text_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line label -text PERIGO
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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

  group('line -text failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-03171-line_with_invalid_text_option-failure.th2',
      'th_file_parser-03172-line_with_invalid_text_option-failure.th2',
      // 'th_file_parser-03174-line_with_text_option_invalid_line_type-failure.th2',
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

  group('line -visibility', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-03050-line_with_visibility_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line arrow -visibility on
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-03051-linepoint_with_visibility_option.th2',
        'length': 7,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line arrow -visibility on
    1758 -1030
    2147.74 -1120.48
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) = await parser.parse(
          (THTestAux.testPath(success['file'] as String)),
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
}
