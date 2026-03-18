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
    'UI: copy/paste multiple elements (point, line, area) across scraps using Ctrl+C / Ctrl+V',
    () {
      setUp(() {
        mpLocator.appLocalizations = AppLocalizationsEn();
        mpLocator.mpGeneralController.reset();
      });

      testWidgets(
        'copy multiple elements from one scrap, paste into another scrap',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(1280, 720);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final TH2FileWriter writer = TH2FileWriter();
          final String testFilename = THTestAux.testPath(
            '2026-03-18-002-two_scraps_with_point_line_area.th2',
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

          final List<THScrap> scraps = th2File.getScraps().toList();

          /// Verify test file has required structure
          expect(
            scraps.length >= 2,
            isTrue,
            reason: 'Test file must contain at least two scraps',
          );

          final THScrap firstScrap = scraps[0];
          final THScrap secondScrap = scraps[1];

          th2Controller.setActiveScrap(firstScrap.mpID);

          final Iterable<THElement> firstScrapChildren = firstScrap.getChildren(
            th2File,
          );
          final List<THPoint> firstScrapPoints = firstScrapChildren
              .whereType<THPoint>()
              .toList();
          final List<THLine> firstScrapLines = firstScrapChildren
              .whereType<THLine>()
              .toList();
          final List<THArea> firstScrapAreas = firstScrapChildren
              .whereType<THArea>()
              .toList();

          /// Ensure first scrap has required elements
          expect(
            firstScrapPoints.isNotEmpty,
            isTrue,
            reason: 'First scrap must contain at least one point',
          );
          expect(
            firstScrapLines.length >= 2,
            isTrue,
            reason:
                'First scrap must contain at least two lines (border + contour)',
          );
          expect(
            firstScrapAreas.isNotEmpty,
            isTrue,
            reason: 'First scrap must contain at least one area',
          );

          final THPoint pointToCopy = firstScrapPoints[0];
          final THLine lineToCopy =
              firstScrapLines[1]; // blaus line, not border line
          final THArea areaToCopy = firstScrapAreas[0];

          final int originalPointsInSecondScrap = secondScrap
              .getChildren(th2File)
              .whereType<THPoint>()
              .length;
          final int originalLinesInSecondScrap = secondScrap
              .getChildren(th2File)
              .whereType<THLine>()
              .length;
          final int originalAreasInSecondScrap = secondScrap
              .getChildren(th2File)
              .whereType<THArea>()
              .length;

          /// Select and copy multiple elements from first scrap
          selectionController.setSelectedElements([
            pointToCopy,
            lineToCopy,
            areaToCopy,
          ]);
          th2Controller.stateController.setState(
            MPTH2FileEditStateType.selectNonEmptySelection,
          );
          th2Controller.elementEditController.copySelectedElements();

          /// Switch to second scrap and paste
          th2Controller.setActiveScrap(secondScrap.mpID);
          th2Controller.stateController.setState(
            MPTH2FileEditStateType.selectEmptySelection,
          );
          th2Controller.elementEditController.pasteElements();

          /// Verify elements were pasted into second scrap
          final int pointsInSecondScrapAfterPaste = secondScrap
              .getChildren(th2File)
              .whereType<THPoint>()
              .length;
          final int linesInSecondScrapAfterPaste = secondScrap
              .getChildren(th2File)
              .whereType<THLine>()
              .length;
          final int areasInSecondScrapAfterPaste = secondScrap
              .getChildren(th2File)
              .whereType<THArea>()
              .length;

          expect(
            pointsInSecondScrapAfterPaste,
            originalPointsInSecondScrap + 1,
          );
          expect(linesInSecondScrapAfterPaste, originalLinesInSecondScrap + 2);
          expect(areasInSecondScrapAfterPaste, originalAreasInSecondScrap + 1);

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
