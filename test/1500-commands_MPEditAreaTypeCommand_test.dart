import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
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
  group('command: MPEditAreaTypeCommand', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-07-001-area_with_line.th2',
        'length': 16,

        /// There are 5 empty lines that are not shown on the sanitized output.
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap test
  area clay
    blaus
  endarea
  line contour -id blaus
    2736.2 -808.5
    2894.3 -202.7
    2264.5 -205.7
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  area debris
    blaus
  endarea
  line contour -id blaus
    2736.2 -808.5
    2894.3 -202.7
    2264.5 -205.7
  endline
endscrap
''',
        'newPLAType': 'debris',
      },
      {
        'file': '2025-10-07-001-area_with_line.th2',
        'length': 16,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap test
  area clay
    blaus
  endarea
  line contour -id blaus
    2736.2 -808.5
    2894.3 -202.7
    2264.5 -205.7
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  area spaceport
    blaus
  endarea
  line contour -id blaus
    2736.2 -808.5
    2894.3 -202.7
    2264.5 -205.7
  endline
endscrap
''',
        'newPLAType': 'spaceport',
      },
    ];

    int count = 1;

    for (var success in successes) {
      test(
        'apply and undo yields original state (equal by value, not identity) : ${success['file']} - ${count++}',
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
            final THFile snapshotOriginal = THFile.fromMap(parsedFile.toMap());

            /// Execution: taken from TH2FileEditUserInteractionController.prepareSetPLAType()

            controller.setActiveScrap(parsedFile.getScraps().first.mpID);

            final int areaMPID = parsedFile.getAreas().first.mpID;

            final MPCommand setPLATypeCommand = MPCommandFactory.editAreasType(
              newAreaType: THAreaType.fromString(
                success['newPLAType'] as String,
              ),
              unknownPLAType: THAreaType.unknownPLATypeFromString(
                success['newPLAType'] as String,
              ),
              areaMPIDs: [areaMPID],
            );

            controller.execute(setPLATypeCommand);

            final String asFileChanged = writer.serialize(controller.thFile);

            expect(asFileChanged, success['asFileChanged']);

            controller.undo();

            final String asFileUndone = writer.serialize(controller.thFile);

            expect(asFileUndone, success['asFileOriginal']);

            // Assert: final state equals original by value but is not the same object
            expect(identical(controller.thFile, snapshotOriginal), isFalse);
            expect(controller.thFile == snapshotOriginal, isTrue);
          } catch (e, st) {
            fail('Unexpected exception: $e\n$st');
          }
        },
      );
    }
  });
}
