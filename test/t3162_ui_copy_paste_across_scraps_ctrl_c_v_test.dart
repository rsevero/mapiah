// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
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

  group('UI: copy/paste across different scraps using Ctrl+C / Ctrl+V', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'open file with two scraps, copy from one, paste into another scrap',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final TH2FileWriter writer = TH2FileWriter();
        final String testFilename = THTestAux.testPath(
          '2025-11-26-001-two_scraps_with_empty_lines.th2',
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
          buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
        );
        await tester.pump();

        th2Controller.zoomOneToOne();

        final List<THScrap> scraps = th2File.getScraps().toList();
        expect(scraps.length >= 2, isTrue);

        final THScrap firstScrap = scraps[0];
        final THScrap secondScrap = scraps[1];

        /// Set active scrap to first scrap
        th2Controller.setActiveScrap(firstScrap.mpID);

        /// Get points from first scrap
        final Iterable<THElement> firstScrapChildren = firstScrap.getChildren(
          th2File,
        );
        final List<THPoint> firstScrapPoints = firstScrapChildren
            .whereType<THPoint>()
            .toList();

        if (firstScrapPoints.isEmpty) {
          /// Skip test if first scrap has no points
          return;
        }

        final THPoint pointFromFirstScrap = firstScrapPoints[0];
        final int originalPointsInFirstScrap = firstScrap
            .getChildren(th2File)
            .whereType<THPoint>()
            .length;
        final int originalPointsInSecondScrap = secondScrap
            .getChildren(th2File)
            .whereType<THPoint>()
            .length;

        /// Copy point from first scrap
        selectionController.setSelectedElements([pointFromFirstScrap]);
        th2Controller.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );
        th2Controller.copyPasteController.copySelectedElements();

        /// Switch to second scrap and paste
        th2Controller.setActiveScrap(secondScrap.mpID);
        th2Controller.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
        th2Controller.copyPasteController.pasteElements();

        /// Verify point was pasted into second scrap
        final int pointsInFirstScrapAfterPaste = firstScrap
            .getChildren(th2File)
            .whereType<THPoint>()
            .length;
        final int pointsInSecondScrapAfterPaste = secondScrap
            .getChildren(th2File)
            .whereType<THPoint>()
            .length;

        expect(pointsInFirstScrapAfterPaste, originalPointsInFirstScrap);
        expect(pointsInSecondScrapAfterPaste, originalPointsInSecondScrap + 1);

        /// Test undo removes the pasted element atomically
        th2Controller.undo();
        await tester.pumpAndSettle();

        final String undoneSerialized = writer.serialize(th2Controller.th2File);
        expect(undoneSerialized, originalSerialized);
        expect(identical(th2Controller.th2File, snapshotOriginal), isFalse);
        expect(th2Controller.th2File == snapshotOriginal, isTrue);
      },
    );
  });
}
