import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
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
  group('actions: smooth line points test (S)', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-12-10-001-line.th2',
        'length': 22,
        'smoothedChildIndexes': [7, 8, 9, 10],
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap Bonita
  line wall
    2958.06 -1197.98 2746.69 -1144.75 2638.25 -1116.12
    2666.53 -1121.02 2674.25 -1119.45 2686.25 -1120.04
    2690.52 -1120.91 2699.29 -1122.01 2703.27 -1123.42
    2707.25 -1124.83 2712.18 -1125.63 2716.01 -1127.25
    2719.84 -1128.87 2728.22 -1130.46 2732 -1132.03
    2735.77 -1133.59 2743.54 -1138.41 2746.26 -1139.8
    2748.07 -1140.78 2752.22 -1141.58 2753.8 -1143.2
    2757.05 -1145.52 2768.84 -1156.4 2772.54 -1158.68
    2774.94 -1160.63 2780.76 -1160.63 2783.4 -1161.39
    2786 -1162.14 2791.2 -1163.67 2793.69 -1164.77
    2797.53 -1166.32 2808.59 -1172.43 2814.1 -1173.76
    2830.13 -1175.23 2837.36 -1191.36 2849.95 -1194.18
    2852.09 -1194.38 2856.28 -1195.38 2858.44 -1195.4
    2862.53 -1195.69 2878.59 -1196.19 2882.65 -1196.52
    2884.79 -1196.49 2888.69 -1198.45 2890.89 -1198.08
    2893.73 -1197.83 2901.58 -1194.6 2905.4 -1194.5
    2910.81 -1194.01 2928.16 -1193.93 2934.18 -1194.18
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap Bonita
  line wall
    2958.06 -1197.98 2746.69 -1144.75 2638.25 -1116.12
    2666.53 -1121.02 2674.25 -1119.45 2686.25 -1120.04
    2690.52 -1120.91 2699.29 -1122.01 2703.27 -1123.42
    2707.25 -1124.83 2712.18 -1125.63 2716.01 -1127.25
    2719.84 -1128.87 2728.22 -1130.46 2732 -1132.03
    2735.77 -1133.59 2743.54 -1138.41 2746.26 -1139.8
    2748.07 -1140.78 2752.22 -1141.58 2753.8 -1143.2
    2757.05 -1145.52 2768.968586 -1156.203429 2772.54 -1158.68
      smooth on
    2774.94 -1160.63 2780.760203 -1160.629295 2783.4 -1161.39
      smooth on
    2786 -1162.14 2791.17901 -1163.718796 2793.69 -1164.77
      smooth on
    2797.53 -1166.32 2808.479046 -1173.029328 2814.1 -1173.76
      smooth on
    2830.062958 -1175.835036 2837.36 -1191.36 2849.95 -1194.18
    2852.09 -1194.38 2856.28 -1195.38 2858.44 -1195.4
    2862.53 -1195.69 2878.59 -1196.19 2882.65 -1196.52
    2884.79 -1196.49 2888.69 -1198.45 2890.89 -1198.08
    2893.73 -1197.83 2901.58 -1194.6 2905.4 -1194.5
    2910.81 -1194.01 2928.16 -1193.93 2934.18 -1194.18
  endline
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(
        'apply and undo yields original state (equal by value, not identity): ${success['file']}',
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
            controller.setActiveScrap(parsedFile.getScraps().first.mpID);

            final THLine line = controller.thFile.getLines().first;

            controller.selectionController.addSelectedElement(line);
            controller.stateController.setState(
              MPTH2FileEditStateType.editSingleLine,
            );

            controller.selectionController
                .updateSelectableEndAndControlPoints();

            final List<int> childrenMPIDs = line.getLineSegmentMPIDs(
              controller.thFile,
            );
            final List<int> smoothedChildIndexes =
                success['smoothedChildIndexes'] as List<int>;
            final Set<int> smoothedChildMPIDs = {};

            for (final int index in smoothedChildIndexes) {
              smoothedChildMPIDs.add(childrenMPIDs[index]);
            }

            final Iterable<MPSelectable> mpSelectableElements = controller
                .selectionController
                .getMPSelectableEndControlPoints();

            for (final MPSelectable mpSelectableElement
                in mpSelectableElements) {
              if (mpSelectableElement is! MPSelectableEndControlPoint) {
                continue;
              }

              if (smoothedChildMPIDs.contains(
                mpSelectableElement.element.mpID,
              )) {
                controller.selectionController.addSelectedEndControlPoint(
                  mpSelectableElement,
                );
              }
            }

            controller.selectionController
                .updateSelectableEndAndControlPoints();

            controller.elementEditController
                .toggleSelectedLinePointsSmoothOption();

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
}
