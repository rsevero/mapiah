// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
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

  group('UI: copy scrap from file A and paste into new empty file B', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'pasting a copied scrap into a new empty file adds the scrap to that file',
      (WidgetTester tester) async {
        /// Load file A
        final String testFilenameA = THTestAux.testPath(
          '2025-10-07-002-point.th2',
        );
        final TH2FileEditController controllerA = mpLocator.mpGeneralController
            .getTH2FileEditController(filename: testFilenameA);

        await tester.runAsync(() async {
          await controllerA.load();
        });

        final TH2File th2FileA = controllerA.th2File;

        mpLocator.mpGeneralController.addFileTab(testFilenameA);

        /// Create new empty file B (scrap thID 'scrap-1', default encoding)
        final TH2FileEditController controllerB = mpLocator.mpGeneralController
            .getTH2FileEditControllerForNewFile(
              scrapTHID: '${mpScrapTHIDPrefix}1',
              scrapOptions: [],
              encoding: mpDefaultEncoding,
            );

        final TH2File th2FileB = controllerB.th2File;

        mpLocator.mpGeneralController.addFileTab(controllerB.th2File.filename);

        /// Verify initial state: file B has exactly one scrap ('scrap-1')
        final List<THScrap> scrapsInBBefore = th2FileB.getScraps().toList();
        expect(scrapsInBBefore.length, 1);
        expect(scrapsInBBefore.first.thID, '${mpScrapTHIDPrefix}1');

        /// Switch to file A (tab index 0) and copy its scrap ('test')
        mpLocator.mpGeneralController.setActiveTab(0);

        final List<THScrap> scrapsInA = th2FileA.getScraps().toList();
        expect(scrapsInA.length, 1);
        expect(scrapsInA.first.thID, 'test');

        controllerA.copyPasteController.copyScrap(scrapsInA.first.mpID);

        /// Verify clipboard was populated
        expect(mpLocator.mpGeneralController.hasClipboardContent, isTrue);

        /// Switch to file B (tab index 1) and paste
        mpLocator.mpGeneralController.setActiveTab(1);

        controllerB.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
        controllerB.copyPasteController.pasteElements();

        /// File B should now have two scraps: 'scrap-1' and 'test'
        final List<THScrap> scrapsInBAfter = th2FileB.getScraps().toList();
        expect(scrapsInBAfter.length, 2);

        final List<String> scrapTHIDs = scrapsInBAfter
            .map((final THScrap s) => s.thID)
            .toList();
        expect(scrapTHIDs, containsAll(['${mpScrapTHIDPrefix}1', 'test']));
      },
    );
  });
}
