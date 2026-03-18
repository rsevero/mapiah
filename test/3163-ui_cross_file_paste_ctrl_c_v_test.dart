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

  group('UI: cross-file paste using Ctrl+C in file A, Ctrl+V in file B', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'copy point from file A, switch to file B tab, paste point into file B',
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

        final TH2File snapshotOriginal2 = TH2File.fromMap(th2File2.toMap());

        /// For this test, we'll manually test the clipboard functionality
        /// since we're not testing the full UI navigation between tabs

        th2Controller1.zoomOneToOne();
        th2Controller1.setActiveScrap(th2File1.getScraps().first.mpID);

        final List<THPoint> originalPointsFile1 = th2File1.getPoints().toList();
        expect(originalPointsFile1.length, 1);

        final THPoint pointFromFile1 = originalPointsFile1[0];

        /// Copy point from file 1
        selectionController1.setSelectedElements([pointFromFile1]);
        th2Controller1.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );
        th2Controller1.elementEditController.copySelectedElements();

        /// Verify clipboard has content
        expect(mpLocator.mpGeneralController.hasClipboardContent, isTrue);

        th2Controller2.zoomOneToOne();
        th2Controller2.setActiveScrap(th2File2.getScraps().first.mpID);

        final int originalPointsInFile2 = th2File2.getPoints().length;

        /// Paste point into file 2
        th2Controller2.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
        th2Controller2.elementEditController.pasteElements();

        /// Verify point was pasted into file 2
        final int pointsInFile2AfterPaste = th2File2.getPoints().length;
        expect(pointsInFile2AfterPaste, originalPointsInFile2 + 1);

        /// Verify file 1 was not modified
        final String serialized1AfterPaste = writer.serialize(th2File1);
        expect(serialized1AfterPaste, originalSerialized1);

        /// Test undo in file 2
        th2Controller2.undo();
        await tester.pumpAndSettle();

        final String undoneSerializedFile2 = writer.serialize(
          th2Controller2.th2File,
        );
        expect(undoneSerializedFile2, originalSerialized2);
        expect(identical(th2Controller2.th2File, snapshotOriginal2), isFalse);
        expect(th2Controller2.th2File == snapshotOriginal2, isTrue);
      },
    );
  });
}
