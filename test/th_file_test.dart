import 'package:mapiah/src/th_file_aux/th_file_writer.dart';
// import 'package:petitparser/debug.dart';
import 'package:test/test.dart';

import 'package:mapiah/src/th_file_aux/th_file_parser.dart';
import 'package:mapiah/src/th_elements/th_element.dart';

void main() {
  group('initial', () {
    final file = THFile();

    test("THFile", () {
      expect(file.mapiahID, -1);
      expect(file.elements.length, 0);
    });
  });

  group('line breaks', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    var successes = [
      {
        'file': 'th_file_parser-00000-line_breaks.th2',
        'countElements': 3,
        'asFile': """encoding UTF-8
scrap poco_surubim_SCP01
endscrap
""",
      },
      {
        'file': 'th_file_parser-00001-no_linebreak_at_file_end.th2',
        'countElements': 3,
        'asFile': """encoding UTF-8
scrap poco_surubim_SCP01
endscrap
""",
      },
      {
        'file': 'th_file_parser-00002-backslash_ending.th2',
        'countElements': 3,
        'asFile': """encoding UTF-8
scrap poco_surubim_SCP01
endscrap
""",
      },
    ];

    for (var success in successes) {
      test(success['file'], () async {
        final (file, isSuccessful, errors) =
            await parser.parse(success['file'] as String);
        // final (file, isSuccessful, errors) = await parser.parse(success['file'] as String,
        //     startParser: myGrammar.start());
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.countElements(), success['countElements']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });
}
