import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:test/test.dart';
import 'th_test_aux.dart';

void main() {
  group('line', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-00080-line_only.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line wall
  endline
endscrap
''',
      },
      {
        'file': 'th_file_parser-00081-line_with_last_line_with_spaces_only.th2',
        'length': 6,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  line wall
  endline
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

  group('line failures', () {
    final parser = THFileParser();

    const failures = [
      'th_file_parser-00082-line_with_invalid_type-failure.th2',
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

  // group('linepoint -altitude failures', () {
  //   final parser = THFileParser();

  //   const failures = [
  //     'th_file_parser-03132-linepoint_with_altitude_option_with_invalid_line_type-failure.th2',
  //   ];

  //   for (var failure in failures) {
  //     test(failure, () async {
  //       final (_, isSuccessful, error) =
  //           await parser.parse(THTestAux.testPath(failure));
  //       expect(isSuccessful, false);
  //     });
  //   }
  // });

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
      // 'th_file_parser-02394-line_with_anchors_option_invalid_line_type-failure.th2',
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

  group('line -height failures', () {
    final parser = THFileParser();

    const failures = [
      // 'th_file_parser-03182-line_with_height_option_on_invalid_line_type-failure.th2',
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
  line water-flow
    1758 -1030
      subtype conjectural
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

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('linepoint -subtype failures', () {
    final parser = THFileParser();

    const failures = [
      // 'th_file_parser-03102-linepoint_with_subtype_option_for_unsupported_type-failure.th2',
      // 'th_file_parser-03101-line_with_subtype_option_unsupported_type-failure.th2',
      'th_file_parser-03104-linepoint_with_subtype_option_as_first_line_data.th2',
      // 'th_file_parser-03103-line_with_subtype_option_unsupported_type-failure.th2',
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
