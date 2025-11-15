import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
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
  group('command: MPEditPointTypeCommand', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-07-002-point.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap test
  point 12.2 42.7 station
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  point 12.2 42.7 stalactite
endscrap
''',
        'newPLAType': 'stalactite',
      },
      {
        'file': '2025-10-07-002-point.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap test
  point 12.2 42.7 station
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  point 12.2 42.7 stairwaytoheaven
endscrap
''',
        'newPLAType': 'stairwaytoheaven',
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

            final int pointMPID = parsedFile.getPoints().first.mpID;

            final MPCommand setPLATypeCommand = MPCommandFactory.editPointsType(
              newPointType: THPointType.fromString(
                success['newPLAType'] as String,
              ),
              unknownPLAType: THPointType.unknownPLATypeFromString(
                success['newPLAType'] as String,
              ),
              pointMPIDs: [pointMPID],
            );

            controller.execute(setPLATypeCommand);

            final String asFileChanged = writer.serialize(controller.thFile);

            expect(asFileChanged, success['asFileChanged']);

            // Undo line create
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
