// import 'package:petitparser/petitparser.dart';
// import 'package:petitparser/debug.dart';
import 'package:test/test.dart';

import 'th_test_aux.dart';

import 'package:mapiah/src/th_elements/th_element.dart';

void main() {
  group('comment', () {
    var aTHFile = THFile();

    test("THFile", () {
      expect(aTHFile.id, -1);
      expect(aTHFile.elements.length, 0);
    });
  });
}
