// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
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

  group(
    'command: removeImageInsertConfigFromExisting after XTherion conversion',
    () {
      setUp(() {
        mpLocator.appLocalizations = AppLocalizationsEn();
        mpLocator.mpGeneralController.reset();
      });

      test(
        'removes and restores Mapiah image inserts while keeping undo stable',
        () async {
          final TH2FileParser parser = TH2FileParser();
          final TH2FileWriter writer = TH2FileWriter();
          final String path = THTestAux.testPath(
            '2025-10-26-001-with_image.th2',
          );
          final (parsedFile, isSuccessful, errors) = await parser.parse(
            path,
            forceNewController: true,
          );

          expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

          final TH2FileEditController controller = mpLocator.mpGeneralController
              .getTH2FileEditController(filename: path);
          final int imageMPID = parsedFile.imageMPIDs.first;
          final String originalFile = writer.serialize(controller.th2File);

          final MPImageInsertConfig convertedImage = controller
              .elementEditController
              .prepareImageForMPOnlyTransformActions(imageMPID);

          expect(convertedImage.mpID, imageMPID);
          expect(convertedImage, isA<MPXVIImageInsertConfig>());

          final String convertedFile = writer.serialize(controller.th2File);

          expect(convertedFile.contains('##MAPIAH## image_insert_v1'), isTrue);
          expect(
            convertedFile.contains('##XTHERION## xth_me_image_insert'),
            isFalse,
          );

          final MPCommand removeCommand =
              MPCommandFactory.removeImageInsertConfigFromExisting(
                existingImageInsertConfigMPID: imageMPID,
                th2File: controller.th2File,
              );

          controller.execute(removeCommand);

          expect(writer.serialize(controller.th2File), 'encoding UTF-8\n');

          controller.undo();

          expect(writer.serialize(controller.th2File), convertedFile);

          controller.undo();

          expect(writer.serialize(controller.th2File), originalFile);
        },
      );
    },
  );
}
