import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
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
  group('actions: set point id', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-12-17-001-single_point.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap araras3
  point 822 9012 anchor -text "Blaus legal"
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap araras3
  point 822 9012 anchor -id Test -text "Blaus legal"
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

            /// Execution: taken from MPIDOptionWidget._okButtonPressed()()

            // Select the single line in the file
            controller.setActiveScrap(parsedFile.getScraps().first.mpID);

            final THPoint point = controller.thFile.getPoints().first;

            controller.selectionController.clearSelectedElements();
            controller.stateController.setState(
              MPTH2FileEditStateType.selectEmptySelection,
            );

            final Iterable<MPSelectable> mpSelectableElementsPre = controller
                .selectionController
                .getMPSelectableElements()
                .values;
            final THPoint pointSelectablePre =
                mpSelectableElementsPre
                        .firstWhere((e) => e.element.mpID == point.mpID)
                        .element
                    as THPoint;

            expect(MPCommandOptionAux.hasID(pointSelectablePre), isFalse);

            controller.selectionController.addSelectedElement(point);
            controller.stateController.setState(
              MPTH2FileEditStateType.selectNonEmptySelection,
            );

            final THCommandOption newOption =
                THIDCommandOption.fromStringWithParentMPID(
                  parentMPID: 0,
                  thID: 'Test',
                );

            controller.userInteractionController.prepareSetOption(
              option: newOption,
              optionType: THCommandOptionType.id,
            );

            final THPoint pointAfterSetOption = controller.thFile
                .getPoints()
                .first;

            expect(MPCommandOptionAux.hasID(pointAfterSetOption), isTrue);
            expect(
              (pointAfterSetOption.getOption(THCommandOptionType.id)
                      as THIDCommandOption)
                  .thID,
              'Test',
            );

            controller.selectionController.clearSelectedElements();
            controller.stateController.setState(
              MPTH2FileEditStateType.selectEmptySelection,
            );

            final Iterable<MPSelectable> mpSelectableElementsPos = controller
                .selectionController
                .getMPSelectableElements()
                .values;
            final THPoint pointSelectablePos =
                mpSelectableElementsPos
                        .firstWhere(
                          (e) => e.element.mpID == pointAfterSetOption.mpID,
                        )
                        .element
                    as THPoint;

            expect(MPCommandOptionAux.hasID(pointSelectablePos), isTrue);
            expect(
              (pointSelectablePos.getOption(THCommandOptionType.id)
                      as THIDCommandOption)
                  .thID,
              'Test',
            );

            controller.selectionController.addSelectedElement(
              pointAfterSetOption,
            );
            controller.stateController.setState(
              MPTH2FileEditStateType.selectNonEmptySelection,
            );

            final Iterable<MPSelectedElement> mpSelectedElements =
                controller.selectionController.mpSelectedElementsLogical.values;

            expect(mpSelectedElements.length, 1);
            expect(mpSelectedElements.first, isA<MPSelectedPoint>());

            final THPoint selectedPoint =
                mpSelectedElements.first.originalElementClone as THPoint;

            expect(MPCommandOptionAux.hasID(selectedPoint), isTrue);
            expect(
              (selectedPoint.getOption(THCommandOptionType.id)
                      as THIDCommandOption)
                  .thID,
              'Test',
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
}
