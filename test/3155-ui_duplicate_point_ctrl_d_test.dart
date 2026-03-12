import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
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

  group('UI: duplicate point through Ctrl+D', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets('open a file, select a point and duplicate pressing Ctrl+D', (
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
        '2026-03-12-001-point_with_attr_and_id_option.th2',
      );
      final TH2FileEditController th2Controller = mpLocator.mpGeneralController
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

      final THPoint originalPoint = thFile.getPoints().first;

      expect(thFile.getPoints().length, 1);
      expect(originalPoint.getAttrOptionValue('text'), '35');

      final String? originalTHID = MPCommandOptionAux.getID(originalPoint);
      expect(originalTHID, 'blaus');

      final String? originalSubtype = MPCommandOptionAux.getSubtype(
        originalPoint,
      );
      expect(originalSubtype, 'mappe');

      selectionController.setSelectedElements([originalPoint]);
      th2Controller.stateController.setState(
        MPTH2FileEditStateType.selectNonEmptySelection,
      );
      th2Controller.elementEditController.duplicateSelectedElements();

      final List<THPoint> pointsAfterDuplicate = thFile.getPoints().toList();

      expect(pointsAfterDuplicate.length, 2);

      final THPoint duplicatedPoint = pointsAfterDuplicate.last;

      final List<int> scrapChildrenMPIDs = thFile
          .getScraps()
          .first
          .childrenMPIDs;

      expect(
        scrapChildrenMPIDs.indexOf(duplicatedPoint.mpID),
        scrapChildrenMPIDs.length - 2,
      );

      expect(duplicatedPoint.mpID == originalPoint.mpID, isFalse);
      expect(duplicatedPoint.position, originalPoint.position);
      expect(duplicatedPoint.pointType, originalPoint.pointType);
      expect(duplicatedPoint.unknownPLAType, originalPoint.unknownPLAType);

      final String? duplicatedTHID = MPCommandOptionAux.getID(duplicatedPoint);
      expect(duplicatedTHID, 'blaus-1');
      expect(duplicatedPoint.getAttrOptionValue('text'), '35');

      final String? duplicatedSubtype = MPCommandOptionAux.getSubtype(
        duplicatedPoint,
      );
      expect(duplicatedSubtype, originalSubtype);

      expect(
        originalPoint.optionsMap.length,
        duplicatedPoint.optionsMap.length,
      );

      final bool areAttrOptionsMapsEquivalent =
          THTestAux.areAttrCommandOptionsMapsEquivalent(
            firstAttrOptionsMap: duplicatedPoint.attrOptionsMap,
            secondAttrOptionsMap: originalPoint.attrOptionsMap,
          );
      expect(areAttrOptionsMapsEquivalent, isTrue);

      th2Controller.undo();
      await tester.pumpAndSettle();

      final String undoneSerialized = writer.serialize(th2Controller.thFile);

      expect(undoneSerialized, originalSerialized);
      expect(identical(th2Controller.thFile, snapshotOriginal), isFalse);
      expect(th2Controller.thFile == snapshotOriginal, isTrue);
    });
  });
}
