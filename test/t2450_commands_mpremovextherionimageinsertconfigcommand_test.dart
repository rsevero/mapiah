// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th2_file.dart';
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
  group('command: MPRemoveXTherionImageInsertConfigCommand without empty lines', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-26-001-with_image.th2',
        'length': 2,
        'encoding': 'UTF-8',
        'lineID': 'blaus',
        'asFileOriginal': r'''encoding UTF-8
##XTHERION## xth_me_image_insert {-0 1 1} -433 "./xvi/2025-10-07-001-color_as_rgb_hex.xvi" 0 {}
''',
        'asFileChanged': r'''encoding UTF-8
''',
      },
    ];

    for (var success in successes) {
      test(
        'apply and undo yields original state (equal by value, not identity) : ${success['file']}',
        () async {
          try {
            final parser = TH2FileParser();
            final writer = TH2FileWriter();
            mpLocator.mpGeneralController.reset();
            final String path = THTestAux.testPath(success['file']! as String);
            final (parsedFile, isSuccessful, errors) = await parser.parse(
              path,
              forceNewController: true,
            );
            expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
            expect(parsedFile, isA<TH2File>());
            expect(parsedFile.encoding, (success['encoding'] as String));
            expect(parsedFile.countElements(), success['length']);

            final asFile = writer.serialize(parsedFile);
            expect(asFile, success['asFileOriginal']);
            final TH2FileEditController controller = mpLocator
                .mpGeneralController
                .getTH2FileEditController(filename: path);

            // Snapshot original state (deep clone via toMap/fromMap)
            final TH2File snapshotOriginal = TH2File.fromMap(
              controller.th2File.toMap(),
            );

            /// Execution: taken from TH2FileEditElementEditController.removeImage()

            final int imageMPID = parsedFile.imageMPIDs.first;
            final MPCommand setCommand =
                MPCommandFactory.removeXTherionImageInsertConfigFromExisting(
                  existingXTherionImageInsertConfigMPID: imageMPID,
                  th2File: parsedFile,
                );

            controller.execute(setCommand);

            final String asFileChanged = writer.serialize(controller.th2File);
            expect(asFileChanged, success['asFileChanged']);

            // Undo the action
            controller.undo();

            final String asFileUndone = writer.serialize(controller.th2File);
            expect(asFileUndone, success['asFileOriginal']);

            // Assert: final state equals original by value but is not the same object
            expect(identical(controller.th2File, snapshotOriginal), isFalse);
            expect(controller.th2File == snapshotOriginal, isTrue);
          } catch (e, st) {
            fail('Unexpected exception: $e\n$st');
          }
        },
      );
    }
  });

  group('command: MPRemoveXTherionImageInsertConfigCommand with empty lines', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-11-27-001-xtherion_image_insert_with_empty_lines.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'lineID': 'blaus',
        'asFileOriginal': r'''encoding UTF-8
##XTHERION## xth_me_image_insert {-0 1 1} -433 "./xvi/2025-10-07-001-color_as_rgb_hex.xvi" 0 {}



''',
        'asFileChanged': r'''encoding UTF-8
''',
      },
    ];

    for (var success in successes) {
      test(
        'apply and undo yields original state (equal by value, not identity) : ${success['file']}',
        () async {
          try {
            final parser = TH2FileParser();
            final writer = TH2FileWriter();
            mpLocator.mpGeneralController.reset();
            final String path = THTestAux.testPath(success['file']! as String);
            final (parsedFile, isSuccessful, errors) = await parser.parse(
              path,
              forceNewController: true,
            );
            expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
            expect(parsedFile, isA<TH2File>());
            expect(parsedFile.encoding, (success['encoding'] as String));
            expect(parsedFile.countElements(), success['length']);

            final asFile = writer.serialize(
              parsedFile,
              includeEmptyLines: true,
            );
            expect(asFile, success['asFileOriginal']);
            final TH2FileEditController controller = mpLocator
                .mpGeneralController
                .getTH2FileEditController(filename: path);

            // Snapshot original state (deep clone via toMap/fromMap)
            final TH2File snapshotOriginal = TH2File.fromMap(
              controller.th2File.toMap(),
            );

            /// Execution: taken from TH2FileEditElementEditController.removeImage()

            final int imageMPID = parsedFile.imageMPIDs.first;
            final MPCommand setCommand =
                MPCommandFactory.removeXTherionImageInsertConfigFromExisting(
                  existingXTherionImageInsertConfigMPID: imageMPID,
                  th2File: parsedFile,
                );

            controller.execute(setCommand);

            final String asFileChanged = writer.serialize(
              controller.th2File,
              includeEmptyLines: true,
            );
            expect(asFileChanged, success['asFileChanged']);

            // Undo the action
            controller.undo();

            final String asFileUndone = writer.serialize(
              controller.th2File,
              includeEmptyLines: true,
            );
            expect(asFileUndone, success['asFileOriginal']);

            // Assert: final state equals original by value but is not the same object
            expect(identical(controller.th2File, snapshotOriginal), isFalse);
            expect(controller.th2File == snapshotOriginal, isTrue);
          } catch (e, st) {
            fail('Unexpected exception: $e\n$st');
          }
        },
      );
    }
  });
}
