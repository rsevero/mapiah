import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:test/test.dart';
import 'th_test_aux.dart';

final MPLocator mpLocator = MPLocator();
void main() {
  group('line json', () {
    mpLocator.mpGeneralController.reset();
    final parser = THFileParser();

    const successes = [
      {
        'file': 'th_file_parser-00080-line_only.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
line wall
endline
endscrap
''',
        'asJson':
            r'''{"elementType":"line","mpID":3,"parentMPID":2,"sameLineComment":null,"originalLineInTH2File":"\tline wall\n","lineType":"wall","childrenMPID":[4],"lineSegmentMPIDs":[],"optionsMap":{},"attrOptionsMap":{}}''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final (file, isSuccessful, _) =
            await parser.parse(THTestAux.testPath(success['file'] as String));
        expect(isSuccessful, true);

        THElement expected = file.elementByMPID(3);

        Map<String, dynamic> asMap = expected.toMap();
        THLine fromMap = THLine.fromMap(asMap);
        expect(expected, fromMap);
        expect(identical(expected, fromMap), false);

        String asJson = expected.toJson();
        expect(asJson, success['asJson']);
        THElement fromJson = THLine.fromJson(asJson);
        expect(expected == fromJson, true);
        expect(identical(expected, fromJson), false);
      });
    }
  });
}
