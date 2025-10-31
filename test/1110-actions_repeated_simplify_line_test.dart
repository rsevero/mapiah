import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
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
  group('actions: simplify straight line (Ctrl+L)', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-03-001-simplify_straight_line.th2',
        'length': 23,
        'scale': 5.0,
        'repetitions': 2,
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
        'scale': 1.0,
        'repetitions': 8,
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
    2758.628372 -639.551633 2770.547019 -487.145127 2861.959832 -348.981931
    2892.706019 -302.511515 2912.896336 -262.41677 2886.6 -215.5
    2855.709105 -160.405969 2808.046183 -173.796362 2749.134226 -199.081695
    2465.034553 -321.018826 2344.466397 -194.419337 2264.5 -205.7
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(
        'apply and undo yields original state (equal by value, not identity) : ${success['file']} at scale ${success['scale']}',
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
            for (int i = 0; i < (success['repetitions'] as int); i++) {
              controller.elementEditController.simplifySelectedLines();
            }

            final int simplifiedLineSegmentCount = controller.thFile
                .lineByMPID(lineMPID)
                .getLineSegmentMPIDs(controller.thFile)
                .length;
            final int originalLineSegmentCount = snapshotOriginal
                .lineByMPID(lineMPID)
                .getLineSegmentMPIDs(snapshotOriginal)
                .length;

            expect(
              simplifiedLineSegmentCount < originalLineSegmentCount,
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
    ;
  });
}
