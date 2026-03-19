// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  group('UI: copy scrap from file A, switch tab, keyboard paste into file B', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'switching to file B tab gives focus to file B canvas so Ctrl+V pastes there',
      (WidgetTester tester) async {
        /// Load file A.
        final String testFilenameA = THTestAux.testPath(
          '2025-10-07-002-point.th2',
        );
        final TH2FileEditController controllerA = mpLocator.mpGeneralController
            .getTH2FileEditController(filename: testFilenameA);

        await tester.runAsync(() async {
          await controllerA.load();
        });

        mpLocator.mpGeneralController.addFileTab(testFilenameA);

        /// Create new empty file B.
        final TH2FileEditController controllerB = mpLocator.mpGeneralController
            .getTH2FileEditControllerForNewFile(
              scrapTHID: '${mpScrapTHIDPrefix}1',
              scrapOptions: [],
              encoding: mpDefaultEncoding,
            );

        mpLocator.mpGeneralController.addFileTab(controllerB.th2File.filename);

        /// Pump a minimal widget tree that attaches both focus nodes to the
        /// Flutter focus system and routes key events to each controller's
        /// state machine (mirroring MPListenerWidget's behaviour).
        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                Focus(
                  focusNode: controllerA.th2FileFocusNode,
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent) {
                      controllerA.stateController.onKeyDownEvent(event);
                    }

                    return KeyEventResult.handled;
                  },
                  child: Container(width: 100, height: 100),
                ),
                Focus(
                  focusNode: controllerB.th2FileFocusNode,
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent) {
                      controllerB.stateController.onKeyDownEvent(event);
                    }

                    return KeyEventResult.handled;
                  },
                  child: Container(width: 100, height: 100),
                ),
              ],
            ),
          ),
        );
        await tester.pump();

        /// Switch to file A (tab index 0) and simulate the user clicking on
        /// its canvas, which gives it focus.
        mpLocator.mpGeneralController.setActiveTab(0);
        controllerA.th2FileFocusNode.requestFocus();
        await tester.pump();

        expect(controllerA.th2FileFocusNode.hasFocus, isTrue);

        /// Copy scrap from file A.
        final TH2File th2FileA = controllerA.th2File;
        final List<THScrap> scrapsInA = th2FileA.getScraps().toList();

        expect(scrapsInA.length, 1);
        expect(scrapsInA.first.thID, 'test');

        controllerA.copyPasteController.copyScrap(scrapsInA.first.mpID);
        expect(mpLocator.mpGeneralController.hasClipboardContent, isTrue);

        /// Switch to file B (tab index 1).
        /// setActiveTab must request focus on file B's canvas so that a
        /// subsequent Ctrl+V is delivered to B, not to A's offstage canvas.
        controllerB.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
        mpLocator.mpGeneralController.setActiveTab(1);
        await tester.pump();

        expect(
          controllerB.th2FileFocusNode.hasFocus,
          isTrue,
          reason:
              'After switching to file B tab, file B\'s canvas must hold '
              'focus so that keyboard shortcuts (Ctrl+V) are routed there.',
        );

        /// Send Ctrl+V to the focused widget — must be delivered to file B.
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyV);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyV);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pumpAndSettle();

        /// File B should now have two scraps: the original 'scrap-1' and
        /// the pasted 'test' scrap from file A.
        final TH2File th2FileB = controllerB.th2File;
        final List<THScrap> scrapsInBAfter = th2FileB.getScraps().toList();

        expect(
          scrapsInBAfter.length,
          2,
          reason: 'Ctrl+V must paste the copied scrap into file B.',
        );

        final List<String> scrapTHIDs = scrapsInBAfter
            .map((final THScrap s) => s.thID)
            .toList();

        expect(scrapTHIDs, containsAll(['${mpScrapTHIDPrefix}1', 'test']));
      },
    );
  });
}
