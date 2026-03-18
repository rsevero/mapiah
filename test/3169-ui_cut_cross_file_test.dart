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

  group('UI: cut from file A, paste into file B', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'cut point from file A, switch to file B, paste point, then undo twice restores both files to original state',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final TH2FileWriter writer = TH2FileWriter();

        /// Load two different files
        final String testFilename1 = THTestAux.testPath(
          '2025-10-07-002-point.th2',
        );
        final String testFilename2 = THTestAux.testPath(
          '2025-12-17-001-single_point.th2',
        );

        final TH2FileEditController th2Controller1 = mpLocator
            .mpGeneralController
            .getTH2FileEditController(filename: testFilename1);
        final TH2FileEditController th2Controller2 = mpLocator
            .mpGeneralController
            .getTH2FileEditController(filename: testFilename2);

        await tester.runAsync(() async {
          await th2Controller1.load();
          await th2Controller2.load();
        });

        final TH2FileEditSelectionController selectionController1 =
            th2Controller1.selectionController;
        final TH2File th2File1 = th2Controller1.th2File;
        final TH2File th2File2 = th2Controller2.th2File;

        final String originalSerialized1 = writer.serialize(th2File1);
        final String originalSerialized2 = writer.serialize(th2File2);

        final TH2File snapshotOriginal1 = TH2File.fromMap(th2File1.toMap());
        final TH2File snapshotOriginal2 = TH2File.fromMap(th2File2.toMap());

        th2Controller1.zoomOneToOne();
        th2Controller1.setActiveScrap(th2File1.getScraps().first.mpID);

        final List<THPoint> originalPointsFile1 = th2File1.getPoints().toList();
        expect(originalPointsFile1.length, 1);

        final THPoint pointFromFile1 = originalPointsFile1[0];
        final int originalPointMPIDFile1 = pointFromFile1.mpID;

        /// Step 1: Select and cut point from file 1
        selectionController1.setSelectedElements([pointFromFile1]);
        th2Controller1.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );
        th2Controller1.copyPasteController.cutSelectedElements();

        /// Verify point is removed from file 1
        final List<THPoint> pointsFile1AfterCut = th2File1.getPoints().toList();
        expect(pointsFile1AfterCut.length, 0);

        /// Verify clipboard has content
        expect(mpLocator.mpGeneralController.hasClipboardContent, isTrue);

        /// Step 2: Switch context to file 2 and paste
        th2Controller2.zoomOneToOne();
        th2Controller2.setActiveScrap(th2File2.getScraps().first.mpID);

        final int originalPointsInFile2 = th2File2.getPoints().length;

        th2Controller2.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
        th2Controller2.copyPasteController.pasteElements();

        /// Verify point was pasted into file 2
        final int pointsInFile2AfterPaste = th2File2.getPoints().length;
        expect(pointsInFile2AfterPaste, originalPointsInFile2 + 1);

        /// Verify file 1 still has 0 points (cut removed it)
        final List<THPoint> pointsFile1AfterPaste = th2File1
            .getPoints()
            .toList();
        expect(pointsFile1AfterPaste.length, 0);

        /// Step 3: Undo paste in file 2 (first undo)
        th2Controller2.undo();
        await tester.pumpAndSettle();

        final int pointsInFile2AfterUndoPaste = th2File2.getPoints().length;
        expect(pointsInFile2AfterUndoPaste, originalPointsInFile2);

        /// Verify file 1 still has 0 points
        final List<THPoint> pointsFile1AfterUndoPaste = th2File1
            .getPoints()
            .toList();
        expect(pointsFile1AfterUndoPaste.length, 0);

        /// Step 4: Undo cut in file 1 (second undo)
        th2Controller1.undo();
        await tester.pumpAndSettle();

        /// Verify point is restored to file 1
        final List<THPoint> pointsFile1AfterUndoCut = th2File1
            .getPoints()
            .toList();
        expect(pointsFile1AfterUndoCut.length, 1);

        final THPoint restoredPointFile1 = pointsFile1AfterUndoCut[0];
        expect(restoredPointFile1.mpID, originalPointMPIDFile1);
        expect(restoredPointFile1.pointType, pointFromFile1.pointType);

        /// Verify both files are back to original state
        final String undoneSerializedFile1 = writer.serialize(
          th2Controller1.th2File,
        );
        final String undoneSerializedFile2 = writer.serialize(
          th2Controller2.th2File,
        );

        expect(undoneSerializedFile1, originalSerialized1);
        expect(undoneSerializedFile2, originalSerialized2);

        expect(identical(th2Controller1.th2File, snapshotOriginal1), isFalse);
        expect(th2Controller1.th2File == snapshotOriginal1, isTrue);

        expect(identical(th2Controller2.th2File, snapshotOriginal2), isFalse);
        expect(th2Controller2.th2File == snapshotOriginal2, isTrue);
      },
    );
  });
}
