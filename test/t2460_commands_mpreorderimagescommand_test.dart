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

  group('command: MPReorderImagesCommand', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test('apply, undo and redo keep image order consistent', () async {
      final TH2FileParser parser = TH2FileParser();
      final TH2FileWriter writer = TH2FileWriter();
      final String path = THTestAux.testPath(
        'th_file_parser-00040-adding_several_xtherionsettings.th2',
      );
      final (TH2File parsedFile, bool isSuccessful, List<String> errors) =
          await parser.parse(path, forceNewController: true);

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);
      final TH2File snapshotOriginal = TH2File.fromMap(
        controller.th2File.toMap(),
      );
      final String originalAsFile = writer.serialize(controller.th2File);
      final MPCommand reorderCommand = MPCommandFactory.reorderImages(
        oldIndex: 0,
        newIndex: 1,
      );

      controller.execute(reorderCommand);

      expect(
        controller.th2File.imageMPIDs.map(
          (int mpID) => controller.th2File.imageByMPID(mpID).filename,
        ),
        <String>['croquis/croqui-007.jpg', 'croquis/croqui-006.jpg'],
      );
      expect(writer.serialize(controller.th2File), """encoding UTF-8
##XTHERION## xth_me_area_adjust -164 -2396 4206 1508
##XTHERION## xth_me_area_zoom_to 100
##XTHERION## xth_me_image_insert {-36 1 1} {28 {}} "croquis/croqui-007.jpg" 0 {}
##XTHERION## xth_me_image_insert {1890 1 1} {1380 {}} "croquis/croqui-006.jpg" 0 {}
""");

      controller.undo();

      expect(writer.serialize(controller.th2File), originalAsFile);
      expect(identical(controller.th2File, snapshotOriginal), isFalse);
      expect(controller.th2File == snapshotOriginal, isTrue);

      controller.redo();

      expect(
        controller.th2File.imageMPIDs.map(
          (int mpID) => controller.th2File.imageByMPID(mpID).filename,
        ),
        <String>['croquis/croqui-007.jpg', 'croquis/croqui-006.jpg'],
      );
    });
  });
}
