import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
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
  group('command: MPAddXTherionImageInsertConfigCommand', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-06-004-only_encoding.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
''',
        'asFileChanged': r'''encoding UTF-8
##XTHERION## xth_me_image_insert {-0 1 1} {-433} "./xvi/2025-10-07-001-color_as_rgb_hex.xvi" 0 {}
''',
        'imageInsertFile':
            './test/auxiliary/xvi/2025-10-07-001-color_as_rgb_hex.xvi',
      },
      {
        'file': '2025-10-06-004-only_encoding.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
''',
        'asFileChanged': r'''encoding UTF-8
##XTHERION## xth_me_image_insert {-0 1 1} {0} "./jpg/2025-10-07-001.jpg" 0 {}
''',
        'imageInsertFile': './test/auxiliary/jpg/2025-10-07-001.jpg',
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
            final THFile snapshotOriginal = THFile.fromMap(parsedFile.toMap());

            /// Execution: taken from TH2FileEditElementEditController.addImage()

            controller.setCanvasScale(1);

            final MPCommand addImageCommand =
                MPCommandFactory.addXTherionInsertImageConfig(
                  imageFilename: success['imageInsertFile'] as String,
                  th2FileEditController: controller,
                );

            controller.execute(addImageCommand);

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
