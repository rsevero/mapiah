// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
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

  group('UI: image flip buttons', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets('shows image flip buttons and flips the active image', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final String testFilename =
          './test/auxiliary/2026-04-08-001-scrap_with_image.th2';
      final TH2FileEditController th2Controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: testFilename);

      await tester.runAsync(() async {
        await th2Controller.load();
      });

      final int imageMPID = th2Controller.th2File.imageMPIDs.first;
      final MPRuntimeImageInsertConfigMixin originalImage = th2Controller
          .th2File
          .imageByMPID(imageMPID);
      final Rect originalBoundingBox = originalImage.getBoundingBox(
        th2Controller,
      )!;

      th2Controller.moveScaleRotateElementController.prepareImageMoveState(
        imageMPID,
      );

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Flip image horizontally (H)'), findsOneWidget);
      expect(find.byTooltip('Flip image vertically (V)'), findsOneWidget);

      await tester.tap(find.byTooltip('Flip image horizontally (H)'));
      await tester.pumpAndSettle();

      final MPImageInsertConfig flippedHorizontally =
          th2Controller.th2File.imageByMPID(imageMPID) as MPImageInsertConfig;

      expect(flippedHorizontally.xScale.value, closeTo(-1.0, 0.0001));
      expect(flippedHorizontally.yScale.value, closeTo(1.0, 0.0001));
      expect(
        flippedHorizontally.getBoundingBox(th2Controller)!.center.dx,
        closeTo(originalBoundingBox.center.dx, 0.0001),
      );
      expect(
        flippedHorizontally.getBoundingBox(th2Controller)!.center.dy,
        closeTo(originalBoundingBox.center.dy, 0.0001),
      );

      await tester.tap(find.byTooltip('Flip image vertically (V)'));
      await tester.pumpAndSettle();

      final MPImageInsertConfig flippedBothAxes =
          th2Controller.th2File.imageByMPID(imageMPID) as MPImageInsertConfig;

      expect(flippedBothAxes.xScale.value, closeTo(-1.0, 0.0001));
      expect(flippedBothAxes.yScale.value, closeTo(-1.0, 0.0001));
      expect(
        flippedBothAxes.getBoundingBox(th2Controller)!.center.dx,
        closeTo(originalBoundingBox.center.dx, 0.0001),
      );
      expect(
        flippedBothAxes.getBoundingBox(th2Controller)!.center.dy,
        closeTo(originalBoundingBox.center.dy, 0.0001),
      );
    });
  });
}
