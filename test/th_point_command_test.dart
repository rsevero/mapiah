import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_file_aux/th_file_parser.dart';
import 'package:mapiah/src/th_file_aux/th_file_writer.dart';
import 'package:mapiah/src/th_file_aux/th_grammar.dart';
import 'package:petitparser/debug.dart';
import 'package:test/test.dart';

void main() {
  group('point', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-00070-point_only.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  point 2596.0 -468.0 debris
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

  group('point failures', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const failures = [
      'th_file_parser-00074-point_invalid_type_failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(failure);
        expect(isSuccessful, false);
      });
    }
  });

  group('point -align', () {
    final parser = THFileParser();
    final grammar = THGrammar();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-02200-point_with_align_main_choice_option.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  point 122.0031 321.9712 ex-voto -align top-right
endscrap
''',
      },
      {
        'file':
            'th_file_parser-02201-point_with_align_alternate_choice_option.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  point 122.0031 321.9712 ex-voto -align center
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

  group('point -orientation', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-00126-point_with_orientation_option.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  point 122.0031 321.9712 ex-voto -orientation 173.23
endscrap
''',
      },
      {
        'file':
            'th_file_parser-00127-point_with_alternative_id_for_orientation_option.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  point 4122 9321 electric-light -orientation 297.0
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

  group('point -orientation failures', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const failures = [
      'th_file_parser-00128-point_with_invalid_orientation_option_value_failure.th2',
      'th_file_parser-00129-point_with_orientation_option_with_unit_failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(failure);
        expect(isSuccessful, false);
      });
    }
  });

  group('point -scale', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-00130-point_with_preset_scale_value.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  point -949.68 -354.61 altitude -scale xs
endscrap
''',
      },
      {
        'file': 'th_file_parser-00131-point_with_numeric_scale_value.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  point 717.49 552.12 date -scale 2.84
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

  group('point -scale failures', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const failures = [
      'th_file_parser-00132-point_with_invalid_scale_value_failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(failure);
        expect(isSuccessful, false);
      });
    }
  });

  group('point -subtype', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-00122-point_with_inline_subtype.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  point 43 336 water-flow -subtype paleo
endscrap
''',
      },
      {
        'file': 'th_file_parser-00123-point_with_subtype_option.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  point 43 336 water-flow -subtype paleo
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

  group('point -subtype failures', () {
    final parser = THFileParser();
    // final grammar = THGrammar();
    final writer = THFileWriter();

    const failures = [
      'th_file_parser-00124-point_with_invalid_subtype_for_type_failure.th2',
      'th_file_parser-00125-point_with_subtype_for_type_with_no_support_failure.th2',
      'th_file_parser-00126-point_outside_scrap_failure.th2',
      'th_file_parser-00127-point_duplicate_index_with_type_as_option_failure.th2',
    ];

    for (var failure in failures) {
      test(failure, () async {
        final (_, isSuccessful, error) = await parser.parse(failure);
        expect(isSuccessful, false);
      });
    }
  });
}
