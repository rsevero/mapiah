import 'package:test/test.dart';

import 'package:mapiah/src/elements/parts/th_double_part.dart';

void main() {
  group('THDoublePart from double', () {
    var successes = [
      {'value': 9322.91263, 'decimalPositions': 5, 'asString': '9322.91263'},
      {'value': 9322.91263, 'decimalPositions': 3, 'asString': '9322.913'},
      {'value': 9322.9115, 'decimalPositions': 3, 'asString': '9322.912'},
      {'value': 5.550, 'decimalPositions': 1, 'asString': '5.6'},
      {'value': 2.3456789, 'decimalPositions': 2, 'asString': '2.35'},
      {'value': 2.275, 'decimalPositions': 2, 'asString': '2.28'},
      {'value': 312.toDouble(), 'decimalPositions': 2, 'asString': '312'},
      {'value': 312.toDouble(), 'decimalPositions': 1, 'asString': '312'},
      {'value': 312.toDouble(), 'decimalPositions': 0, 'asString': '312'},
      {'value': 312.00, 'decimalPositions': 2, 'asString': '312'},
      {'value': 312.00, 'decimalPositions': 1, 'asString': '312'},
      {'value': 312.00, 'decimalPositions': 0, 'asString': '312'},
    ];

    var id = 1;
    for (var success in successes) {
      test(
        "$id - ${success['value']} - ${success['decimalPositions']} - ${success['asString']}",
        () {
          THDoublePart thDoublePart = THDoublePart(
            value: success['value'] as double,
            decimalPositions: success['decimalPositions'] as int,
          );
          expect(thDoublePart.value, success['value']);
          expect(thDoublePart.decimalPositions, success['decimalPositions']);
          expect(thDoublePart.toString(), success['asString']);
        },
      );
      id++;
    }
  });

  group('THDoublePart from string', () {
    var successes = [
      {'value': 9322.91263, 'decimalPositions': 5, 'asString': '9322.91263'},
      {'value': 9322.9115, 'decimalPositions': 4, 'asString': '9322.9115'},
      {'value': 5.550, 'decimalPositions': 2, 'asString': '5.55'},
      {'value': 2.3456789, 'decimalPositions': 7, 'asString': '2.3456789'},
      {'value': 2.275, 'decimalPositions': 3, 'asString': '2.275'},
      {'value': 312, 'decimalPositions': 0, 'asString': '312'},
      {'value': 312.0, 'decimalPositions': 0, 'asString': '312'},
      {'value': 312.00, 'decimalPositions': 0, 'asString': '312'},
    ];
    var id = 1;
    for (var success in successes) {
      test(
        "$id - ${success['value']} - ${success['decimalPositions']} - ${success['asString']}",
        () {
          var aTHDoublePart = THDoublePart.fromString(
            valueString: success['asString'] as String,
          );
          expect(aTHDoublePart.value, success['value']);
          expect(aTHDoublePart.decimalPositions, success['decimalPositions']);
          expect(aTHDoublePart.toString(), success['asString']);
        },
      );
      id++;
    }
  });
}
