import 'package:petitparser/petitparser.dart';
import 'package:petitparser/debug.dart';
import 'package:th_parser/src/th_grammar.dart';
import 'package:test/test.dart';

void main() {
  group('encoding', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.encodingCommand()).end();

    const successes = {
      'encoding UTF-8': ['encoding', 'UTF-8'],
      'encoding  UTF-8    ': ['encoding', 'UTF-8'],
      ' encoding UTF-8 ': ['encoding', 'UTF-8'],
    };

    for (var success in successes.keys) {
      test(success, () {
        final result = parser.parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, successes[success]);
      });
    }

    const failures = [
      '-point',
      '_secret*Keywork49/',
      '/st+range39',
      '099.92',
      'cmy,k-rgb',
      "OSGB'",
    ];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });
}
