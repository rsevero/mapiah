import 'package:petitparser/petitparser.dart';
import 'package:petitparser/debug.dart';
import 'package:mapiah/src/th_file_aux/th_grammar.dart';

import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:test/test.dart';

import 'package:mapiah/src/th_file_aux/th_file_parser.dart';

void main() {
  group('encoding', () {
    final parser = THFileParser();
    final grammar = THGrammar();

    const successes = {
      'th2parser-0011-encoding_with_trailing_space.th2': {
        'length': 0,
        'encoding': 'UTF-8',
        'results': [],
      },
      'th2parser-0012-encoding_with_trailing_comment.th2': {
        'length': 1,
        'encoding': 'UTF-8',
        'results': [
          {
            'index': 0,
            'type': 'samelinecomment',
            'asString': '# end of line comment'
          },
        ],
      },
      'th2parser-0013-iso8859-1_encoding.th2': {
        'length': 1,
        'encoding': 'ISO8859-1',
        'results': [
          {
            'index': 0,
            'type': 'fulllinecomment',
            'asString': '# ISO8859-1 comment: àáâãäåç'
          }
        ],
      },
      'th2parser-0014-iso8859-2_encoding.th2': {
        'length': 1,
        'encoding': 'ISO8859-2',
        'results': [
          {
            'index': 0,
            'type': 'fulllinecomment',
            'asString': '# ISO8859-2 comment: ŕáâăäĺç'
          }
        ],
      },
      'th2parser-0015-iso8859-15_encoding.th2': {
        'length': 1,
        'encoding': 'ISO8859-15',
        'results': [
          {
            'index': 0,
            'type': 'fulllinecomment',
            'asString': '# ISO8859-15 comment: àáâãäåç€'
          }
        ],
      },
      'th2parser-0019-encoding_only.th2': {
        'length': 0,
        'encoding': 'UTF-8',
        'results': [],
      },
    };

    var id = 1;
    for (var success in successes.keys) {
      test("$id - $success", () async {
        // final aTHFile = await parser.parse(success);
        final aTHFile =
            await parser.parse(success, startParser: grammar.start());
        final expectations = successes[success]!;
        // print(expectations);
        // print(expectations.runtimeType);
        // print(expectations['results'].runtimeType);
        expect(aTHFile, isA<THFile>());
        expect(aTHFile.encoding, expectations['encoding']);
        expect(aTHFile.elements.length, expectations['length']);
        for (var result in (expectations['results'] as List)) {
          expect(
              aTHFile.elementByIndex(result['index'])!.type(), result['type']);
          expect(aTHFile.elementByIndex(result['index'])!.toString(),
              result['asString']);
        }
      });
      id++;
    }
  });

  group('scrap', () {
    final parser = THFileParser();
    final grammar = THGrammar();

    const successes = {
      'th2parser-0060-scrap_without_endscrap-parse_failure.th2': {
        'length': 1,
        'encoding': 'UTF-8',
        'results': [
          {
            'index': 0,
            'type': 'scrap',
            'asString':
                'scrap poco_surubim_SCP01 -scale [-164.0 -2396.0 3308.0 -2396.0 0.0 0.0 88.1888 0.0 m]'
          },
        ],
      },
      'th2parser-0012-encoding_with_trailing_comment.th2': {
        'length': 1,
        'encoding': 'UTF-8',
        'results': [
          {
            'index': 0,
            'type': 'samelinecomment',
            'asString': '# end of line comment'
          },
        ],
      },
    };

    var id = 1;
    for (var success in successes.keys) {
      test("$id - $success", () async {
        final aTHFile = await parser.parse(success);
        // await parser.parse(success, startParser: grammar.scrapCommand());
        final expectations = successes[success]!;
        if (expectations != null) {
          // print(expectations);
          // print(expectations.runtimeType);
          // print(expectations['results'].runtimeType);
          expect(aTHFile, isA<THFile>());
          expect(aTHFile.encoding, expectations['encoding']);
          expect(aTHFile.elements.length, expectations['length']);
          for (var result in (expectations['results'] as List)) {
            expect(aTHFile.elementByIndex(result['index'])!.type(),
                result['type']);
            expect(aTHFile.elementByIndex(result['index'])!.toString(),
                result['asString']);
          }
        }
      });
      id++;
    }
  });
}
