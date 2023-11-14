import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_file_aux/th_file_parser.dart';
import 'package:mapiah/src/th_file_aux/th_file_writer.dart';
import 'package:mapiah/src/th_file_aux/th_grammar.dart';
import 'package:petitparser/debug.dart';
import 'package:test/test.dart';

void main() {
  group('area', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

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
    3592.0 208.0
    3539.45 249.03 3447.39 245.1 3392.0 208.0
    3233.22 101.65 3066.45 -131.93 3204.0 -332.0
    3266.87 -423.45 3365.54 -513.28 3476.0 -524.0
    3929.86 -568.03 3743.42 89.77 3592.0 208.0
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

  group('area failures', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const failures = [
      'th_file_parser-00093-area_with_invalid_type-failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(failure);
        expect(isSuccessful, false);
      });
    }
  });
}
