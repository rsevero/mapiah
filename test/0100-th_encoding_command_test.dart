import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/th_file_read_write/th_file_writer.dart';
// import 'package:mapiah/src/th_file_read_write/th_grammar.dart';
import 'package:test/test.dart';

import 'th_test_aux.dart';

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
        final (file, isSuccessful, _) =
            await parser.parse(THTestAux.testPath(success['file'] as String));
        // final (file, isSuccessful, errors) =
        //     await parser.parse(success, startParser: grammar.start());
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
