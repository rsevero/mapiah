// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'th_test_aux.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  final MPLocator mpLocator = MPLocator();

  group('TH2FileEditController dirty mirroring', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      mpLocator.thProjectController.closeProject();
    });

    tearDown(() {
      mpLocator.thProjectController.closeProject();
    });

    test(
      'gains the canonical path when enableSaveButton becomes true, and '
      'loses it when undone back to clean',
      () async {
        final String path = THTestAux.testPath('2025-10-05-001-line.th2');
        final String canonicalPath = THProjectPathResolver.canonicalize(
          p.absolute(path),
        );
        final TH2FileEditController controller = mpLocator
            .mpGeneralController
            .getTH2FileEditController(filename: path);

        await controller.load();

        expect(controller.enableSaveButton, isFalse);
        expect(
          mpLocator.thProjectController.dirtyFilePaths,
          isNot(contains(canonicalPath)),
        );

        controller.setActiveScrap(controller.th2File.getScraps().first.mpID);

        final THArea area = controller.areaLineCreationController.getNewArea();
        final MPCommand addAreaCommand = MPCommandFactory.addAreaFromExisting(
          existingArea: area,
          th2File: controller.th2File,
        );

        controller.execute(addAreaCommand);

        expect(controller.enableSaveButton, isTrue);
        expect(
          mpLocator.thProjectController.dirtyFilePaths,
          contains(canonicalPath),
        );

        controller.undo();

        expect(controller.enableSaveButton, isFalse);
        expect(
          mpLocator.thProjectController.dirtyFilePaths,
          isNot(contains(canonicalPath)),
        );
      },
    );

    test('never adds an entry for a new, unsaved file', () {
      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditControllerForNewFile(
            scrapTHID: 'scrap-new',
            scrapOptions: const [],
            encoding: mpDefaultEncoding,
          );

      expect(controller.enableSaveButton, isFalse);
      expect(mpLocator.thProjectController.dirtyFilePaths, isEmpty);
    });
  });
}
