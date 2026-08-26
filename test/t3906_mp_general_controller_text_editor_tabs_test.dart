// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/mp_general_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MPLocator mpLocator = MPLocator();

  group('MPGeneralController text-editor tab support', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test('isTH2Tab distinguishes .th2 from thconfig/.th filenames', () {
      expect(isTH2Tab('/a/b/cave.th2'), isTrue);
      expect(isTH2Tab('/a/b/CAVE.TH2'), isTrue);
      expect(isTH2Tab('/a/b/cave.th'), isFalse);
      expect(isTH2Tab('/a/b/thconfig'), isFalse);
    });

    test(
      'getTextEditorController creates once and reuses on the normalized '
      'path',
      () {
        final String rawPath = './test/auxiliary/th_project/multiple-sources/cave_one.th';
        final THTextEditorController first = mpLocator.mpGeneralController
            .getTextEditorController(rawPath);
        final THTextEditorController second = mpLocator.mpGeneralController
            .getTextEditorController(p.absolute(rawPath));

        expect(identical(first, second), isTrue);
        expect(
          mpLocator.mpGeneralController.getTextEditorControllerIfExists(
            rawPath,
          ),
          same(first),
        );
      },
    );

    test('getTextEditorControllerIfExists returns null before creation', () {
      expect(
        mpLocator.mpGeneralController.getTextEditorControllerIfExists(
          '/no/such/file.th',
        ),
        isNull,
      );
    });

    test(
      'addFileTab/setActiveTab/removeFileTab work for a mix of .th2 and '
      '.th filenames',
      () {
        const String th2Filename = '/tmp/mapiah_test_mixed_tabs_a.th2';
        const String thFilename = '/tmp/mapiah_test_mixed_tabs_b.th';

        mpLocator.mpGeneralController.getTH2FileEditController(
          filename: th2Filename,
        );
        mpLocator.mpGeneralController.getTextEditorController(thFilename);

        mpLocator.mpGeneralController.addFileTab(th2Filename);
        mpLocator.mpGeneralController.addFileTab(thFilename);

        expect(mpLocator.mpGeneralController.openFileOrder, hasLength(2));
        expect(mpLocator.mpGeneralController.activeTabIndex, 1);

        mpLocator.mpGeneralController.setActiveTab(0);
        expect(mpLocator.mpGeneralController.activeTabIndex, 0);

        mpLocator.mpGeneralController.removeFileTab(filename: thFilename);
        expect(mpLocator.mpGeneralController.openFileOrder, hasLength(1));
        expect(
          mpLocator.mpGeneralController.getTextEditorControllerIfExists(
            thFilename,
          ),
          isNull,
        );
      },
    );

    test('removeFileTab disposes and clears the text-editor controller', () {
      const String thFilename = '/tmp/mapiah_test_removed_tab.th';

      expect(
        mpLocator.mpGeneralController.getTextEditorController(thFilename),
        isNotNull,
      );

      mpLocator.mpGeneralController.addFileTab(thFilename);

      // Disposing here cancels the controller's own debounce Timer; a
      // dangling one would keep the test process alive after this test
      // completes.
      expect(
        () => mpLocator.mpGeneralController.removeFileTab(
          filename: thFilename,
        ),
        returnsNormally,
      );
      expect(
        mpLocator.mpGeneralController.getTextEditorControllerIfExists(
          thFilename,
        ),
        isNull,
      );
    });

    test('reset() clears and disposes both registries', () {
      const String th2Filename = '/tmp/mapiah_test_reset_a.th2';
      const String thFilename = '/tmp/mapiah_test_reset_b.th';

      mpLocator.mpGeneralController.getTH2FileEditController(
        filename: th2Filename,
      );
      mpLocator.mpGeneralController.getTextEditorController(thFilename);

      mpLocator.mpGeneralController.addFileTab(th2Filename);
      mpLocator.mpGeneralController.addFileTab(thFilename);

      expect(mpLocator.mpGeneralController.reset, returnsNormally);

      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
      expect(
        mpLocator.mpGeneralController.getTextEditorControllerIfExists(
          thFilename,
        ),
        isNull,
      );
    });
  });
}
