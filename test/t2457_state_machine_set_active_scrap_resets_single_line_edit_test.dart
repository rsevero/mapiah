// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
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

  group('setActiveScrap resets single-line edit state', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    Future<TH2FileEditController> loadController() async {
      final TH2FileParser parser = TH2FileParser();
      final String path = THTestAux.testPath(
        '2026-03-18-002-two_scraps_with_point_line_area.th2',
      );
      final (_, isSuccessful, errors) = await parser.parse(
        path,
        forceNewController: true,
      );

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);

      controller.setActiveScrap(controller.th2File.getScraps().first.mpID);

      return controller;
    }

    test('switching scraps leaves the editor in empty-selection mode', () async {
      final TH2FileEditController controller = await loadController();
      final List<THScrap> scraps = controller.th2File.getScraps().toList();
      final THScrap firstScrap = scraps.first;
      final THScrap secondScrap = scraps[1];
      final THLine selectedLine = firstScrap.getLines(controller.th2File).first;
      final THLineSegment selectedLineSegment = selectedLine
          .getLineSegments(controller.th2File)
          .first;

      controller.selectionController.setSelectedElements(<THElement>[
        selectedLine,
      ]);
      controller.stateController.setState(
        MPTH2FileEditStateType.editSingleLine,
      );
      controller.selectionController.setSelectedEndPoints(<THLineSegment>[
        selectedLineSegment,
      ]);

      expect(
        controller.stateController.state.type,
        MPTH2FileEditStateType.editSingleLine,
      );
      expect(controller.selectionController.isSingleLineSelected(), isTrue);
      expect(
        controller.selectionController.selectedEndControlPoints.isNotEmpty,
        isTrue,
      );

      controller.setActiveScrap(secondScrap.mpID);

      expect(controller.activeScrapID, secondScrap.mpID);
      expect(
        controller.stateController.state.type,
        MPTH2FileEditStateType.selectEmptySelection,
      );
      expect(
        controller.selectionController.mpSelectedElementsLogical.isEmpty,
        isTrue,
      );
      expect(
        controller.selectionController.selectedEndControlPoints.isEmpty,
        isTrue,
      );
    });
  });
}
