// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  final MPLocator mpLocator = MPLocator();

  group('UI: interactive simplify line dialog', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    Future<TH2FileEditController> loadController(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final String testFilename =
          './test/auxiliary/2025-10-27-001-straight_line.th2';
      final TH2FileEditController th2Controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: testFilename);

      await tester.runAsync(() async {
        await th2Controller.load();
      });

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
      );
      await tester.pumpAndSettle();

      th2Controller.zoomOneToOne();

      final THLine line = th2Controller.th2File.getLines().first;

      th2Controller.selectionController.setSelectedElements(<THLine>[line]);
      th2Controller.stateController.setState(
        MPTH2FileEditStateType.editSingleLine,
      );
      await tester.pumpAndSettle();

      return th2Controller;
    }

    testWidgets('cancel restores the original line without adding undo', (
      WidgetTester tester,
    ) async {
      final AppLocalizationsEn appLocalizations = AppLocalizationsEn();
      final TH2FileEditController th2Controller = await loadController(tester);
      final int lineMPID = th2Controller.th2File.getLines().first.mpID;
      final int originalSegmentCount = th2Controller.th2File
          .lineByMPID(lineMPID)
          .getLineSegmentMPIDs(th2Controller.th2File)
          .length;

      await tester.tap(
        find.byTooltip(
          appLocalizations.th2FileEditPageInteractiveSimplifyLines,
        ),
      );
      await tester.pumpAndSettle();

      final int previewSegmentCount = th2Controller.th2File
          .lineByMPID(lineMPID)
          .getLineSegmentMPIDs(th2Controller.th2File)
          .length;

      expect(
        find.text(
          appLocalizations.th2FileEditPageInteractiveSimplifyLinesTitle,
        ),
        findsOneWidget,
      );
      expect(previewSegmentCount < originalSegmentCount, isTrue);
      expect(th2Controller.hasUndo, isTrue);

      await tester.tap(find.text(appLocalizations.mpButtonCancel));
      await tester.pumpAndSettle();

      final int finalSegmentCount = th2Controller.th2File
          .lineByMPID(lineMPID)
          .getLineSegmentMPIDs(th2Controller.th2File)
          .length;

      expect(
        find.text(
          appLocalizations.th2FileEditPageInteractiveSimplifyLinesTitle,
        ),
        findsNothing,
      );
      expect(finalSegmentCount, originalSegmentCount);
      expect(th2Controller.hasUndo, isFalse);
    });

    testWidgets('tapping outside closes like Close and keeps one undo step', (
      WidgetTester tester,
    ) async {
      final AppLocalizationsEn appLocalizations = AppLocalizationsEn();
      final TH2FileEditController th2Controller = await loadController(tester);
      final int lineMPID = th2Controller.th2File.getLines().first.mpID;
      final int originalSegmentCount = th2Controller.th2File
          .lineByMPID(lineMPID)
          .getLineSegmentMPIDs(th2Controller.th2File)
          .length;
      final String heroTag =
          '${th2Controller.th2FileMPID}_ctx_simplify_lines_interactive';

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyL);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyL);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      final Finder buttonFinder = find.byWidgetPredicate(
        (Widget widget) =>
            widget is FloatingActionButton && widget.heroTag == heroTag,
      );
      final FloatingActionButton activeButton = tester
          .widget<FloatingActionButton>(buttonFinder);
      final ColorScheme colorScheme = Theme.of(
        tester.element(buttonFinder),
      ).colorScheme;

      expect(
        find.text(
          appLocalizations.th2FileEditPageInteractiveSimplifyLinesTitle,
        ),
        findsOneWidget,
      );
      expect(activeButton.backgroundColor, colorScheme.primary);

      await tester.tapAt(const Offset(16, 16));
      await tester.pumpAndSettle();

      final int finalSegmentCount = th2Controller.th2File
          .lineByMPID(lineMPID)
          .getLineSegmentMPIDs(th2Controller.th2File)
          .length;

      expect(
        find.text(
          appLocalizations.th2FileEditPageInteractiveSimplifyLinesTitle,
        ),
        findsNothing,
      );
      expect(finalSegmentCount < originalSegmentCount, isTrue);
      expect(th2Controller.hasUndo, isTrue);

      th2Controller.undo();

      final int undoneSegmentCount = th2Controller.th2File
          .lineByMPID(lineMPID)
          .getLineSegmentMPIDs(th2Controller.th2File)
          .length;

      expect(undoneSegmentCount, originalSegmentCount);
    });
  });
}
