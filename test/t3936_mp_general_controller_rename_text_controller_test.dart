// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MPLocator mpLocator = MPLocator();

  group('MPGeneralController.renameFileController (text-editor)', () {
    setUp(() {
      mpLocator.mpGeneralController.reset();
    });

    test(
      'migrates a registered THTextEditorController map entry, preserving '
      'the same controller instance and its cursor/fold/find state',
      () {
        const String oldFilename = '/tmp/mapiah_rename_old.th';
        const String newFilename = '/tmp/mapiah_rename_new.th';

        final THTextEditorController controller = mpLocator.mpGeneralController
            .getTextEditorController(oldFilename);

        controller.setCursorPosition(line: 3, column: 5);
        controller.toggleFold(2);
        controller.setFindQuery('cave');

        mpLocator.mpGeneralController.renameFileController(
          oldFilename: oldFilename,
          newFilename: newFilename,
        );

        expect(
          mpLocator.mpGeneralController.getTextEditorControllerIfExists(
            oldFilename,
          ),
          isNull,
        );

        final THTextEditorController? migrated = mpLocator.mpGeneralController
            .getTextEditorControllerIfExists(newFilename);

        expect(migrated, same(controller));
        expect(migrated!.cursorLine, 3);
        expect(migrated.cursorColumn, 5);
        expect(migrated.collapsedFoldStarts, contains(2));
        expect(migrated.findQuery, 'cave');
      },
    );

    test(
      'rewrites the matching _openFileOrder entry in place, preserving '
      'activeTabIndex when the active tab is the one being renamed',
      () {
        const String otherFilename = '/tmp/mapiah_rename_sibling.th';
        const String oldFilename = '/tmp/mapiah_rename_active_old.th';
        const String newFilename = '/tmp/mapiah_rename_active_new.th';

        mpLocator.mpGeneralController.getTextEditorController(otherFilename);
        mpLocator.mpGeneralController.getTextEditorController(oldFilename);
        mpLocator.mpGeneralController.addFileTab(otherFilename);
        mpLocator.mpGeneralController.addFileTab(oldFilename);

        expect(mpLocator.mpGeneralController.activeTabIndex, 1);

        mpLocator.mpGeneralController.renameFileController(
          oldFilename: oldFilename,
          newFilename: newFilename,
        );

        expect(
          mpLocator.mpGeneralController.openFileOrder,
          <String>[otherFilename, newFilename],
        );
        expect(mpLocator.mpGeneralController.activeTabIndex, 1);
      },
    );

    test('leaves an unrelated TH2 controller/tab entry untouched', () {
      const String th2Filename = '/tmp/mapiah_rename_unrelated.th2';
      const String oldFilename = '/tmp/mapiah_rename_text_old.th';
      const String newFilename = '/tmp/mapiah_rename_text_new.th';

      final TH2FileEditController th2Controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: th2Filename);
      mpLocator.mpGeneralController.getTextEditorController(oldFilename);
      mpLocator.mpGeneralController.addFileTab(th2Filename);
      mpLocator.mpGeneralController.addFileTab(oldFilename);

      mpLocator.mpGeneralController.renameFileController(
        oldFilename: oldFilename,
        newFilename: newFilename,
      );

      expect(
        mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(
          th2Filename,
        ),
        same(th2Controller),
      );
      expect(
        mpLocator.mpGeneralController.openFileOrder,
        <String>[th2Filename, newFilename],
      );
    });

    test(
      'pre-existing TH2 rename behavior is unaffected (regression)',
      () {
        const String oldFilename = '/tmp/mapiah_rename_th2_old.th2';
        const String newFilename = '/tmp/mapiah_rename_th2_new.th2';

        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditController(filename: oldFilename);
        mpLocator.mpGeneralController.addFileTab(oldFilename);

        mpLocator.mpGeneralController.renameFileController(
          oldFilename: oldFilename,
          newFilename: newFilename,
        );

        expect(
          mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(
            oldFilename,
          ),
          isNull,
        );
        expect(
          mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(
            newFilename,
          ),
          same(controller),
        );
        expect(
          mpLocator.mpGeneralController.openFileOrder,
          <String>[newFilename],
        );
        // No text-editor entry was ever created for this .th2-only rename.
        expect(
          mpLocator.mpGeneralController.getTextEditorControllerIfExists(
            newFilename,
          ),
          isNull,
        );
      },
    );
  });
}
