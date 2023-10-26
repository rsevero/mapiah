import 'package:petitparser/petitparser.dart';
// import 'package:petitparser/debug.dart';
import 'package:test/test.dart';

import 'package:mapiah/src/th_file_aux/th_file_parser.dart';
import 'package:mapiah/src/th_elements/th_element.dart';

void main() {
  group('initial', () {
    var aTHFile = THFile();

    test("THFile", () {
      expect(aTHFile.index, -1);
      expect(aTHFile.elements.length, 0);
    });
  });

  group('comment', () {
    final thParser = THFileParser();

    // final
    //   test("THFile", () async {
    //     var aTHFile = await thParser.parse(aFilePath);
    //     expect(aTHFile.id, -1);
    //     expect(aTHFile.elements.length, 0);
    //   });
  });
}
