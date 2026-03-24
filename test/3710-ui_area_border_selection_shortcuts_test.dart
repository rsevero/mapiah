// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'th2_file_tabs_page_test_aux.dart';
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

  group('UI: area border selection shortcuts', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets('Ctrl-click cycles multi-line area border selection', (
      WidgetTester tester,
    ) async {
      await _configureTestSurface(tester);

      final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
          await _pumpExistingEditor(
            tester,
            mpLocator,
            filename: '2025-10-14-001-area_with_2_lines.th2',
          );
      final TH2FileEditSelectionController selectionController =
          editor.th2Controller.selectionController;
      final THArea area = editor.th2File.getAreas().first;
      final List<int> areaLineMPIDs = area.getLineMPIDs(editor.th2File);
      final THLine clickedLine = editor.th2File.lineByMPID(areaLineMPIDs.last);
      final Offset clickPosition = _getLineClickPosition(
        line: clickedLine,
        th2File: editor.th2File,
        th2Controller: editor.th2Controller,
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      final Map<int, THElement> firstClick = Map<int, THElement>.from(
        selectionController.getSelectableElementsClickedWithoutDialog(
          screenCoordinates: clickPosition,
          selectionType: THSelectionType.pla,
        ),
      );
      final Map<int, THElement> secondClick = Map<int, THElement>.from(
        selectionController.getSelectableElementsClickedWithoutDialog(
          screenCoordinates: clickPosition,
          selectionType: THSelectionType.pla,
        ),
      );
      final Map<int, THElement> thirdClick = Map<int, THElement>.from(
        selectionController.getSelectableElementsClickedWithoutDialog(
          screenCoordinates: clickPosition,
          selectionType: THSelectionType.pla,
        ),
      );
      final Map<int, THElement> fourthClick = Map<int, THElement>.from(
        selectionController.getSelectableElementsClickedWithoutDialog(
          screenCoordinates: clickPosition,
          selectionType: THSelectionType.pla,
        ),
      );

      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(firstClick.keys.toSet(), equals(areaLineMPIDs.toSet()));
      expect(firstClick.containsKey(area.mpID), isFalse);
      expect(secondClick.keys, orderedEquals(<int>[areaLineMPIDs.first]));
      expect(thirdClick.keys, orderedEquals(<int>[areaLineMPIDs.last]));
      expect(fourthClick.keys.toSet(), equals(areaLineMPIDs.toSet()));
    });

    testWidgets('Ctrl+Alt-click on area-border line selects area only', (
      WidgetTester tester,
    ) async {
      await _configureTestSurface(tester);

      final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
          await _pumpExistingEditor(
            tester,
            mpLocator,
            filename: '2025-10-14-001-area_with_2_lines.th2',
          );
      final TH2FileEditSelectionController selectionController =
          editor.th2Controller.selectionController;
      final THArea area = editor.th2File.getAreas().first;
      final THLine clickedLine = editor.th2File.lineByMPID(
        area.getLineMPIDs(editor.th2File).first,
      );
      final Offset clickPosition = _getLineClickPosition(
        line: clickedLine,
        th2File: editor.th2File,
        th2Controller: editor.th2Controller,
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();

      final Map<int, THElement> clickedElements = Map<int, THElement>.from(
        selectionController.getSelectableElementsClickedWithoutDialog(
          screenCoordinates: clickPosition,
          selectionType: THSelectionType.pla,
        ),
      );

      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(clickedElements.keys, orderedEquals(<int>[area.mpID]));
    });

    testWidgets(
      'Ctrl+Shift-click on area-border line is not area-only selection',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);

        final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
            await _pumpExistingEditor(
              tester,
              mpLocator,
              filename: '2025-10-14-001-area_with_2_lines.th2',
            );
        final TH2FileEditSelectionController selectionController =
            editor.th2Controller.selectionController;
        final THArea area = editor.th2File.getAreas().first;
        final THLine clickedLine = editor.th2File.lineByMPID(
          area.getLineMPIDs(editor.th2File).first,
        );
        final Offset clickPosition = _getLineClickPosition(
          line: clickedLine,
          th2File: editor.th2File,
          th2Controller: editor.th2Controller,
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();

        final Map<int, THElement> clickedElements = Map<int, THElement>.from(
          selectionController.getSelectableElementsClickedWithoutDialog(
            screenCoordinates: clickPosition,
            selectionType: THSelectionType.pla,
          ),
        );

        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pump();

        expect(clickedElements.containsKey(area.mpID), isTrue);
        expect(clickedElements.containsKey(clickedLine.mpID), isTrue);
        expect(clickedElements.keys.length, greaterThan(1));
      },
    );

    testWidgets(
      'Meta+Shift-click on area-border line is not area-only selection',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);

        final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
            await _pumpExistingEditor(
              tester,
              mpLocator,
              filename: '2025-10-14-001-area_with_2_lines.th2',
            );
        final TH2FileEditSelectionController selectionController =
            editor.th2Controller.selectionController;
        final THArea area = editor.th2File.getAreas().first;
        final THLine clickedLine = editor.th2File.lineByMPID(
          area.getLineMPIDs(editor.th2File).first,
        );
        final Offset clickPosition = _getLineClickPosition(
          line: clickedLine,
          th2File: editor.th2File,
          th2Controller: editor.th2Controller,
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();

        final Map<int, THElement> clickedElements = Map<int, THElement>.from(
          selectionController.getSelectableElementsClickedWithoutDialog(
            screenCoordinates: clickPosition,
            selectionType: THSelectionType.pla,
          ),
        );

        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();

        expect(clickedElements.containsKey(area.mpID), isTrue);
        expect(clickedElements.containsKey(clickedLine.mpID), isTrue);
        expect(clickedElements.keys.length, greaterThan(1));
      },
    );
  });
}

Future<void> _configureTestSurface(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 720);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Future<({TH2File th2File, TH2FileEditController th2Controller})>
_pumpExistingEditor(
  WidgetTester tester,
  MPLocator mpLocator, {
  required String filename,
}) async {
  final TH2FileEditController th2Controller = mpLocator.mpGeneralController
      .getTH2FileEditController(filename: THTestAux.testPath(filename));

  await tester.runAsync(() async {
    await th2Controller.load();
  });

  final TH2File th2File = th2Controller.th2File;

  await tester.pumpWidget(
    buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
  );
  await tester.pumpAndSettle();

  th2Controller.zoomOneToOne();
  th2Controller.setActiveScrap(th2File.getScraps().first.mpID);
  await tester.pumpAndSettle();

  return (th2File: th2File, th2Controller: th2Controller);
}

Offset _getLineClickPosition({
  required THLine line,
  required TH2File th2File,
  required TH2FileEditController th2Controller,
}) {
  final List<THLineSegment> lineSegments = line.getLineSegments(th2File);
  final THLineSegment firstLineSegment = lineSegments.first;
  final Offset canvasPosition = firstLineSegment.endPoint.coordinates;

  return th2Controller.offsetCanvasToScreen(canvasPosition);
}
