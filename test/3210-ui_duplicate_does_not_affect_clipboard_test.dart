// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_copy_element_result.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  final MPLocator mpLocator = MPLocator();

  group('UI: duplicate does not affect clipboard', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets('duplicateScrap does not overwrite the clipboard', (
      WidgetTester tester,
    ) async {
      final String testFilename = THTestAux.testPath(
        '2025-10-07-002-point.th2',
      );
      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: testFilename);

      await tester.runAsync(() async {
        await controller.load();
      });

      mpLocator.mpGeneralController.addFileTab(testFilename);

      final TH2File th2File = controller.th2File;
      final THScrap scrap = th2File.getScraps().first;

      /// Establish clipboard content by copying the scrap.
      controller.selectionController.setSelectedElements([scrap]);
      controller.copyPasteController.copySelectedElements();
      controller.selectionController.clearSelectedElements();

      final List<MPCopyElementWithChildren>? clipboardBefore = mpLocator
          .mpGeneralController
          .getClipboard();

      expect(clipboardBefore, isNotNull);
      expect(clipboardBefore!.isNotEmpty, isTrue);

      final List<int> originalMPIDsBefore = clipboardBefore
          .map((entry) => entry.template.originalMPID ?? 0)
          .toList();

      /// Duplicate the scrap — this should not overwrite the clipboard.
      controller.copyPasteController.duplicateScrap(scrap.mpID);

      final List<MPCopyElementWithChildren>? clipboardAfter = mpLocator
          .mpGeneralController
          .getClipboard();

      expect(clipboardAfter, isNotNull);
      expect(clipboardAfter!.isNotEmpty, isTrue);

      final List<int> originalMPIDsAfter = clipboardAfter
          .map((entry) => entry.template.originalMPID ?? 0)
          .toList();

      /// Clipboard MPIDs must be unchanged.
      expect(originalMPIDsAfter, equals(originalMPIDsBefore));
    });

    testWidgets('duplicateSelectedElements does not overwrite the clipboard', (
      WidgetTester tester,
    ) async {
      final String testFilename = THTestAux.testPath(
        '2025-10-07-002-point.th2',
      );
      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: testFilename);

      await tester.runAsync(() async {
        await controller.load();
      });

      mpLocator.mpGeneralController.addFileTab(testFilename);

      final TH2File th2File = controller.th2File;
      final THScrap scrap = th2File.getScraps().first;

      /// Establish clipboard content by copying the scrap.
      controller.selectionController.setSelectedElements([scrap]);
      controller.copyPasteController.copySelectedElements();
      controller.selectionController.clearSelectedElements();

      final List<MPCopyElementWithChildren>? clipboardBefore = mpLocator
          .mpGeneralController
          .getClipboard();

      expect(clipboardBefore, isNotNull);
      expect(clipboardBefore!.isNotEmpty, isTrue);

      final List<int> originalMPIDsBefore = clipboardBefore
          .map((entry) => entry.template.originalMPID ?? 0)
          .toList();

      /// Select the scrap and call duplicateSelectedElements.
      controller.selectionController.setSelectedElements([scrap]);
      controller.copyPasteController.duplicateSelectedElements();

      final List<MPCopyElementWithChildren>? clipboardAfter = mpLocator
          .mpGeneralController
          .getClipboard();

      expect(clipboardAfter, isNotNull);
      expect(clipboardAfter!.isNotEmpty, isTrue);

      final List<int> originalMPIDsAfter = clipboardAfter
          .map((entry) => entry.template.originalMPID ?? 0)
          .toList();

      /// Clipboard MPIDs must be unchanged.
      expect(originalMPIDsAfter, equals(originalMPIDsBefore));
    });
  });
}
