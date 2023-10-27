import 'package:mapiah/src/th_file_aux/th_grammar.dart';
import 'package:petitparser/petitparser.dart';
// import 'package:petitparser/debug.dart';
import 'package:test/test.dart';

import 'package:mapiah/src/th_file_aux/th_file_parser.dart';
import 'package:mapiah/src/th_elements/th_element.dart';

void main() {
  group('initial', () {
    var myTHFile = THFile();

    test("THFile", () {
      expect(myTHFile.index, -1);
      expect(myTHFile.elements.length, 0);
    });
  });

  group('line breaks', () {
    var myTHParser = THFileParser();
    var myGrammar = THGrammar();

    var successes = [
      {
        'file': 'th2parser-0000-line_breaks.th2',
        'countElements': 1,
        'results': [
          {
            'index': 0,
            'asString': 'scrap poco_surubim_SCP01',
          }
        ],
      },
      {
        'file': 'th2parser-0001-no_linebreak_at_file_end.th2',
        'countElements': 1,
        'results': [
          {
            'index': 0,
            'asString': 'scrap poco_surubim_SCP01',
          }
        ],
      },
      {
        'file': 'th2parser-0002-backslashending.th2',
        'countElements': 1,
        'results': [
          {
            'index': 0,
            'asString': 'scrap poco_surubim_SCP01',
          }
        ],
      }
    ];

    for (var success in successes) {
      test(success['file'], () async {
        final myTHFile = await myTHParser.parse(success['file'] as String);
        // final myTHFile = await myTHParser.parse(success['file'] as String,
        //     startParser: myGrammar.start());

        expect(myTHFile.countElements(), success['countElements']);

        for (var result in (success['results'] as List)) {
          expect(myTHFile.elementByIndex(result['index']).toString(),
              result['asString']);
        }
      });
    }
  });
}
