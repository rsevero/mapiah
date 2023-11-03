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

//   group('line -clip', () {
//     final parser = THFileParser();
//     // final grammar = THGrammar();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-02230-point_with_clip_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 122.0031 321.9712 mud -clip off
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse((success['file'] as String));
//         // final (file, isSuccessful, errors) = await parser.parse((success['file'] as String),
//         //     startParser: grammar.start());
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('line -clip failures', () {
//     final parser = THFileParser();
//     // final grammar = THGrammar();
//     final writer = THFileWriter();

//     const failures = [
//       'th_file_parser-02231-point_with_invalid_clip_option_failure.th2',
//       'th_file_parser-02232-point_with_clip_option_on_invalid_point_type_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) = await parser.parse(failure);
//         expect(isSuccessful, false);
//       });
//     }
//   });
// }
}
