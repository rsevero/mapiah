// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
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

  group('UI: line double click enters single-line edit mode', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets('double-clicking a line enters single-line edit mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(
            filename: './test/auxiliary/2025-10-27-001-straight_line.th2',
          );

      await tester.runAsync(() async {
        await controller.load();
      });

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: controller),
      );
      await tester.pumpAndSettle();

      final THLine line = controller.th2File.getLines().first;
      final List<THLineSegment> lineSegments = line.getLineSegments(
        controller.th2File,
      );
      final Offset firstPoint = lineSegments[0].endPoint.coordinates;
      final Offset secondPoint = lineSegments[1].endPoint.coordinates;
      final Offset segmentMidpoint = Offset(
        (firstPoint.dx + secondPoint.dx) / 2.0,
        (firstPoint.dy + secondPoint.dy) / 2.0,
      );
      final Offset screenOffset = controller.offsetCanvasToScreen(
        segmentMidpoint,
      );
      final Finder listenerFinder = find.byKey(
        ValueKey('MPListenerWidget|${controller.th2FileMPID}'),
      );

      await tester.tapAt(tester.getTopLeft(listenerFinder) + screenOffset);
      await tester.pump(const Duration(milliseconds: 20));
      await tester.tapAt(tester.getTopLeft(listenerFinder) + screenOffset);
      await tester.pumpAndSettle();

      expect(
        controller.stateController.state.type,
        MPTH2FileEditStateType.editSingleLine,
      );
      expect(
        controller.selectionController.mpSelectedElementsLogical.length,
        1,
      );
      expect(controller.selectionController.getSelectedLine().mpID, line.mpID);
      expect(
        find.byKey(ValueKey('MPEditLineWidget|${controller.th2FileMPID}')),
        findsOneWidget,
      );
    });

    testWidgets('double-clicking a line segment enters single-line edit mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(
            filename: './test/auxiliary/2025-10-27-002-bezier_line.th2',
          );

      await tester.runAsync(() async {
        await controller.load();
      });

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: controller),
      );
      await tester.pumpAndSettle();

      final THLine line = controller.th2File.getLines().first;
      final List<THLineSegment> lineSegments = line.getLineSegments(
        controller.th2File,
      );
      final THLineSegment clickedSegment = lineSegments[1];
      final THLineSegment previousSegment = lineSegments[0];
      final Offset firstPoint = previousSegment.endPoint.coordinates;
      final Offset secondPoint = clickedSegment.endPoint.coordinates;
      final Offset segmentMidpoint = Offset(
        (firstPoint.dx + secondPoint.dx) / 2.0,
        (firstPoint.dy + secondPoint.dy) / 2.0,
      );
      final Offset screenOffset = controller.offsetCanvasToScreen(
        segmentMidpoint,
      );
      final Finder listenerFinder = find.byKey(
        ValueKey('MPListenerWidget|${controller.th2FileMPID}'),
      );

      await tester.tapAt(tester.getTopLeft(listenerFinder) + screenOffset);
      await tester.pump(const Duration(milliseconds: 20));
      await tester.tapAt(tester.getTopLeft(listenerFinder) + screenOffset);
      await tester.pumpAndSettle();

      expect(
        controller.stateController.state.type,
        MPTH2FileEditStateType.editSingleLine,
      );
      expect(controller.selectionController.getSelectedLine().mpID, line.mpID);
      expect(
        find.byKey(ValueKey('MPEditLineWidget|${controller.th2FileMPID}')),
        findsOneWidget,
      );
    });
  });
}
