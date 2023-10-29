import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_file_aux/th_file_parser.dart';
import 'package:mapiah/src/th_file_aux/th_file_writer.dart';
import 'package:mapiah/src/th_file_aux/th_grammar.dart';
import 'package:test/test.dart';

void main() {
  group('multilinecomment', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    const successes = [
      {
        'file': 'th_file_parser-00110-comment_block.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': '''encoding UTF-8
comment
The scrap below is really complex.
   Take care!!
endcomment
''',
      },
      {
        'file': 'th_file_parser-00111-comment_block_complex.th2',
        'length': 14,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
comment
The scrap below is really complex.
Take care!!
endcomment
scrap poco_surubim_SCP01 -scale [ -164.0 -2396.0 3308.0 -2396.0 0.0 0.0 88.1888 \
    0.0 m ]
  comment

Another comment block.

But this one is inside a scrap!

  endcomment
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) =
            await parser.parse((success['file'] as String));
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
