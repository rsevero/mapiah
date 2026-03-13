import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
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

  group('UI: duplicate lines through Ctrl+D', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'open a file, select both lines and duplicate pressing Ctrl+D',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final THFileWriter writer = THFileWriter();
        final String testFilename = THTestAux.testPath(
          '2026-03-13-001-lines.th2',
        );
        final TH2FileEditController th2Controller = mpLocator
            .mpGeneralController
            .getTH2FileEditController(filename: testFilename);

        await tester.runAsync(() async {
          await th2Controller.load();
        });

        final TH2FileEditSelectionController selectionController =
            th2Controller.selectionController;
        final THFile thFile = th2Controller.thFile;
        final String originalSerialized = writer.serialize(thFile);
        final THFile snapshotOriginal = THFile.fromMap(thFile.toMap());

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
        th2Controller.setActiveScrap(thFile.getScraps().first.mpID);

        final List<THLine> originalLines = thFile.getLines().toList();

        expect(originalLines.length, 2);

        final THLine originalWallLine = originalLines[0];
        final THLine originalContourLine = originalLines[1];

        expect(originalWallLine.lineType, THLineType.wall);
        expect(originalContourLine.lineType, THLineType.contour);

        final String? originalWallID = MPCommandOptionAux.getID(
          originalWallLine,
        );
        expect(originalWallID, 'unsurveyed');

        final String? originalContourID = MPCommandOptionAux.getID(
          originalContourLine,
        );
        expect(originalContourID, 'blaus');

        selectionController.setSelectedElements([
          originalWallLine,
          originalContourLine,
        ]);
        th2Controller.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );
        th2Controller.elementEditController.duplicateSelectedElements();

        final List<THLine> linesAfterDuplicate = thFile.getLines().toList();

        expect(linesAfterDuplicate.length, 4);

        final Set<int> originalMPIDs = {
          originalWallLine.mpID,
          originalContourLine.mpID,
        };
        final List<THLine> duplicatedLines = linesAfterDuplicate
            .where((THLine line) => !originalMPIDs.contains(line.mpID))
            .toList();

        expect(duplicatedLines.length, 2);

        final THLine duplicatedWallLine = duplicatedLines.firstWhere(
          (THLine line) => line.lineType == THLineType.wall,
        );
        final THLine duplicatedContourLine = duplicatedLines.firstWhere(
          (THLine line) => line.lineType == THLineType.contour,
        );

        expect(duplicatedWallLine.mpID == originalWallLine.mpID, isFalse);
        expect(duplicatedWallLine.lineType, originalWallLine.lineType);
        expect(
          duplicatedWallLine.unknownPLAType,
          originalWallLine.unknownPLAType,
        );
        expect(MPCommandOptionAux.getID(duplicatedWallLine), 'unsurveyed-1');
        expect(
          duplicatedWallLine.optionsMap.length,
          originalWallLine.optionsMap.length,
        );

        expect(duplicatedContourLine.mpID == originalContourLine.mpID, isFalse);
        expect(duplicatedContourLine.lineType, originalContourLine.lineType);
        expect(
          duplicatedContourLine.unknownPLAType,
          originalContourLine.unknownPLAType,
        );
        expect(MPCommandOptionAux.getID(duplicatedContourLine), 'blaus-1');
        expect(
          duplicatedContourLine.optionsMap.length,
          originalContourLine.optionsMap.length,
        );

        th2Controller.undo();
        await tester.pumpAndSettle();

        final String undoneSerialized = writer.serialize(th2Controller.thFile);

        expect(undoneSerialized, originalSerialized);
        expect(identical(th2Controller.thFile, snapshotOriginal), isFalse);
        expect(th2Controller.thFile == snapshotOriginal, isTrue);
      },
    );
  });
}
