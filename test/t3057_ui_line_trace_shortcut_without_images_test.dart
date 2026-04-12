// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'th2_file_tabs_page_test_aux.dart';

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

  group('UI: line trace shortcut without images', () {
    setUp(() async {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      await mpLocator.mpSettingsController.initialized;
    });

    testWidgets('Ctrl+Shift+T does not start tracing when no images exist', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final TH2FileEditController th2Controller = mpLocator.mpGeneralController
          .getTH2FileEditControllerForNewFile(
            scrapTHID: 'scrap-1',
            scrapOptions: const [],
            encoding: 'utf-8',
          );

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
      );
      await tester.pumpAndSettle();

      th2Controller.stateController.setState(MPTH2FileEditStateType.addLine);
      await tester.pumpAndSettle();

      expect(th2Controller.lineTraceController.hasAnyImage, isFalse);
      expect(th2Controller.lineTraceController.isTracing, isFalse);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyT);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyT);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(th2Controller.lineTraceController.isTracing, isFalse);
    });
  });
}
