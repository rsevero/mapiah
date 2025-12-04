import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'th_test_aux.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();
  group('actions: simplify lines keeping line segment type (Ctrl+L)', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-03-001-simplify_straight_line.th2',
        'length': 23,
        'scale': 5.0,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    72.46 -61.74
    80.37 -62.39
    94.52 -63.03
    108.76 -65.62
    122.36 -69.18
    136.13 -72.61
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    182.36 -109.48
    184.3 -123.49
    187.86 -137.32
    189.64 -150.59
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    94.52 -63.03
    108.76 -65.62
    136.13 -72.61
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    182.36 -109.48
    184.3 -123.49
    187.86 -137.32
    189.64 -150.59
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
      },
      {
        'file': '2025-10-03-001-simplify_straight_line.th2',
        'length': 23,
        'scale': 1.0,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    72.46 -61.74
    80.37 -62.39
    94.52 -63.03
    108.76 -65.62
    122.36 -69.18
    136.13 -72.61
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    182.36 -109.48
    184.3 -123.49
    187.86 -137.32
    189.64 -150.59
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    94.52 -63.03
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    184.3 -123.49
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
      },
      {
        'file': '2025-10-27-002-bezier_line.th2',
        'length': 14,
        'scale': 0.1,
        'encoding': 'UTF-8',
        'lineID': 'blaus',
        'asFileOriginal': r'''encoding UTF-8
scrap test
  line contour -id blaus
    2736.2 -808.5
    2750.782742 -763.207098 2753.753042 -701.893597 2758.628372 -639.551633
    2763.257801 -580.354048 2769.604935 -520.22913 2789.2 -472
    2809.032418 -423.426792 2838.554614 -384.357056 2861.959832 -348.981931
    2892.706019 -302.511515 2912.896336 -262.41677 2886.6 -215.5
    2855.709105 -160.405969 2808.046183 -173.796362 2749.134226 -199.081695
    2705.425227 -217.841836 2655.523955 -243.149803 2601.7 -251.9
    2547.483456 -260.696578 2488.777976 -248.14154 2432.707201 -233.731693
    2370.020304 -217.621543 2310.626565 -199.193039 2264.5 -205.7
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  line contour -id blaus
    2736.2 -808.5
    2750.782742 -763.207098 2753.753042 -701.893597 2758.628372 -639.551633
    2758.6284 -639.5516 2770.547 -487.1451 2861.959832 -348.981931
    2892.706019 -302.511515 2912.896336 -262.41677 2886.6 -215.5
    2855.709105 -160.405969 2808.046183 -173.796362 2749.134226 -199.081695
    2705.425227 -217.841836 2655.523955 -243.149803 2601.7 -251.9
    2547.483456 -260.696578 2488.777976 -248.14154 2432.707201 -233.731693
    2370.020304 -217.621543 2310.626565 -199.193039 2264.5 -205.7
  endline
endscrap
''',
      },
      {
        'file': '2025-11-09-001-complex_line.th2',
        'length': 38,
        'scale': 0.1,
        'encoding': 'UTF-8',
        'lineID': 'balaus',
        'asFileOriginal': r'''encoding UTF-8
scrap U20-U23 -projection plan -scale [ -128 -2644 3414 -2644 0 0 89.9668 0 m ]
  line wall -id balaus
    597 -2427
    597 -2427 582 -2399 587 -2383
    592 -2367 593 -2308 604 -2286
    615 -2264 619 -2229 642 -2197
    689 -2118
    719 -2002
    748 -1927
    764 -1851
    775 -1781
    777 -1693
    782 -1665 797 -1611 817 -1581
    837 -1551 863 -1503 869 -1485
    875 -1467 886 -1446 895 -1415
    904 -1384 916 -1355 929 -1331
    942 -1307 953 -1289 965 -1261
    977 -1233 989 -1193 992 -1164
    984 -1089
    980 -1011
    957 -944
    892 -927
    829 -964
    806 -972 806 -989 767 -990
    728 -991 690 -981 655 -976
    620 -971 602 -968 574 -981
    546 -994 508 -1026 496 -1044
    484 -1062 446 -1104 434 -1121
    422 -1138 398 -1180 377 -1199
    356 -1218 326 -1269 320 -1279
    281 -1332
    245 -1408
    198 -1458
    137 -1510
    83 -1537
  endline
endscrap
''',
        'asFileChanged':
            'encoding UTF-8\n'
            'scrap U20-U23 -projection plan -scale [ -128 -2644 3414 -2644 0 0 89.9668 0 m ]\n'
            '  line wall -id balaus\n'
            '    597 -2427\n'
            '    597 -2427 564.1552 -2365.6895 604 -2286\n'
            '    615 -2264 619 -2229 642 -2197\n'
            '    689 -2118\n'
            '    748 -1927\n'
            '    777 -1693\n'
            '    782 -1665 797 -1611 817 -1581\n'
            '    847.4 -1535.4 965 -1261 965 -1261\n'
            '    977 -1233 989 -1193 992 -1164\n'
            '    980 -1011\n'
            '    957 -944\n'
            '    892 -927\n'
            '    829 -964\n'
            '    806 -972 806 -989 767 -990\n'
            '    728 -991 690 -981 655 -976\n'
            '    551.2174 -961.1739 496 -1044 496 -1044\n'
            '    496 -1044 416.48 -1163.28 377 -1199\n'
            '    356 -1218 326 -1269 320 -1279\n'
            '    245 -1408\n'
            '    137 -1510\n'
            '    83 -1537\n'
            '  endline\n'
            'endscrap\n'
            '',
      },
      {
        'file':
            '2025-12-01-003-line_with_line_segment_option_at_last_line_segment.th2',
        'length': 9,
        'encoding': 'UTF-8',
        'scale': 0.01,
        'lineID': 'option_at_last_segment',
        'asFileOriginal': r'''encoding UTF-8
scrap Bonita-1R1-1p -projection plan -scale [ 0 0 39.3701 0 0 0 1 0 m ]
  line slope -id option_at_last_segment
    -46.89 31.54
    -36.66 36.61
    -29.52 41
    -19.68 45.42
      l-size 20
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap Bonita-1R1-1p -projection plan -scale [ 0 0 39.3701 0 0 0 1 0 m ]
  line slope -id option_at_last_segment
    -46.89 31.54
    -19.68 45.42
      l-size 20
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(
        'apply and undo yields original state (equal by value, not identity): ${success['file']} at scale ${success['scale']}',
        () async {
          try {
            final parser = THFileParser();
            final writer = THFileWriter();
            mpLocator.mpGeneralController.reset();
            final String path = THTestAux.testPath(success['file']! as String);
            final (parsedFile, isSuccessful, errors) = await parser.parse(
              path,
              forceNewController: true,
            );
            expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
            expect(parsedFile, isA<THFile>());
            expect(parsedFile.encoding, (success['encoding'] as String));
            expect(parsedFile.countElements(), success['length']);

            final String asFile = writer.serialize(parsedFile);
            expect(asFile, success['asFileOriginal']);
            final TH2FileEditController controller = mpLocator
                .mpGeneralController
                .getTH2FileEditController(filename: path);

            // Snapshot original state (deep clone via toMap/fromMap)
            final THFile snapshotOriginal = THFile.fromMap(
              controller.thFile.toMap(),
            );

            /// Execution: taken from MPTH2FileEditPageSimplifyLineMixin.onKeyLDownEvent()

            // Select the single line in the file
            final THLine line = controller.thFile.getLines().first;
            final int lineMPID = line.mpID;

            controller.selectionController.addSelectedElement(line);
            controller.setCanvasScale(success['scale'] as double);
            controller.elementEditController.setLineSimplificationMethod(
              MPLineSimplificationMethod.keepOriginalTypes,
            );
            controller.elementEditController.simplifySelectedLines();

            expect(
              controller.thFile
                      .lineByMPID(lineMPID)
                      .getLineSegmentMPIDs(controller.thFile)
                      .length <
                  snapshotOriginal
                      .lineByMPID(lineMPID)
                      .getLineSegmentMPIDs(snapshotOriginal)
                      .length,
              isTrue,
            );

            final String asFileChanged = writer.serialize(controller.thFile);

            expect(asFileChanged, success['asFileChanged']);

            // Undo the action
            controller.undo();

            final String asFileUndone = writer.serialize(controller.thFile);

            expect(asFileUndone, success['asFileOriginal']);

            // Assert: final state equals original by value but is not the same object
            expect(controller.thFile == snapshotOriginal, isTrue);
            expect(identical(controller.thFile, snapshotOriginal), isFalse);
          } catch (e, st) {
            fail('Unexpected exception: $e\n$st');
          }
        },
      );
    }
  });

  group('actions: simplify lines forcing Bézier line segment (Ctrl+Alt+L)', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-03-001-simplify_straight_line.th2',
        'length': 23,
        'scale': 5.0,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    72.46 -61.74
    80.37 -62.39
    94.52 -63.03
    108.76 -65.62
    122.36 -69.18
    136.13 -72.61
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    182.36 -109.48
    184.3 -123.49
    187.86 -137.32
    189.64 -150.59
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    68.25 -61.655 76.3414 -61.9571 80.37 -62.39
    85.9388 -62.9163 101.79 -64.3425 108.76 -65.62
    115.723 -66.8957 131.0363 -71.3963 136.13 -72.61
    139.4402 -73.4612 146.1825 -74.5641 149.51 -75.33
    154.5425 -76.4425 172.1132 -77.9829 176.39 -81.51
    179.9009 -85.9058 180.9263 -102.5038 182.36 -109.48
    183.7885 -116.4294 186.95 -132.1813 187.86 -137.32
    188.5218 -140.6084 188.9885 -147.3002 189.64 -150.59
    190.3088 -154.0088 190.9784 -162.084 193.21 -164.67
    195.475 -167.2475 204.1225 -169.575 207.76 -171.21
  endline
endscrap
''',
      },
      {
        'file': '2025-10-03-001-simplify_straight_line.th2',
        'length': 23,
        'scale': 1.0,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    72.46 -61.74
    80.37 -62.39
    94.52 -63.03
    108.76 -65.62
    122.36 -69.18
    136.13 -72.61
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    182.36 -109.48
    184.3 -123.49
    187.86 -137.32
    189.64 -150.59
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    75.3475 -62.4625 98.0975 -63.88 108.76 -65.62
    119.128 -67.2898 141.0563 -73.3438 149.51 -75.33
    156.2207 -76.9155 172.1132 -77.9829 176.39 -81.51
    179.9009 -85.9058 181.0462 -102.4494 182.36 -109.48
    184.0163 -118.115 188.2838 -143.6913 189.64 -150.59
    190.1633 -154.2036 190.9784 -162.084 193.21 -164.67
    195.475 -167.2475 204.1225 -169.575 207.76 -171.21
  endline
endscrap
''',
      },
      {
        'file': '2025-10-27-002-bezier_line.th2',
        'length': 14,
        'scale': 0.1,
        'encoding': 'UTF-8',
        'lineID': 'blaus',
        'asFileOriginal': r'''encoding UTF-8
scrap test
  line contour -id blaus
    2736.2 -808.5
    2750.782742 -763.207098 2753.753042 -701.893597 2758.628372 -639.551633
    2763.257801 -580.354048 2769.604935 -520.22913 2789.2 -472
    2809.032418 -423.426792 2838.554614 -384.357056 2861.959832 -348.981931
    2892.706019 -302.511515 2912.896336 -262.41677 2886.6 -215.5
    2855.709105 -160.405969 2808.046183 -173.796362 2749.134226 -199.081695
    2705.425227 -217.841836 2655.523955 -243.149803 2601.7 -251.9
    2547.483456 -260.696578 2488.777976 -248.14154 2432.707201 -233.731693
    2370.020304 -217.621543 2310.626565 -199.193039 2264.5 -205.7
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  line contour -id blaus
    2736.2 -808.5
    2750.782742 -763.207098 2753.753042 -701.893597 2758.628372 -639.551633
    2758.6284 -639.5516 2770.547 -487.1451 2861.959832 -348.981931
    2892.706019 -302.511515 2912.896336 -262.41677 2886.6 -215.5
    2855.709105 -160.405969 2808.046183 -173.796362 2749.134226 -199.081695
    2705.425227 -217.841836 2655.523955 -243.149803 2601.7 -251.9
    2547.483456 -260.696578 2488.777976 -248.14154 2432.707201 -233.731693
    2370.020304 -217.621543 2310.626565 -199.193039 2264.5 -205.7
  endline
endscrap
''',
      },
      {
        'file': '2025-11-09-001-complex_line.th2',
        'length': 38,
        'scale': 0.1,
        'encoding': 'UTF-8',
        'lineID': 'balaus',
        'asFileOriginal': r'''encoding UTF-8
scrap U20-U23 -projection plan -scale [ -128 -2644 3414 -2644 0 0 89.9668 0 m ]
  line wall -id balaus
    597 -2427
    597 -2427 582 -2399 587 -2383
    592 -2367 593 -2308 604 -2286
    615 -2264 619 -2229 642 -2197
    689 -2118
    719 -2002
    748 -1927
    764 -1851
    775 -1781
    777 -1693
    782 -1665 797 -1611 817 -1581
    837 -1551 863 -1503 869 -1485
    875 -1467 886 -1446 895 -1415
    904 -1384 916 -1355 929 -1331
    942 -1307 953 -1289 965 -1261
    977 -1233 989 -1193 992 -1164
    984 -1089
    980 -1011
    957 -944
    892 -927
    829 -964
    806 -972 806 -989 767 -990
    728 -991 690 -981 655 -976
    620 -971 602 -968 574 -981
    546 -994 508 -1026 496 -1044
    484 -1062 446 -1104 434 -1121
    422 -1138 398 -1180 377 -1199
    356 -1218 326 -1269 320 -1279
    281 -1332
    245 -1408
    198 -1458
    137 -1510
    83 -1537
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap U20-U23 -projection plan -scale [ -128 -2644 3414 -2644 0 0 89.9668 0 m ]
  line wall -id balaus
    597 -2427
    597 -2427 564.1552 -2365.6895 604 -2286
    615 -2264 619 -2229 642 -2197
    730.2766 -2048.6201 773.0759 -1865.6607 777 -1693
    782 -1665 797 -1611 817 -1581
    847.4 -1535.4 965 -1261 965 -1261
    977 -1233 989 -1193 992 -1164
    979.1155 -1043.2074 1013.233 -855.7997 829 -964
    806 -972 806 -989 767 -990
    728 -991 690 -981 655 -976
    551.2174 -961.1739 496 -1044 496 -1044
    496 -1044 416.48 -1163.28 377 -1199
    356 -1218 326 -1269 320 -1279
    236.9478 -1391.8658 218.6165 -1469.1918 83 -1537
  endline
endscrap
''',
      },
      {
        'file': '2025-11-30-001-simplify_straight_line_with_options.th2',
        'length': 23,
        'scale': 5.0,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    72.46 -61.74
    80.37 -62.39
      l-size 20
    94.52 -63.03
    108.76 -65.62
    122.36 -69.18
    136.13 -72.61
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    182.36 -109.48
    184.3 -123.49
    187.86 -137.32
    189.64 -150.59
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    75.1034 -61.8457 69.717 -61.5146 80.37 -62.39
      l-size 20
    87.4675 -63.1975 101.79 -64.3425 108.76 -65.62
    115.723 -66.8957 131.0363 -71.3963 136.13 -72.61
    139.4402 -73.4612 146.1825 -74.5641 149.51 -75.33
    154.5425 -76.4425 172.1132 -77.9829 176.39 -81.51
    179.9009 -85.9058 180.9263 -102.5038 182.36 -109.48
    183.7885 -116.4294 186.95 -132.1813 187.86 -137.32
    188.5218 -140.6084 188.9885 -147.3002 189.64 -150.59
    190.3088 -154.0088 190.9784 -162.084 193.21 -164.67
    195.475 -167.2475 204.1225 -169.575 207.76 -171.21
  endline
endscrap
''',
      },
      {
        'file':
            '2025-12-01-003-line_with_line_segment_option_at_last_line_segment.th2',
        'length': 9,
        'encoding': 'UTF-8',
        'scale': 0.1,
        'lineID': 'option_at_last_segment',
        'asFileOriginal': r'''encoding UTF-8
scrap Bonita-1R1-1p -projection plan -scale [ 0 0 39.3701 0 0 0 1 0 m ]
  line slope -id option_at_last_segment
    -46.89 31.54
    -36.66 36.61
    -29.52 41
    -19.68 45.42
      l-size 20
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap Bonita-1R1-1p -projection plan -scale [ 0 0 39.3701 0 0 0 1 0 m ]
  line slope -id option_at_last_segment
    -46.89 31.54
    -37.6661 36.1114 -29.0697 41.2023 -19.68 45.42
      l-size 20
  endline
endscrap
''',
      },
      {
        'file': '2025-12-02-002-straight_line_to_simplify_to_bezier.th2',
        'length': 17,
        'encoding': 'UTF-8',
        'scale': 1.5,
        'lineID': 'option_at_last_segment',
        'asFileOriginal': r'''encoding UTF-8
scrap Bonita-1R1-1p
  line slope
    -759.4 1446.23
    -750.08 1438.86
    -741.48 1435.59
    -732.49 1432.81
    -723.58 1431.09
    -715.32 1429.45
    -705.18 1428.64
    -694.23 1425.77
    -683.12 1423.32
    -672.47 1422.09
    -662.77 1420.86
    -651.61 1420.45
      l-size 20
  endline
endscrap
''',
        'asFileChanged':
            'encoding UTF-8\n'
            'scrap Bonita-1R1-1p\n'
            '  line slope\n'
            '    -759.4 1446.23\n'
            '    -757.07 1444.3875 -753.3313 1439.5375 -750.08 1438.86\n'
            '    -743.3025 1436.6613 -713.55 1430.5825 -705.18 1428.64\n'
            '    -699.6477 1427.3818 -688.7697 1424.0914 -683.12 1423.32\n'
            '    -676.4238 1422.2963 -659.4875 1421.1675 -651.61 1420.45\n'
            '      l-size 20\n'
            '  endline\n'
            'endscrap\n'
            '',
      },
    ];

    for (var success in successes) {
      test(
        'apply and undo yields original state (equal by value, not identity): ${success['file']} at scale ${success['scale']}',
        () async {
          try {
            final parser = THFileParser();
            final writer = THFileWriter();
            mpLocator.mpGeneralController.reset();
            final String path = THTestAux.testPath(success['file']! as String);
            final (parsedFile, isSuccessful, errors) = await parser.parse(
              path,
              forceNewController: true,
            );
            expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
            expect(parsedFile, isA<THFile>());
            expect(parsedFile.encoding, (success['encoding'] as String));
            expect(parsedFile.countElements(), success['length']);

            final asFile = writer.serialize(parsedFile);
            expect(asFile, success['asFileOriginal']);
            final TH2FileEditController controller = mpLocator
                .mpGeneralController
                .getTH2FileEditController(filename: path);

            // Snapshot original state (deep clone via toMap/fromMap)
            final THFile snapshotOriginal = THFile.fromMap(
              controller.thFile.toMap(),
            );

            /// Execution: taken from MPTH2FileEditPageSimplifyLineMixin.onKeyLDownEvent()

            // Select the single line in the file
            final THLine line = controller.thFile.getLines().first;
            final int lineMPID = line.mpID;

            controller.selectionController.addSelectedElement(line);
            controller.setCanvasScale(success['scale'] as double);
            controller.elementEditController.setLineSimplificationMethod(
              MPLineSimplificationMethod.forceBezier,
            );
            controller.elementEditController.simplifySelectedLines();

            expect(
              controller.thFile
                      .lineByMPID(lineMPID)
                      .getLineSegmentMPIDs(controller.thFile)
                      .length <
                  snapshotOriginal
                      .lineByMPID(lineMPID)
                      .getLineSegmentMPIDs(snapshotOriginal)
                      .length,
              isTrue,
            );

            final String asFileChanged = writer.serialize(controller.thFile);

            expect(asFileChanged, success['asFileChanged']);

            // Undo the action
            controller.undo();

            final String asFileUndone = writer.serialize(controller.thFile);

            expect(asFileUndone, success['asFileOriginal']);

            // Assert: final state equals original by value but is not the same object
            expect(controller.thFile == snapshotOriginal, isTrue);
            expect(identical(controller.thFile, snapshotOriginal), isFalse);
          } catch (e, st) {
            fail('Unexpected exception: $e\n$st');
          }
        },
      );
    }
  });

  group('actions: simplify lines forcing straight line segments (Ctrl+Shift+L)', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-03-001-simplify_straight_line.th2',
        'length': 23,
        'scale': 5.0,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    72.46 -61.74
    80.37 -62.39
    94.52 -63.03
    108.76 -65.62
    122.36 -69.18
    136.13 -72.61
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    182.36 -109.48
    184.3 -123.49
    187.86 -137.32
    189.64 -150.59
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    94.52 -63.03
    108.76 -65.62
    136.13 -72.61
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    182.36 -109.48
    184.3 -123.49
    187.86 -137.32
    189.64 -150.59
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
      },
      {
        'file': '2025-10-03-001-simplify_straight_line.th2',
        'length': 23,
        'scale': 1.0,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    72.46 -61.74
    80.37 -62.39
    94.52 -63.03
    108.76 -65.62
    122.36 -69.18
    136.13 -72.61
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    182.36 -109.48
    184.3 -123.49
    187.86 -137.32
    189.64 -150.59
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    94.52 -63.03
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    184.3 -123.49
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
      },
      {
        'file': '2025-10-27-002-bezier_line.th2',
        'length': 14,
        'scale': 0.1,
        'encoding': 'UTF-8',
        'lineID': 'blaus',
        'asFileOriginal': r'''encoding UTF-8
scrap test
  line contour -id blaus
    2736.2 -808.5
    2750.782742 -763.207098 2753.753042 -701.893597 2758.628372 -639.551633
    2763.257801 -580.354048 2769.604935 -520.22913 2789.2 -472
    2809.032418 -423.426792 2838.554614 -384.357056 2861.959832 -348.981931
    2892.706019 -302.511515 2912.896336 -262.41677 2886.6 -215.5
    2855.709105 -160.405969 2808.046183 -173.796362 2749.134226 -199.081695
    2705.425227 -217.841836 2655.523955 -243.149803 2601.7 -251.9
    2547.483456 -260.696578 2488.777976 -248.14154 2432.707201 -233.731693
    2370.020304 -217.621543 2310.626565 -199.193039 2264.5 -205.7
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  line contour -id blaus
    2736.2 -808.5
    2789.2 -472
    2861.959832 -348.981931
    2886.6 -215.5
    2749.134226 -199.081695
    2601.7 -251.9
    2264.5 -205.7
  endline
endscrap
''',
      },
      {
        'file': '2025-11-09-001-complex_line.th2',
        'length': 38,
        'scale': 0.1,
        'encoding': 'UTF-8',
        'lineID': 'balaus',
        'asFileOriginal': r'''encoding UTF-8
scrap U20-U23 -projection plan -scale [ -128 -2644 3414 -2644 0 0 89.9668 0 m ]
  line wall -id balaus
    597 -2427
    597 -2427 582 -2399 587 -2383
    592 -2367 593 -2308 604 -2286
    615 -2264 619 -2229 642 -2197
    689 -2118
    719 -2002
    748 -1927
    764 -1851
    775 -1781
    777 -1693
    782 -1665 797 -1611 817 -1581
    837 -1551 863 -1503 869 -1485
    875 -1467 886 -1446 895 -1415
    904 -1384 916 -1355 929 -1331
    942 -1307 953 -1289 965 -1261
    977 -1233 989 -1193 992 -1164
    984 -1089
    980 -1011
    957 -944
    892 -927
    829 -964
    806 -972 806 -989 767 -990
    728 -991 690 -981 655 -976
    620 -971 602 -968 574 -981
    546 -994 508 -1026 496 -1044
    484 -1062 446 -1104 434 -1121
    422 -1138 398 -1180 377 -1199
    356 -1218 326 -1269 320 -1279
    281 -1332
    245 -1408
    198 -1458
    137 -1510
    83 -1537
  endline
endscrap
''',
        'asFileChanged':
            'encoding UTF-8\n'
            'scrap U20-U23 -projection plan -scale [ -128 -2644 3414 -2644 0 0 89.9668 0 m ]\n'
            '  line wall -id balaus\n'
            '    597 -2427\n'
            '    587 -2383\n'
            '    604 -2286\n'
            '    642 -2197\n'
            '    689 -2118\n'
            '    748 -1927\n'
            '    777 -1693\n'
            '    965 -1261\n'
            '    992 -1164\n'
            '    980 -1011\n'
            '    957 -944\n'
            '    892 -927\n'
            '    829 -964\n'
            '    767 -990\n'
            '    574 -981\n'
            '    496 -1044\n'
            '    320 -1279\n'
            '    245 -1408\n'
            '    137 -1510\n'
            '    83 -1537\n'
            '  endline\n'
            'endscrap\n'
            '',
      },
      {
        'file': '2025-12-01-001-bezier_line_with_line_segment_options.th2',
        'length': 14,
        'scale': 0.1,
        'encoding': 'UTF-8',
        'lineID': 'blaus',
        'asFileOriginal': r'''encoding UTF-8
scrap test
  line contour -id blaus
    2736.2 -808.5
    2750.782742 -763.207098 2753.753042 -701.893597 2758.628372 -639.551633
    2763.257801 -580.354048 2769.604935 -520.22913 2789.2 -472
    2809.032418 -423.426792 2838.554614 -384.357056 2861.959832 -348.981931
    2892.706019 -302.511515 2912.896336 -262.41677 2886.6 -215.5
    2855.709105 -160.405969 2808.046183 -173.796362 2749.134226 -199.081695
    2705.425227 -217.841836 2655.523955 -243.149803 2601.7 -251.9
      smooth on
    2547.483456 -260.696578 2488.777976 -248.14154 2432.707201 -233.731693
    2370.020304 -217.621543 2310.626565 -199.193039 2264.5 -205.7
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  line contour -id blaus
    2736.2 -808.5
    2789.2 -472
    2861.959832 -348.981931
    2886.6 -215.5
    2749.134226 -199.081695
    2601.7 -251.9
      smooth on
    2264.5 -205.7
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(
        'apply and undo yields original state (equal by value, not identity): ${success['file']} at scale ${success['scale']}',
        () async {
          try {
            final parser = THFileParser();
            final writer = THFileWriter();
            mpLocator.mpGeneralController.reset();
            final String path = THTestAux.testPath(success['file']! as String);
            final (parsedFile, isSuccessful, errors) = await parser.parse(
              path,
              forceNewController: true,
            );
            expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
            expect(parsedFile, isA<THFile>());
            expect(parsedFile.encoding, (success['encoding'] as String));
            expect(parsedFile.countElements(), success['length']);

            final asFile = writer.serialize(parsedFile);
            expect(asFile, success['asFileOriginal']);
            final TH2FileEditController controller = mpLocator
                .mpGeneralController
                .getTH2FileEditController(filename: path);

            // Snapshot original state (deep clone via toMap/fromMap)
            final THFile snapshotOriginal = THFile.fromMap(
              controller.thFile.toMap(),
            );

            /// Execution: taken from MPTH2FileEditPageSimplifyLineMixin.onKeyLDownEvent()

            // Select the single line in the file
            final THLine line = controller.thFile.getLines().first;

            controller.selectionController.addSelectedElement(line);
            controller.setCanvasScale(success['scale'] as double);
            controller.elementEditController.setLineSimplificationMethod(
              MPLineSimplificationMethod.forceStraight,
            );
            controller.elementEditController.simplifySelectedLines();

            final String asFileChanged = writer.serialize(controller.thFile);

            expect(asFileChanged, success['asFileChanged']);

            // Undo the action
            controller.undo();

            final String asFileUndone = writer.serialize(controller.thFile);

            expect(asFileUndone, success['asFileOriginal']);

            // Assert: final state equals original by value but is not the same object
            expect(controller.thFile == snapshotOriginal, isTrue);
            expect(identical(controller.thFile, snapshotOriginal), isFalse);
          } catch (e, st) {
            fail('Unexpected exception: $e\n$st');
          }
        },
      );
    }
  });

  group(
    'actions: simplify lines keeping line segment type (Ctrl+L) with line segments with options',
    () {
      setUp(() {
        mpLocator.appLocalizations = AppLocalizationsEn();
        mpLocator.mpGeneralController.reset();
      });

      const successes = [
        {
          'file': '2025-11-30-001-simplify_straight_line_with_options.th2',
          'length': 23,
          'scale': 5.0,
          'encoding': 'UTF-8',
          'asFileOriginal': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    72.46 -61.74
    80.37 -62.39
      l-size 20
    94.52 -63.03
    108.76 -65.62
    122.36 -69.18
    136.13 -72.61
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    182.36 -109.48
    184.3 -123.49
    187.86 -137.32
    189.64 -150.59
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
          'asFileChanged': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    80.37 -62.39
      l-size 20
    94.52 -63.03
    108.76 -65.62
    136.13 -72.61
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    182.36 -109.48
    184.3 -123.49
    187.86 -137.32
    189.64 -150.59
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
        },
        {
          'file': '2025-11-30-001-simplify_straight_line_with_options.th2',
          'length': 23,
          'scale': 1.0,
          'encoding': 'UTF-8',
          'asFileOriginal': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    72.46 -61.74
    80.37 -62.39
      l-size 20
    94.52 -63.03
    108.76 -65.62
    122.36 -69.18
    136.13 -72.61
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    182.36 -109.48
    184.3 -123.49
    187.86 -137.32
    189.64 -150.59
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
          'asFileChanged': r'''encoding UTF-8
scrap Trianglinho-1R1-2p
  line wall
    64.21 -61.41
    80.37 -62.39
      l-size 20
    108.76 -65.62
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    184.3 -123.49
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
        },
        {
          'file': '2025-12-01-001-bezier_line_with_line_segment_options.th2',
          'length': 14,
          'scale': 0.1,
          'encoding': 'UTF-8',
          'lineID': 'blaus',
          'asFileOriginal': r'''encoding UTF-8
scrap test
  line contour -id blaus
    2736.2 -808.5
    2750.782742 -763.207098 2753.753042 -701.893597 2758.628372 -639.551633
    2763.257801 -580.354048 2769.604935 -520.22913 2789.2 -472
    2809.032418 -423.426792 2838.554614 -384.357056 2861.959832 -348.981931
    2892.706019 -302.511515 2912.896336 -262.41677 2886.6 -215.5
    2855.709105 -160.405969 2808.046183 -173.796362 2749.134226 -199.081695
    2705.425227 -217.841836 2655.523955 -243.149803 2601.7 -251.9
      smooth on
    2547.483456 -260.696578 2488.777976 -248.14154 2432.707201 -233.731693
    2370.020304 -217.621543 2310.626565 -199.193039 2264.5 -205.7
  endline
endscrap
''',
          'asFileChanged': r'''encoding UTF-8
scrap test
  line contour -id blaus
    2736.2 -808.5
    2750.782742 -763.207098 2753.753042 -701.893597 2758.628372 -639.551633
    2758.6284 -639.5516 2770.547 -487.1451 2861.959832 -348.981931
    2892.706019 -302.511515 2912.896336 -262.41677 2886.6 -215.5
    2855.709105 -160.405969 2808.046183 -173.796362 2749.134226 -199.081695
    2705.425227 -217.841836 2655.523955 -243.149803 2601.7 -251.9
      smooth on
    2547.483456 -260.696578 2488.777976 -248.14154 2432.707201 -233.731693
    2370.020304 -217.621543 2310.626565 -199.193039 2264.5 -205.7
  endline
endscrap
''',
        },
        {
          'file': '2025-12-01-002-complex_line_with_options.th2',
          'length': 38,
          'scale': 0.1,
          'encoding': 'UTF-8',
          'lineID': 'balaus',
          'asFileOriginal': r'''encoding UTF-8
scrap U20-U23 -projection plan -scale [ -128 -2644 3414 -2644 0 0 89.9668 0 m ]
  line wall -id balaus
    597 -2427
    597 -2427 582 -2399 587 -2383
      l-size 13
    592 -2367 593 -2308 604 -2286
    615 -2264 619 -2229 642 -2197
    689 -2118
    719 -2002
      orientation 192
    748 -1927
    764 -1851
    775 -1781
    777 -1693
    782 -1665 797 -1611 817 -1581
    837 -1551 863 -1503 869 -1485
    875 -1467 886 -1446 895 -1415
    904 -1384 916 -1355 929 -1331
    942 -1307 953 -1289 965 -1261
    977 -1233 989 -1193 992 -1164
    984 -1089
    980 -1011
    957 -944
    892 -927
    829 -964
    806 -972 806 -989 767 -990
    728 -991 690 -981 655 -976
    620 -971 602 -968 574 -981
    546 -994 508 -1026 496 -1044
    484 -1062 446 -1104 434 -1121
    422 -1138 398 -1180 377 -1199
    356 -1218 326 -1269 320 -1279
    281 -1332
    245 -1408
    198 -1458
    137 -1510
    83 -1537
  endline
endscrap
''',
          'asFileChanged':
              'encoding UTF-8\n'
              'scrap U20-U23 -projection plan -scale [ -128 -2644 3414 -2644 0 0 89.9668 0 m ]\n'
              '  line wall -id balaus\n'
              '    597 -2427\n'
              '    597 -2427 582 -2399 587 -2383\n'
              '      l-size 13\n'
              '    592 -2367 593 -2308 604 -2286\n'
              '    615 -2264 619 -2229 642 -2197\n'
              '    689 -2118\n'
              '    719 -2002\n'
              '      orientation 192\n'
              '    764 -1851\n'
              '    777 -1693\n'
              '    782 -1665 797 -1611 817 -1581\n'
              '    847.4 -1535.4 965 -1261 965 -1261\n'
              '    977 -1233 989 -1193 992 -1164\n'
              '    980 -1011\n'
              '    957 -944\n'
              '    892 -927\n'
              '    829 -964\n'
              '    806 -972 806 -989 767 -990\n'
              '    728 -991 690 -981 655 -976\n'
              '    551.2174 -961.1739 496 -1044 496 -1044\n'
              '    496 -1044 416.48 -1163.28 377 -1199\n'
              '    356 -1218 326 -1269 320 -1279\n'
              '    245 -1408\n'
              '    137 -1510\n'
              '    83 -1537\n'
              '  endline\n'
              'endscrap\n'
              '',
        },
      ];

      for (var success in successes) {
        test(
          'apply and undo yields original state (equal by value, not identity): ${success['file']} at scale ${success['scale']}',
          () async {
            try {
              final parser = THFileParser();
              final writer = THFileWriter();
              mpLocator.mpGeneralController.reset();
              final String path = THTestAux.testPath(
                success['file']! as String,
              );
              final (parsedFile, isSuccessful, errors) = await parser.parse(
                path,
                forceNewController: true,
              );
              expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
              expect(parsedFile, isA<THFile>());
              expect(parsedFile.encoding, (success['encoding'] as String));
              expect(parsedFile.countElements(), success['length']);

              final String asFile = writer.serialize(parsedFile);
              expect(asFile, success['asFileOriginal']);
              final TH2FileEditController controller = mpLocator
                  .mpGeneralController
                  .getTH2FileEditController(filename: path);

              // Snapshot original state (deep clone via toMap/fromMap)
              final THFile snapshotOriginal = THFile.fromMap(
                controller.thFile.toMap(),
              );

              /// Execution: taken from MPTH2FileEditPageSimplifyLineMixin.onKeyLDownEvent()

              // Select the single line in the file
              final THLine line = controller.thFile.getLines().first;
              final int lineMPID = line.mpID;

              controller.selectionController.addSelectedElement(line);
              controller.setCanvasScale(success['scale'] as double);
              controller.elementEditController.setLineSimplificationMethod(
                MPLineSimplificationMethod.keepOriginalTypes,
              );
              controller.elementEditController.simplifySelectedLines();

              expect(
                controller.thFile
                        .lineByMPID(lineMPID)
                        .getLineSegmentMPIDs(controller.thFile)
                        .length <
                    snapshotOriginal
                        .lineByMPID(lineMPID)
                        .getLineSegmentMPIDs(snapshotOriginal)
                        .length,
                isTrue,
              );

              final String asFileChanged = writer.serialize(controller.thFile);

              expect(asFileChanged, success['asFileChanged']);

              // Undo the action
              controller.undo();

              final String asFileUndone = writer.serialize(controller.thFile);

              expect(asFileUndone, success['asFileOriginal']);

              // Assert: final state equals original by value but is not the same object
              expect(controller.thFile == snapshotOriginal, isTrue);
              expect(identical(controller.thFile, snapshotOriginal), isFalse);
            } catch (e, st) {
              fail('Unexpected exception: $e\n$st');
            }
          },
        );
      }
    },
  );
}
