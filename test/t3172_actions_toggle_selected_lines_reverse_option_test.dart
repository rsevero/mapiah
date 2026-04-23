// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
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

  group('actions: toggle selected lines reverse option', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test(
      'undo followed by toggling again uses live line state instead of stale selection clone',
      () async {
        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditController(
              filename: THTestAux.testPath('2025-10-05-001-line.th2'),
            );
        await controller.load();

        final TH2FileWriter writer = TH2FileWriter();
        final String serializedBefore = writer.serialize(controller.th2File);
        final THLine line = controller.th2File.getLines().first;

        controller.selectionController.setSelectedElements(<THElement>[line]);
        controller.elementEditController.toggleSelectedLinesReverseOption();

        final THLine reversedLine = controller.th2File.getLines().first;
        expect(MPCommandOptionAux.isReversed(reversedLine), isTrue);

        final THElement staleSelectedLine = controller
            .selectionController
            .getSelectedLine();

        controller.undo();

        final THLine restoredLine = controller.th2File.getLines().first;
        expect(MPCommandOptionAux.isReversed(restoredLine), isFalse);
        expect(writer.serialize(controller.th2File), serializedBefore);

        controller.selectionController.setSelectedElements(<THElement>[
          staleSelectedLine,
        ]);

        expect(
          controller.elementEditController.toggleSelectedLinesReverseOption,
          returnsNormally,
        );

        final THLine toggledAgainLine = controller.th2File.getLines().first;
        expect(MPCommandOptionAux.isReversed(toggledAgainLine), isTrue);
      },
    );
  });
}
