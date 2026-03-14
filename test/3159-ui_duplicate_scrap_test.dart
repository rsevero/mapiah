import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
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

  group('UI: duplicate scrap', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'select scrap and duplicate: new scrap has same point, line and area counts',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final THFileWriter writer = THFileWriter();
        final String testFilename = THTestAux.testPath(
          '2026-03-14-001-point_line_and_area.th2',
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

        final List<THScrap> originalScraps = thFile.getScraps().toList();

        expect(originalScraps.length, 1);

        final THScrap originalScrap = originalScraps.first;
        final int originalPointCount = thFile.getPoints().length;
        final int originalLineCount = thFile.getLines().length;
        final int originalAreaCount = thFile.getAreas().length;

        expect(originalPointCount, 2);
        expect(originalLineCount, 3);
        expect(originalAreaCount, 1);

        th2Controller.setActiveScrap(originalScrap.mpID);

        selectionController.setSelectedElements([originalScrap]);
        th2Controller.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );
        th2Controller.elementEditController.duplicateSelectedElements();

        final List<THScrap> scrapsAfterDuplicate = thFile.getScraps().toList();

        expect(scrapsAfterDuplicate.length, 2);
        expect(thFile.getPoints().length, originalPointCount * 2);
        expect(thFile.getLines().length, originalLineCount * 2);
        expect(thFile.getAreas().length, originalAreaCount * 2);

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
