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

  group('UI: cut in same scrap using Ctrl+X', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'select point, cut (Ctrl+X), element disappears, paste (Ctrl+V), element reappears, then undo twice restores original state',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final TH2FileWriter writer = TH2FileWriter();
        final String testFilename = THTestAux.testPath(
          '2025-10-07-002-point.th2',
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

        final List<THPoint> originalPoints = th2File.getPoints().toList();
        expect(originalPoints.length, 1);

        final THPoint originalPoint = originalPoints[0];

        /// Step 1: Select and cut the point using Ctrl+X
        selectionController.setSelectedElements([originalPoint]);
        th2Controller.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );
        th2Controller.copyPasteController.cutSelectedElements();

        /// Verify point disappears after cut
        final List<THPoint> pointsAfterCut = th2File.getPoints().toList();
        expect(pointsAfterCut.length, 0);

        /// Verify clipboard has content after cut
        expect(mpLocator.mpGeneralController.hasClipboardContent, isTrue);

        /// Step 2: Paste the point using Ctrl+V
        th2Controller.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
        th2Controller.copyPasteController.pasteElements();

        /// Verify point reappears after paste
        final List<THPoint> pointsAfterPaste = th2File.getPoints().toList();
        expect(pointsAfterPaste.length, 1);

        final THPoint pastedPoint = pointsAfterPaste[0];
        expect(pastedPoint.mpID == originalPoint.mpID, isFalse);
        expect(pastedPoint.pointType, originalPoint.pointType);

        /// Step 3: Undo paste operation
        th2Controller.undo();
        await tester.pumpAndSettle();

        final List<THPoint> pointsAfterUndoPaste = th2File.getPoints().toList();
        expect(pointsAfterUndoPaste.length, 0);

        /// Verify clipboard still has content after undo
        expect(mpLocator.mpGeneralController.hasClipboardContent, isTrue);

        /// Step 4: Undo cut operation (second undo)
        th2Controller.undo();
        await tester.pumpAndSettle();

        final List<THPoint> pointsAfterUndoCut = th2File.getPoints().toList();
        expect(pointsAfterUndoCut.length, 1);

        /// Verify state is back to original
        final String undoneSerializedAfterSecondUndo = writer.serialize(
          th2Controller.th2File,
        );
        expect(undoneSerializedAfterSecondUndo, originalSerialized);
        expect(identical(th2Controller.th2File, snapshotOriginal), isFalse);
        expect(th2Controller.th2File == snapshotOriginal, isTrue);
      },
    );
  });
}
