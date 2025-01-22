import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/stores/general_store.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:test/test.dart';

import 'th_test_aux.dart';

final GetIt getIt = GetIt.instance;
void main() {
  getIt.registerSingleton<GeneralStore>(GeneralStore());
  group('point json', () {
    final parser = THFileParser();
    final deepEquality = DeepCollectionEquality();

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
            r'''{"elementType":"point","mapiahID":3,"parentMapiahID":2,"sameLineComment":null,"position":{"partType":"position","coordinates":{"dx":"296.0000000","dy":"468.0000000"},"decimalPositions":1},"pointType":"debris","optionsMap":{}}''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        getIt<GeneralStore>().reset();
        final (file, isSuccessful, _) =
            await parser.parse(THTestAux.testPath(success['file'] as String));
        expect(isSuccessful, true);

        THElement expected = file.elementByMapiahID(3);

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

//   group('point failures', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-00074-point_invalid_type_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -align', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-02200-point_with_align_main_choice_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 122.0031 321.9712 ex-voto -align top-right
// endscrap
// ''',
//       },
//       {
//         'file':
//             'th_file_parser-02201-point_with_align_alternate_choice_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 122.0031 321.9712 ex-voto -align center
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -clip', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-02230-point_with_clip_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 122.0031 321.9712 mud -clip off
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -clip failures', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-02231-point_with_invalid_clip_option_failure.th2',
//       // 'th_file_parser-02232-point_with_clip_option_on_invalid_point_type_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -context', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-00140-point_with_context_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -104.04 75 date -context line fault
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -context failures', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-00141-point_with_invalid_context_type_failure.th2',
//       'th_file_parser-00142-point_with_incomplete_context_option_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -dist', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-00150-point_with_dist_option.th2',
//         'length': 6,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -4882 -2163 extra -dist 18
// endscrap
// ''',
//       },
//       {
//         'file': 'th_file_parser-00151-point_with_dist_option_with_unit.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -4381 -253 extra -dist [ 2450 centimeter ]
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -dist failures', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-00152-point_with_invalid_dist_option_unsupported_unit_failure.th2',
//       'th_file_parser-00153-point_with_invalid_dist_option_no_number_failure.th2',
//       // 'th_file_parser-00154-point_with_invalid_type_for_dist_option_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -explored', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-02280-point_with_explored_option.th2',
//         'length': 6,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -4882 -2163 continuation -explored 18
// endscrap
// ''',
//       },
//       {
//         'file': 'th_file_parser-02281-point_with_explored_option_with_unit.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -4381 -253 continuation -explored [ 2450 centimeter ]
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -explored failures', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-02282-point_with_invalid_explored_option_unsupported_unit_failure.th2',
//       'th_file_parser-02283-point_with_invalid_explored_option_no_number_failure.th2',
//       // 'th_file_parser-02284-point_with_invalid_type_for_explored_option_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -extend', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file':
//             'th_file_parser-00160-point_with_extend_option_without_previous_station.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -2675 2206 station -extend
// endscrap
// ''',
//       },
//       {
//         'file':
//             'th_file_parser-00161-point_with_extend_option_with_previous_station.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -3218 -2379 station -extend previous a12
// endscrap
// ''',
//       },
//       {
//         'file':
//             'th_file_parser-00162-point_with_extend_option_with_alternate_previous_station.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -4747 -2577 station -extend previous c33
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -extend failures', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-00163-point_with_extend_option_with_alternate_previous_missing_station_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -from', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-02240-point_with_from_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -4882 -2163 extra -from a18
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -from failures', () {
//     final parser = THFileParser();

//     const failures = [
//       // 'th_file_parser-02241-point_with_from_option_on_invalid_point_type_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -id', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-00072-point_with_option_and_id.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 782 -1740 station:fixed -id A2
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final pointStation = file.elementByTHID('A2');
//         expect(pointStation, isA<THPoint>());
//         expect((pointStation as THPoint).plaType, 'station');

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -id failures', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-02250-point_with_incomplete_option_id_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -name', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-02263-point_with_only_option_name.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 782 -1740 station -name A2@final_de_semana
// endscrap
// ''',
//       },
//       {
//         'file': 'th_file_parser-02260-point_with_option_name.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 782 -1740 station:fixed -name A2@final_de_semana -id A2
// endscrap
// ''',
//       },
//       {
//         'file': 'th_file_parser-02264-point_with_quoted_option_name.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 782 -1740 station:fixed -name A2@final_de_semana -id A2
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -name failures', () {
//     final parser = THFileParser();

//     const failures = [
//       // 'th_file_parser-02261-point_with_option_name_with_unsupported_point_type_failure.th2',
//       'th_file_parser-02262-point_with_option_name_without_reference_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -orientation', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-00126-point_with_orientation_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 122.0031 321.9712 ex-voto -orientation 173.23
// endscrap
// ''',
//       },
//       {
//         'file':
//             'th_file_parser-00127-point_with_alternative_id_for_orientation_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 4122 9321 electric-light -orientation 297
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -orientation failures', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-00128-point_with_invalid_orientation_option_value_failure.th2',
//       'th_file_parser-00129-point_with_orientation_option_with_unit_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -place', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-02210-point_with_place_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 122.0031 321.9712 vegetable-debris -place bottom
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -place failures', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-02211-point_with_invalid_place_option_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -scale', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-00130-point_with_preset_scale_value.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -949.68 -354.61 altitude -scale xs
// endscrap
// ''',
//       },
//       {
//         'file': 'th_file_parser-00131-point_with_numeric_scale_value.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 717.49 552.12 date -scale 2.84
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -scale failures', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-00132-point_with_invalid_scale_value_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -scrap', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-02270-point_with_option_section.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 782 -1740 section -scrap end_tunnel
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -scrap failures', () {
//     final parser = THFileParser();

//     const failures = [
//       // 'th_file_parser-02271-point_with_option_section_on_invalid_point_type_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -subtype', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-00122-point_with_inline_subtype.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 43 336 water-flow:paleo
// endscrap
// ''',
//       },
//       {
//         'file': 'th_file_parser-00123-point_with_subtype_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 43 336 water-flow:paleo
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -subtype failures', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-00124-point_with_invalid_subtype_for_type_failure.th2',
//       // 'th_file_parser-00125-point_with_subtype_for_type_with_no_support_failure.th2',
//       'th_file_parser-00126-point_outside_scrap_failure.th2',
//       'th_file_parser-00127-point_duplicate_index_with_type_as_option_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -text', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-02290-point_with_title_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap araras3
//   point 822 9012 label -text "Buraco das Araras - Salão Seco"
// endscrap
// ''',
//       },
//       {
//         'file': 'th_file_parser-02294-point_with_title_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap araras3
//   point 822 9012 label -text PERIGO
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -text failures', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-02291-point_with_faulty_title_option_failure.th2',
//       'th_file_parser-02292-point_with_faulty_title_option_failure.th2',
//       // 'th_file_parser-02295-point_with_faulty_title_option_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -value (altitude)', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-00170-point_with_value_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -2885 604 altitude -value 46
// endscrap
// ''',
//       },
//       {
//         'file':
//             'th_file_parser-00353-altitude_point_with_value_option_set_as_nan.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 1758 -1030 altitude -value NaN
// endscrap
// ''',
//       },
//       {
//         'file':
//             'th_file_parser-02321-altitude_point_with_value_option_with_fix.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 1758 -1030 altitude -value [ fix 1300 ]
// endscrap
// ''',
//       },
//       {
//         'file':
//             'th_file_parser-02322-altitude_point_with_value_option_with_fix.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 1758 -1030 altitude -value [ fix 1300 meter ]
// endscrap
// ''',
//       },
//       {
//         'file': 'th_file_parser-00174-altitude_point_with_hyphen.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 3852 -2159 altitude -value NaN
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -value failures (altitude)', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-02320-altitude_point_with_invalid_value_option-failure.th2',
//       'th_file_parser-02330-height_point_with_value_option_set_as_nan-failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -value (date)', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file':
//             'th_file_parser-00380-point_of_type_date_with_date_only_value_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 2282 80 date -value 2022.02.05
// endscrap
// ''',
//       },
//       {
//         'file':
//             'th_file_parser-00381-point_of_type_date_with_date_value_and_other_options.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 2282 80 date -value 2022.02.05 -scale xs -align bottom-left
// endscrap
// ''',
//       },
//       {
//         'file':
//             'th_file_parser-00382-point_of_type_date_with_date_option_as_hyphen.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 2282 80 date -value -
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -value failures (date)', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-02340-point_of_type_date_with_invalid_date_value_option-failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -value (dimensions)', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-02360-dimensions_point_with_value_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 1758 -1030 dimensions -value [ 7 3.3 ]
// endscrap
// ''',
//       },
//       {
//         'file':
//             'th_file_parser-02361-dimensions_point_with_value_option_with_unit.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 1758 -1030 dimensions -value [ 7 3.3 yard ]
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -value failures (dimensions)', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-02362-dimensions_point_with_value_option_with_unit_without_brackets_failure.th2',
//       'th_file_parser-02363-anchor_point_with_value_option_with_unit_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -value (height)', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-02350-height_point_with_value_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -2885 604 height -value [ 40? feet ]
// endscrap
// ''',
//       },
//       {
//         'file': 'th_file_parser-02353-height_point_with_value_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -2885 604 height -value 40
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -value failures (height)', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-02351-height_point_with_invalid_value_option-failure.th2',
//       'th_file_parser-02352-passage-height_point_with_invalid_value_option-failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -value (passage-height)', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file':
//             'th_file_parser-02310-passage_height_point_with_value_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -3081 799 passage-height -value [ +6 -71 ]
// endscrap
// ''',
//       },
//       {
//         'file':
//             'th_file_parser-02312-passage_height_point_with_value_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point -3081 799 passage-height -value +6
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         // final (file, isSuccessful, errors) = await parser.parse((success['file'] as String),
//         //     startParser: grammar.start());
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -value failures (passage-height)', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-00185-passage_height_point_with_value_option_without_brackets-failure.th2',
//       'th_file_parser-02311-passage_height_point_with_value_option_with_invalid_unit-failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });

//   group('point -visibility', () {
//     final parser = THFileParser();
//     final writer = THFileWriter();

//     const successes = [
//       {
//         'file': 'th_file_parser-02220-point_with_visibility_option.th2',
//         'length': 4,
//         'encoding': 'UTF-8',
//         'asFile': r'''encoding UTF-8
// scrap test
//   point 122.0031 321.9712 masonry -visibility on
// endscrap
// ''',
//       },
//     ];

//     for (var success in successes) {
//       test(success, () async {
//         final (file, isSuccessful, _) =
//             await parser.parse(THTestAux.testPath(success['file'] as String));
//         expect(isSuccessful, true);
//         expect(file, isA<THFile>());
//         expect(file.encoding, (success['encoding'] as String));
//         expect(file.countElements(), success['length']);

//         final asFile = writer.serialize(file);
//         expect(asFile, success['asFile']);
//       });
//     }
//   });

//   group('point -visibility failures', () {
//     final parser = THFileParser();

//     const failures = [
//       'th_file_parser-02221-point_with_invalid_visibility_option_failure.th2',
//     ];

//     for (var failure in failures) {
//       test(failure, () async {
//         final (_, isSuccessful, error) =
//             await parser.parse(THTestAux.testPath(failure));
//         expect(isSuccessful, false);
//       });
//     }
//   });
}
