// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
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

  group('Alt+click change scrap', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      MPInteractionAux.debugPressedKeysOverride = null;
    });

    tearDown(() {
      MPInteractionAux.debugPressedKeysOverride = null;
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

    test(
      'Alt+click on second scrap switches active scrap when file has two scraps',
      () async {
        final TH2FileEditController controller = await loadController();
        final List<THScrap> scraps = controller.th2File.getScraps().toList();
        final THScrap firstScrap = scraps.first;
        final THScrap secondScrap = scraps[1];
        final Rect secondScrapBoundingBox =
            MPInteractionAux.getScrapBackgroundRect(
              scrap: secondScrap,
              th2FileEditController: controller,
            );

        expect(controller.activeScrapID, firstScrap.mpID);

        controller.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
        MPInteractionAux.debugPressedKeysOverride = <LogicalKeyboardKey>{
          LogicalKeyboardKey.altLeft,
        };

        await controller.stateController.onPrimaryButtonClick(
          PointerUpEvent(
            position: controller.offsetCanvasToScreen(
              secondScrapBoundingBox.center,
            ),
          ),
        );

        expect(controller.activeScrapID, secondScrap.mpID);
        expect(
          controller.stateController.state.type,
          MPTH2FileEditStateType.selectEmptySelection,
        );
      },
    );
  });
}
