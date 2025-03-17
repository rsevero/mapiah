import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:test/test.dart';
import 'th_test_aux.dart';

final MPLocator mpLocator = MPLocator();
void main() {
  group('point json', () {
    final parser = THFileParser();

    const successes = [
      {
        'file': 'th_file_parser-00070-point_only.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  point 296 468 debris
endscrap
''',
        'asJson':
            r'''{"elementType":"point","mpID":3,"parentMPID":2,"sameLineComment":null,"originalLineInTH2File":"point 296.0 468.0 debris","position":{"partType":"position","coordinates":{"dx":296.0,"dy":468.0},"decimalPositions":1},"pointType":"debris","optionsMap":{}}''',
      },
      {
        'file': 'th_file_parser-00075-point_only_with_extra_precision.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap test
  point 296.48195403809 468.93754612064 debris
endscrap
''',
        'asJson':
            r'''{"elementType":"point","mpID":3,"parentMPID":2,"sameLineComment":null,"originalLineInTH2File":"point 296.48195403809 468.93754612064 debris","position":{"partType":"position","coordinates":{"dx":296.48195403809,"dy":468.93754612064},"decimalPositions":11},"pointType":"debris","optionsMap":{}}''',
      },
      // th_file_parser-00195-passage_height_point_with_value_option_with_unit.th2
    ];

    for (var success in successes) {
      test(success, () async {
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) =
            await parser.parse(THTestAux.testPath(success['file'] as String));
        expect(isSuccessful, true);

        THElement expected = file.elementByMPID(3);

        Map<String, dynamic> asMap = expected.toMap();
        THPoint fromMap = THPoint.fromMap(asMap);
        expect(expected, fromMap);
        expect(identical(expected, fromMap), false);

        String asJson = expected.toJson();
        expect(asJson, success['asJson']);
        THElement fromJson = THPoint.fromJson(asJson);
        expect(expected == fromJson, true);
        expect(identical(expected, fromJson), false);
      });
    }
  });

  group('point copyWith', () {
    final parser = THFileParser();

    const successes = [
      {
        'file':
            'th_file_parser-00195-passage_height_point_with_value_option_with_unit.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
scrap U20-U23 -projection plan -scale [ -128 -2644 3414 -2644 0 0 89.96 0 meter \
    ]
  point 777 -1224 passage-height -value [ +7 feet ]
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) =
            await parser.parse(THTestAux.testPath(success['file'] as String));
        expect(isSuccessful, true);

        THElement expected = file.elementByMPID(3);

        Map<String, dynamic> asMap = expected.toMap();
        THPoint fromMap = THPoint.fromMap(asMap);
        expect(expected, fromMap);
        expect(identical(expected, fromMap), false);

        THElement fromCopyWith = expected.copyWith();
        expect(expected == fromCopyWith, true);
        expect(identical(expected, fromCopyWith), false);
      });
    }
  });
}
