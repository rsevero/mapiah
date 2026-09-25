// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/widgets/th_text_editor_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import 'th2_file_tabs_page_test_aux.dart';
import 'th_test_aux.dart';

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
  });

  Future<void> pressWithModifiers(
    WidgetTester tester,
    LogicalKeyboardKey key, {
    required LogicalKeyboardKey modifier,
    bool shift = false,
  }) async {
    await tester.sendKeyDownEvent(modifier);
    if (shift) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    }
    await tester.sendKeyEvent(key);
    if (shift) {
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    }
    await tester.sendKeyUpEvent(modifier);
    await tester.pump();
  }

  group('canvas', () {
    testWidgets('Ctrl+Shift+Z redoes and Ctrl+Y no longer does', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(
            filename: THTestAux.testPath('2025-10-07-002-point.th2'),
          );

      await tester.runAsync(() async {
        await controller.load();
      });
      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: controller),
      );
      await tester.pump();

      final TH2File th2File = controller.th2File;

      controller.setActiveScrap(th2File.getScraps().first.mpID);

      final THPoint point = th2File.getPoints().first;

      controller.selectionController.setSelectedElements(<THElement>[point]);
      controller.stateController.setState(
        MPTH2FileEditStateType.selectNonEmptySelection,
      );
      controller.copyPasteController.cutSelectedElements();
      await tester.pump();
      expect(th2File.getPoints(), isEmpty);

      controller.th2FileFocusNode.requestFocus();
      await tester.pump();

      await pressWithModifiers(
        tester,
        LogicalKeyboardKey.keyZ,
        modifier: LogicalKeyboardKey.controlLeft,
      );
      expect(th2File.getPoints().length, 1);

      await pressWithModifiers(
        tester,
        LogicalKeyboardKey.keyY,
        modifier: LogicalKeyboardKey.controlLeft,
      );
      expect(th2File.getPoints().length, 1);

      await pressWithModifiers(
        tester,
        LogicalKeyboardKey.keyZ,
        modifier: LogicalKeyboardKey.controlLeft,
        shift: true,
      );
      expect(th2File.getPoints(), isEmpty);

      await pressWithModifiers(
        tester,
        LogicalKeyboardKey.keyZ,
        modifier: LogicalKeyboardKey.metaLeft,
      );
      expect(th2File.getPoints().length, 1);

      await pressWithModifiers(
        tester,
        LogicalKeyboardKey.keyZ,
        modifier: LogicalKeyboardKey.metaLeft,
        shift: true,
      );
      expect(th2File.getPoints(), isEmpty);
    });
  });

  group('text editor', () {
    late Directory tempDir;
    late THTextEditorController controller;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('mapiah_t3956_');
    });

    tearDown(() {
      controller.dispose();
      tempDir.deleteSync(recursive: true);
    });

    for (final (String name, LogicalKeyboardKey modifier) in <(
      String,
      LogicalKeyboardKey,
    )>[
      ('Ctrl', LogicalKeyboardKey.controlLeft),
      ('Cmd', LogicalKeyboardKey.metaLeft),
    ]) {
      testWidgets('$name+Z undoes and $name+Shift+Z redoes', (
        WidgetTester tester,
      ) async {
        final String filePath = p.join(tempDir.path, 'cave.th');

        File(filePath).writeAsStringSync('survey cave\nendsurvey\n');
        controller = THTextEditorController(
          projectController: mpLocator.thProjectController,
        );
        await controller.loadFile(filePath);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(body: THTextEditorWidget(controller: controller)),
          ),
        );

        final Finder field = find.byKey(
          const ValueKey('THTextEditorWidget|TextField'),
        );

        await tester.tap(field);
        await tester.pump(const Duration(seconds: 1));
        await tester.enterText(field, 'survey other\nendsurvey\n');
        await tester.pump(const Duration(seconds: 1));
        expect(controller.content, 'survey other\nendsurvey\n');

        await pressWithModifiers(
          tester,
          LogicalKeyboardKey.keyZ,
          modifier: modifier,
        );
        expect(controller.content, 'survey cave\nendsurvey\n');

        await pressWithModifiers(
          tester,
          LogicalKeyboardKey.keyZ,
          modifier: modifier,
          shift: true,
        );
        expect(controller.content, 'survey other\nendsurvey\n');
      });
    }
  });
}
