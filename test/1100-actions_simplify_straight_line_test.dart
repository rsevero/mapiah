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
    return '/tmp'; // or any fake path
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();
  group('actions: simplify straight line (Ctrl+L)', () {
    setUp(() {
      // Provide localizations to avoid null access in updateUndoRedoStatus()
      mpLocator.appLocalizations = AppLocalizationsEn();
      // Reset IDs and cached controllers between tests
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-03-001-simplify_straight_line.th2',
        'length': 23,
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
    ];

    for (var success in successes) {
      test(
        'apply and undo yields original state (equal by value, not identity) : ${success['file']}',
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
            final THFile originalSnapshot = THFile.fromMap(
              controller.thFile.toMap(),
            );

            // Select the single line in the file
            final THLine line = controller.thFile.getLines().first;
            controller.selectionController.addSelectedElement(line);

            controller.setCanvasScale(5);

            // Act: set method, prepare tolerance and original set, then simplify
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
            expect(controller.thFile == originalSnapshot, isTrue);
            expect(identical(controller.thFile, originalSnapshot), isFalse);
          } catch (e, st) {
            fail('Unexpected exception: $e\n$st');
          }
        },
      );
    }
    ;
  });
}
