// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
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

  group('UI: change scrap overlay action buttons', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'hides snap and remove buttons while available scraps widget is open',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final String testFilename = './test/auxiliary/2025-10-06-002-scrap.th2';
        final TH2FileEditController th2Controller = mpLocator
            .mpGeneralController
            .getTH2FileEditController(filename: testFilename);

        await tester.runAsync(() async {
          await th2Controller.load();
        });

        await tester.pumpWidget(
          buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
        );
        await tester.pumpAndSettle();

        expect(find.byTooltip('Snap'), findsOneWidget);
        expect(find.byTooltip('Remove (Del)'), findsOneWidget);

        final Key changeScrapButtonKey = th2Controller
            .overlayWindowController
            .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType.changeScrapButton]!;

        final FloatingActionButton changeScrapButton = tester
            .widget<FloatingActionButton>(find.byKey(changeScrapButtonKey));

        changeScrapButton.onPressed!();
        await tester.pumpAndSettle();

        expect(find.byTooltip('Snap'), findsNothing);
        expect(find.byTooltip('Remove (Del)'), findsNothing);
      },
    );
  });
}
