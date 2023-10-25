// import 'package:petitparser/debug.dart';
import 'package:test/test.dart';

import 'package:mapiah/src/th_parts/th_double_part.dart';

void main() {
  group('THDoublePart', () {
    var successes = [
      {'value': 9322.91263, 'decimalPositions': 5, 'result': '9322.91263'},
      {'value': 9322.91263, 'decimalPositions': 3, 'result': '9322.913'},
      {'value': 5.550, 'decimalPositions': 1, 'result': '5.6'},
      {'value': 2.3456789, 'decimalPositions': 2, 'result': '2.35'},
      {'value': 2.275, 'decimalPositions': 2, 'result': '2.28'},
      {'value': 312.toDouble(), 'decimalPositions': 2, 'result': '312.00'},
      {'value': 312.toDouble(), 'decimalPositions': 1, 'result': '312.0'},
      {'value': 312.toDouble(), 'decimalPositions': 0, 'result': '312'},
      {'value': 312.00, 'decimalPositions': 2, 'result': '312.00'},
      {'value': 312.00, 'decimalPositions': 1, 'result': '312.0'},
      {'value': 312.00, 'decimalPositions': 0, 'result': '312'},
    ];

    var id = 1;
    for (var success in successes) {
      test(
          "$id - ${success['value']} - ${success['decimalPositions']} - ${success['result']}",
          () {
        var aTHDoublePart =
            THDoublePart(success['value'], success['decimalPositions']);
        expect(aTHDoublePart.value, success['value']);
        expect(aTHDoublePart.decimalPositions, success['decimalPositions']);
        expect(aTHDoublePart.toString(), success['result']);
      });
      id++;
    }
  });
}
