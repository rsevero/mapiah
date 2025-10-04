import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';

import 'th_test_aux.dart';

// Use the same singleton used by the app code
final MPLocator mpLocator = MPLocator();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('actions: simplify straight line (Ctrl+L)', () {
    setUp(() {
      // Provide localizations to avoid null access in updateUndoRedoStatus()
      mpLocator.appLocalizations = AppLocalizationsEn();
      // Reset IDs and cached controllers between tests
      mpLocator.mpGeneralController.reset();
    });

    test(
      'apply and undo yields original state (equal by value, not identity)',
      () async {
        try {
          // Arrange: parse the test file and get its controller
          final String filename = '2025-10-03-001-simplify_straight_line.th2';
          final String path = THTestAux.testPath(filename);
          final THFileParser parser = THFileParser();
          final (parsedFile, isSuccessful, errors) = await parser.parse(
            path,
            forceNewController: true,
          );
          expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
          expect(parsedFile, isA<THFile>());

          final TH2FileEditController controller = mpLocator.mpGeneralController
              .getTH2FileEditController(filename: path);

          // Snapshot original state (deep clone via toMap/fromMap)
          final THFile originalSnapshot = THFile.fromMap(
            controller.thFile.toMap(),
          );

          // Select the single line in the file
          final THLine line = controller.thFile.getLines().first;
          controller.selectionController.addSelectedElement(line);

          // Act: set method, prepare tolerance and original set, then simplify
          controller.elementEditController.setLineSimplificationMethod(
            MPLineSimplificationMethod.forceStraight,
          );
          controller.elementEditController.simplifySelectedLines();

          // Undo the action
          controller.undo();

          // Assert: final state equals original by value but is not the same object
          expect(controller.thFile == originalSnapshot, isTrue);
          expect(identical(controller.thFile, originalSnapshot), isFalse);
        } catch (e, st) {
          fail('Unexpected exception: $e\n$st');
        }
      },
    );
  });
}
