import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_file_aux/th_file_parser.dart';
import 'package:mapiah/src/th_file_aux/th_file_writer.dart';
import 'package:test/test.dart';

void main() {
  group('encoding', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-00011-encoding_with_trailing_space.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFile': '''encoding UTF-8
''',
      },
      {
        'file': 'th_file_parser-00012-encoding_with_trailing_comment.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFile': '''encoding UTF-8 # end of line comment
''',
      },
      {
        'file': 'th_file_parser-00013-iso8859-1_encoding.th2',
        'length': 2,
        'encoding': 'ISO8859-1',
        'asFile': '''encoding ISO8859-1
# ISO8859-1 comment: àáâãäåç
''',
      },
      {
        'file': 'th_file_parser-00014-iso8859-2_encoding.th2',
        'length': 2,
        'encoding': 'ISO8859-2',
        'asFile': '''encoding ISO8859-2
# ISO8859-2 comment: ŕáâăäĺç
''',
      },
      {
        'file': 'th_file_parser-00015-iso8859-15_encoding.th2',
        'length': 2,
        'encoding': 'ISO8859-15',
        'asFile': '''encoding ISO8859-15
# ISO8859-15 comment: àáâãäåç€
''',
      },
      {
        'file': 'th_file_parser-00019-encoding_only.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFile': '''encoding UTF-8
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final file = await parser.parse((success['file'] as String));
        // final aTHFile =
        //     await parser.parse(success, startParser: grammar.start());
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('scrap', () {
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
        'file': 'th_file_parser-00060-scrap_without_endscrap-parse_failure.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap poco_surubim_SCP01 -scale [-164.0 -2396.0 3308.0 -2396.0 0.0 0.0 88.1888 \
  0.0 m]
''',
      },
      {
        'file': 'th_file_parser-00064-scrap_and_endscrap_simplier_scale.th2',
        'length': 2,
        'encoding': 'UTF-8',
        'asFile': '''encoding UTF-8
scrap poco_surubim_SCP01 -scale [-164.0 -2396.0 m]
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
        final file = await parser.parse((success['file'] as String));
        // final aTHFile =
        //     await parser.parse(success, startParser: grammar.start());
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('projection', () {
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
    ];

    for (var success in successes) {
      test(success, () async {
        final file = await parser.parse((success['file'] as String));
        // final file = await parser.parse((success['file'] as String),
        //     startParser: grammar.start());
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });
}
