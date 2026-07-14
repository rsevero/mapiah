// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'th_test_aux.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

Future<void> _expectScrapDuplicationSucceeds({
  required WidgetTester tester,
  required MPLocator mpLocator,
  required String fixtureFilename,
}) async {
  final String testFilename = THTestAux.testPath(fixtureFilename);
  final TH2FileEditController controller = mpLocator.mpGeneralController
      .getTH2FileEditController(filename: testFilename);

  await tester.runAsync(() async {
    await controller.load();
  });

  mpLocator.mpGeneralController.addFileTab(testFilename);

  final TH2File th2File = controller.th2File;
  final List<THScrap> scrapsBefore = th2File.getScraps().toList();

  expect(scrapsBefore.length, 1);

  final int originalScrapMPID = scrapsBefore.first.mpID;

  expect(
    () => controller.copyPasteController.duplicateScrap(originalScrapMPID),
    returnsNormally,
  );

  final List<THScrap> scrapsAfter = th2File.getScraps().toList();

  expect(scrapsAfter.length, 2);

  /// The original scrap must still be present.
  expect(scrapsAfter.any((s) => s.mpID == originalScrapMPID), isTrue);

  /// The newly active scrap must be the duplicate (not the original).
  expect(controller.activeScrapID, isNot(originalScrapMPID));

  /// Selection must be empty after duplicating a scrap.
  expect(controller.selectionController.mpSelectedElementsLogical, isEmpty);
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

    testWidgets('duplicating a scrap with an author option does not throw', (
      WidgetTester tester,
    ) async {
      await _expectScrapDuplicationSucceeds(
        tester: tester,
        mpLocator: mpLocator,
        fixtureFilename: 'th_file_parser-00260-scrap_with_author_option.th2',
      );
    });
  });
}
