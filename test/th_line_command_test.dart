import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_file_aux/th_file_parser.dart';
import 'package:mapiah/src/th_file_aux/th_file_writer.dart';
import 'package:mapiah/src/th_file_aux/th_grammar.dart';
import 'package:petitparser/debug.dart';
import 'package:test/test.dart';

void main() {
  group('line', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
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
        'asFile': r'''encoding UTF-8
scrap scrap1 -scale [ 0 0 1600 0 0.0 0.0 40.64 0.0 m ]
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
        'asFile': r'''encoding UTF-8



scrap scrap1 -scale [ 0 0 1600 0 0.0 0.0 40.64 0.0 m ]

  line wall
    355.0 1065.0
    291.0 499.0
    1124.0 503.0
    1139.0 1079.0
    355.0 1065.0
  endline

  point 1050.0 900.0 station -name a2

  point 450.0 900.0 station -name a1

  line chimney
    450.0 900.0
    450.0 600.0
    450.0 600.0 589.72 521.11 650.0 600.0
    731.0 706.0 649.0 898.0 649.0 898.0
    649.0 898.0 751.0 930.0 850.0 900.0
    774.0 854.0 850.0 600.0 850.0 600.0
    1050.0 600.0
    1050.0 900.0
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
    355.0 1065.0 # Comment on data line
    450.0 600.0 589.72 521.11 650.0 600.0 # Comment on another data line
    291.0 499.0
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
    355.0 1065.0 # Comment on data line
    450.0 600.0 589.72 521.11 650.0 600.0 # Comment that Mapiah will move to the data line above
    291.0 499.0
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
    355.0 1065.0 # Comment on data line
    450.0 600.0 589.72 521.11 650.0 600.0 # Comment on another data line | Comment that Mapiah will join with the comment on the line above
    291.0 499.0
  endline
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

  group('line failures', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const failures = [
      'th_file_parser-00082-line_with_invalid_type-failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(failure);
        expect(isSuccessful, false);
      });
    }
  });

  group('line -anchors', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
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

  group('line -anchors failures', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const failures = [
      'th_file_parser-02394-line_with_anchors_option_invalid_line_type-failure.th2',
      'th_file_parser-02395-line_with_invalid_anchors_option-failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(failure);
        expect(isSuccessful, false);
      });
    }
  });

  group('linepoint -anchors', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
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

  group('linepoint -anchors failures', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const failures = [
      'th_file_parser-02391-linepoint_with_anchors_option_invalid_line_type-failure.th2',
      'th_file_parser-02392-linepoint_with_invalid_anchors_option-failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(failure);
        expect(isSuccessful, false);
      });
    }
  });

  group('line -border', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
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

  group('line -border failures', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const failures = [
      'th_file_parser-03004-line_with_border_option_invalid_line_type-failure.th2',
      'th_file_parser-03005-line_with_invalid_border_option-failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(failure);
        expect(isSuccessful, false);
      });
    }
  });

  group('linepoint -border', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
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

  group('linepoint -border failures', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const failures = [
      'th_file_parser-03001-linepoint_with_border_option_invalid_line_type-failure.th2',
      'th_file_parser-03002-linepoint_with_invalid_border_option-failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(failure);
        expect(isSuccessful, false);
      });
    }
  });

  group('line -clip', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
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

  group('line -clip failures', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const failures = [
      'th_file_parser-03021-line_with_invalid_clip_option-failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(failure);
        expect(isSuccessful, false);
      });
    }
  });

  group('linepoint -clip', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
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

  group('linepoint -clip failures', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const failures = [
      'th_file_parser-03026-linepoint_with_invalid_clip_option-failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(failure);
        expect(isSuccessful, false);
      });
    }
  });

  group('line -close', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
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

  group('line -close failures', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const failures = [
      'th_file_parser-02381-line_with_invalid_close_option-failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(failure);
        expect(isSuccessful, false);
      });
    }
  });

  group('linepoint -close', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
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

  group('line -head', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
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

  group('line -reverse', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
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

  group('linepoint -close failures', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const failures = [
      'th_file_parser-03011-linepoint_with_invalid_close_option-failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(failure);
        expect(isSuccessful, false);
      });
    }
  });
}
