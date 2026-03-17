// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
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

  group('UI: duplicate area through Ctrl+D', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets('select area only: area and its border line are duplicated', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final THFileWriter writer = THFileWriter();
      final String testFilename = THTestAux.testPath(
        '2025-09-20-001-area_line_exists_but_has_no_id.th2',
      );
      final TH2FileEditController th2Controller = mpLocator.mpGeneralController
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

      final List<THArea> originalAreas = th2File.getAreas().toList();
      final List<THLine> originalLines = th2File.getLines().toList();

      expect(originalAreas.length, 1);
      expect(originalLines.length, 2);

      final THArea originalArea = originalAreas.first;
      final THLine originalBorderLine = originalLines.firstWhere(
        (THLine line) => MPCommandOptionAux.getID(line) != null,
      );
      final THLine originalFloorStepLine = originalLines.firstWhere(
        (THLine line) => MPCommandOptionAux.getID(line) == null,
      );

      expect(MPCommandOptionAux.getID(originalBorderLine), 'l85-3732--20');
      expect(MPCommandOptionAux.getID(originalFloorStepLine), isNull);

      selectionController.setSelectedElements([originalArea]);
      th2Controller.stateController.setState(
        MPTH2FileEditStateType.selectNonEmptySelection,
      );
      th2Controller.elementEditController.duplicateSelectedElements();

      final List<THArea> areasAfterDuplicate = th2File.getAreas().toList();
      final List<THLine> linesAfterDuplicate = th2File.getLines().toList();

      expect(areasAfterDuplicate.length, 2);
      expect(linesAfterDuplicate.length, 3);

      final THArea duplicatedArea = areasAfterDuplicate.firstWhere(
        (THArea area) => area.mpID != originalArea.mpID,
      );

      expect(duplicatedArea.mpID == originalArea.mpID, isFalse);
      expect(duplicatedArea.areaType, originalArea.areaType);

      final Set<int> originalLineMPIDs = {
        originalBorderLine.mpID,
        originalFloorStepLine.mpID,
      };
      final THLine duplicatedBorderLine = linesAfterDuplicate.firstWhere(
        (THLine line) => !originalLineMPIDs.contains(line.mpID),
      );

      expect(duplicatedBorderLine.mpID == originalBorderLine.mpID, isFalse);
      expect(MPCommandOptionAux.getID(duplicatedBorderLine), 'l85-3732--20-1');

      th2Controller.undo();
      await tester.pumpAndSettle();

      final String undoneSerialized = writer.serialize(th2Controller.th2File);

      expect(undoneSerialized, originalSerialized);
      expect(identical(th2Controller.th2File, snapshotOriginal), isFalse);
      expect(th2Controller.th2File == snapshotOriginal, isTrue);
    });

    testWidgets('select area and both lines: one copy of each element', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final THFileWriter writer = THFileWriter();
      final String testFilename = THTestAux.testPath(
        '2025-09-20-001-area_line_exists_but_has_no_id.th2',
      );
      final TH2FileEditController th2Controller = mpLocator.mpGeneralController
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

      final List<THArea> originalAreas = th2File.getAreas().toList();
      final List<THLine> originalLines = th2File.getLines().toList();

      expect(originalAreas.length, 1);
      expect(originalLines.length, 2);

      final THArea originalArea = originalAreas.first;
      final THLine originalBorderLine = originalLines.firstWhere(
        (THLine line) => MPCommandOptionAux.getID(line) != null,
      );
      final THLine originalFloorStepLine = originalLines.firstWhere(
        (THLine line) => MPCommandOptionAux.getID(line) == null,
      );

      expect(MPCommandOptionAux.getID(originalBorderLine), 'l85-3732--20');
      expect(MPCommandOptionAux.getID(originalFloorStepLine), isNull);

      selectionController.setSelectedElements([
        originalArea,
        originalBorderLine,
        originalFloorStepLine,
      ]);
      th2Controller.stateController.setState(
        MPTH2FileEditStateType.selectNonEmptySelection,
      );
      th2Controller.elementEditController.duplicateSelectedElements();

      final List<THArea> areasAfterDuplicate = th2File.getAreas().toList();
      final List<THLine> linesAfterDuplicate = th2File.getLines().toList();

      // Border line is deduplicated: the area already duplicates it, so the
      // direct selection of that same line is skipped.
      expect(areasAfterDuplicate.length, 2);
      expect(linesAfterDuplicate.length, 4);

      final Set<int> originalLineMPIDs = {
        originalBorderLine.mpID,
        originalFloorStepLine.mpID,
      };
      final List<THLine> duplicatedLines = linesAfterDuplicate
          .where((THLine line) => !originalLineMPIDs.contains(line.mpID))
          .toList();

      expect(duplicatedLines.length, 2);

      final THLine duplicatedBorderLine = duplicatedLines.firstWhere(
        (THLine line) => MPCommandOptionAux.getID(line) != null,
      );
      final THLine duplicatedFloorStepLine = duplicatedLines.firstWhere(
        (THLine line) => MPCommandOptionAux.getID(line) == null,
      );

      expect(duplicatedBorderLine.mpID == originalBorderLine.mpID, isFalse);
      expect(MPCommandOptionAux.getID(duplicatedBorderLine), 'l85-3732--20-1');

      expect(
        duplicatedFloorStepLine.mpID == originalFloorStepLine.mpID,
        isFalse,
      );
      expect(MPCommandOptionAux.getID(duplicatedFloorStepLine), isNull);

      th2Controller.undo();
      await tester.pumpAndSettle();

      final String undoneSerialized = writer.serialize(th2Controller.th2File);

      expect(undoneSerialized, originalSerialized);
      expect(identical(th2Controller.th2File, snapshotOriginal), isFalse);
      expect(th2Controller.th2File == snapshotOriginal, isTrue);
    });
  });
}
