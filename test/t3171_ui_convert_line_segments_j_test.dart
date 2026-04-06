// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/services.dart';
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

final MPLocator mpLocator = MPLocator();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();
  group('UI: convert line segments through J shortcuts', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets('J converts selected non-start line segments to Bézier', (
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
      await tester.pump();

      final THLine line = controller.th2File.getLines().first;
      final List<THLineSegment> lineSegments = line.getLineSegments(
        controller.th2File,
      );

      controller.selectionController.setSelectedElements(<THElement>[line]);
      controller.stateController.setState(
        MPTH2FileEditStateType.editSingleLine,
      );
      controller.selectionController.setSelectedEndPointsByMPID(<int>[
        lineSegments[1].mpID,
      ]);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyJ);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyJ);
      await tester.pump();

      final THLineSegment changedLineSegment = controller.th2File
          .getLines()
          .first
          .getLineSegments(controller.th2File)[1];

      expect(changedLineSegment, isA<THBezierCurveLineSegment>());
      expect(controller.hasUndo, isTrue);

      controller.undo();

      final THLineSegment undoneLineSegment = controller.th2File
          .getLines()
          .first
          .getLineSegments(controller.th2File)[1];

      expect(undoneLineSegment, isA<THStraightLineSegment>());
    });

    testWidgets(
      'Shift+J converts selected non-start line segments to straight',
      (tester) async {
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
        await tester.pump();

        final THLine line = controller.th2File.getLines().first;
        final List<THLineSegment> lineSegments = line.getLineSegments(
          controller.th2File,
        );

        controller.selectionController.setSelectedElements(<THElement>[line]);
        controller.stateController.setState(
          MPTH2FileEditStateType.editSingleLine,
        );
        controller.selectionController.setSelectedEndPointsByMPID(<int>[
          lineSegments[1].mpID,
        ]);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyJ);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyJ);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();

        final THLineSegment changedLineSegment = controller.th2File
            .getLines()
            .first
            .getLineSegments(controller.th2File)[1];

        expect(changedLineSegment, isA<THStraightLineSegment>());
        expect(controller.hasUndo, isTrue);

        controller.undo();

        final THLineSegment undoneLineSegment = controller.th2File
            .getLines()
            .first
            .getLineSegments(controller.th2File)[1];

        expect(undoneLineSegment, isA<THBezierCurveLineSegment>());
      },
    );

    testWidgets('J does nothing when only the start point is selected', (
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
      await tester.pump();

      final THLine line = controller.th2File.getLines().first;
      final List<THLineSegment> lineSegments = line.getLineSegments(
        controller.th2File,
      );

      controller.selectionController.setSelectedElements(<THElement>[line]);
      controller.stateController.setState(
        MPTH2FileEditStateType.editSingleLine,
      );
      controller.selectionController.setSelectedEndPointsByMPID(<int>[
        lineSegments.first.mpID,
      ]);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyJ);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyJ);
      await tester.pump();

      final THLineSegment unchangedLineSegment = controller.th2File
          .getLines()
          .first
          .getLineSegments(controller.th2File)
          .first;

      expect(unchangedLineSegment, isA<THStraightLineSegment>());
      expect(controller.hasUndo, isFalse);
    });
  });
}
