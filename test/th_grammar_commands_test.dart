import 'package:petitparser/petitparser.dart';
// import 'package:petitparser/debug.dart';
import 'package:test/test.dart';

import 'package:mapiah/src/th_parser/th_grammar.dart';
import 'th_test_aux.dart';

void main() {
  group('encoding', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.encodingCommand()).end();

    const successes = {
      'th2parser-0011-encoding_with_trailing_space.th2': [
        'encoding',
        'UTF-8',
        null,
      ],
      'th2parser-0012-encoding_with_trailing_comment.th2': [
        'encoding',
        'UTF-8',
        '# end of line comment',
      ],
      'th2parser-0013-iso8859-1_encoding.th2': [
        'encoding',
        'ISO8859-1',
        '# ISO8859-1 comment: àáâãäåç'
      ],
      'th2parser-0014-iso8859-2_encoding.th2': [
        'encoding',
        'ISO8859-2',
        '# ISO8859-2 comment: ŕáâăäĺç'
      ],
      'th2parser-0015-iso8859-15_encoding.th2': [
        'encoding',
        'ISO8859-15',
        '# ISO8859-15 comment: àáâãäåç€'
      ],
      'th2parser-0019-encoding_only.th2': [
        'encoding',
        'UTF-8',
        null,
      ],
    };

    for (var success in successes.keys) {
      test(success, () async {
        var content = await readTestFile(success);
        // trace(parser).parse(content);
        final result = parser.parse(content);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, successes[success]);
      });
    }

    const failures = [
      // '-point',
      // '_secret*Keywork49/',
      // '/st+range39',
      // '099.92',
      // 'cmy,k-rgb',
      // "OSGB'",
    ];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });
}
