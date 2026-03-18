// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
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

  group(
    'UI: copy/paste multiple elements (point, line, area) in same scrap using Ctrl+C / Ctrl+V',
    () {
      setUp(() {
        mpLocator.appLocalizations = AppLocalizationsEn();
        mpLocator.mpGeneralController.reset();
      });

      testWidgets(
        'copy point, line, and area (with border line) and paste in same scrap',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(1280, 720);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final TH2FileWriter writer = TH2FileWriter();
          final String testFilename = THTestAux.testPath(
            '2026-03-18-001-area_lines_point.th2',
          );
          final TH2FileEditController th2Controller = mpLocator
              .mpGeneralController
              .getTH2FileEditController(filename: testFilename);

          await tester.runAsync(() async {
            await th2Controller.load();
          });

          final TH2FileEditSelectionController selectionController =
              th2Controller.selectionController;
          final TH2File th2File = th2Controller.th2File;
          final String originalSerialized = writer.serialize(th2File);
          final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              home: TH2FileEditPage(
                filename: testFilename,
                th2FileEditController: th2Controller,
              ),
            ),
          );
          await tester.pump();

          th2Controller.zoomOneToOne();
          th2Controller.setActiveScrap(th2File.getScraps().first.mpID);

          final List<THPoint> points = th2File.getPoints().toList();
          final List<THLine> lines = th2File.getLines().toList();
          final List<THArea> areas = th2File.getAreas().toList();

          /// Verify test file has required elements
          expect(
            points.isNotEmpty,
            isTrue,
            reason: 'Test file must contain at least one point',
          );
          expect(
            lines.length >= 2,
            isTrue,
            reason:
                'Test file must contain at least two lines (border + contour)',
          );
          expect(
            areas.isNotEmpty,
            isTrue,
            reason: 'Test file must contain at least one area',
          );

          final THPoint pointToCopy = points[0];
          final THLine lineToCopy = lines[1]; // blaus line, not border line
          final THArea areaToCopy = areas[0];

          final int originalPointsCount = points.length;
          final int originalLinesCount = lines.length;
          final int originalAreasCount = areas.length;

          /// Select point, line, and area (area's border line is implicitly included)
          selectionController.setSelectedElements([
            pointToCopy,
            lineToCopy,
            areaToCopy,
          ]);
          th2Controller.stateController.setState(
            MPTH2FileEditStateType.selectNonEmptySelection,
          );

          /// Copy all selected elements
          th2Controller.elementEditController.copySelectedElements();

          /// Verify clipboard has content
          expect(mpLocator.mpGeneralController.hasClipboardContent, isTrue);

          /// Switch to empty selection and paste
          th2Controller.stateController.setState(
            MPTH2FileEditStateType.selectEmptySelection,
          );
          th2Controller.elementEditController.pasteElements();

          /// Verify all elements were pasted
          final List<THPoint> pointsAfterPaste = th2File.getPoints().toList();
          final List<THLine> linesAfterPaste = th2File.getLines().toList();
          final List<THArea> areasAfterPaste = th2File.getAreas().toList();

          expect(pointsAfterPaste.length, originalPointsCount + 1);
          expect(linesAfterPaste.length, originalLinesCount + 2);
          expect(areasAfterPaste.length, originalAreasCount + 1);

          /// Verify pasted elements have new MPIDs
          final Set<int> originalMPIDs = {
            pointToCopy.mpID,
            lineToCopy.mpID,
            areaToCopy.mpID,
          };
          final THPoint pastedPoint = pointsAfterPaste.firstWhere(
            (p) => !originalMPIDs.contains(p.mpID),
          );
          final THArea pastedArea = areasAfterPaste.firstWhere(
            (a) => !originalMPIDs.contains(a.mpID),
          );

          expect(pastedPoint.mpID != pointToCopy.mpID, isTrue);
          expect(pastedPoint.pointType, pointToCopy.pointType);
          expect(pastedArea.mpID != areaToCopy.mpID, isTrue);
          expect(pastedArea.areaType, areaToCopy.areaType);

          /// Test undo removes all pasted elements atomically
          th2Controller.undo();
          await tester.pumpAndSettle();

          final String undoneSerialized = writer.serialize(
            th2Controller.th2File,
          );
          expect(undoneSerialized, originalSerialized);
          expect(identical(th2Controller.th2File, snapshotOriginal), isFalse);
          expect(th2Controller.th2File == snapshotOriginal, isTrue);
        },
      );
    },
  );
}
