// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/widgets/th_text_editor_widget.dart';
import 'package:material_ui/material_ui.dart';

import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  THTextEditorController? activeController;

  THTextEditorController buildController(String content) {
    final THTextEditorController controller = THTextEditorController(
      projectController: THProjectController(),
    );

    activeController = controller;
    controller.setContent(content);

    return controller;
  }

  Widget buildTestApp(THTextEditorController controller) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: THTextEditorWidget(controller: controller)),
    );
  }

  TextField findTextField(WidgetTester tester) => tester.widget<TextField>(
    find.byKey(const ValueKey('THTextEditorWidget|TextField')),
  );

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
  });

  tearDown(() {
    activeController?.dispose();
    activeController = null;
  });

  group('THTextEditorController.revealRange', () {
    test('sets and clears pendingSelectionRange', () {
      final THTextEditorController controller = buildController('abc def');

      expect(controller.pendingSelectionRange, isNull);

      controller.revealRange(const TextRange(start: 4, end: 7));
      expect(controller.pendingSelectionRange, const TextRange(start: 4, end: 7));

      controller.clearPendingSelectionRange();
      expect(controller.pendingSelectionRange, isNull);
    });
  });

  group('THTextEditorWidget pending selection', () {
    testWidgets('applies the exact selection then clears the request', (
      WidgetTester tester,
    ) async {
      final THTextEditorController controller = buildController(
        'survey one\nendsurvey',
      );

      await tester.pumpWidget(buildTestApp(controller));
      await tester.pumpAndSettle();

      controller.revealRange(const TextRange(start: 11, end: 20));
      await tester.pump();
      await tester.pump();

      expect(findTextField(tester).controller!.selection.baseOffset, 11);
      expect(findTextField(tester).controller!.selection.extentOffset, 20);
      expect(controller.pendingSelectionRange, isNull);
    });

    testWidgets('clamps an out-of-range request to content length', (
      WidgetTester tester,
    ) async {
      final THTextEditorController controller = buildController('short');

      await tester.pumpWidget(buildTestApp(controller));
      await tester.pumpAndSettle();

      controller.revealRange(const TextRange(start: 2, end: 999));
      await tester.pump();
      await tester.pump();

      expect(findTextField(tester).controller!.selection.baseOffset, 2);
      expect(findTextField(tester).controller!.selection.extentOffset, 5);
      expect(controller.pendingSelectionRange, isNull);
    });

    testWidgets('exact selection wins over a pending line-only scroll', (
      WidgetTester tester,
    ) async {
      final THTextEditorController controller = buildController(
        'line one\nline two\nline three',
      );

      await tester.pumpWidget(buildTestApp(controller));
      await tester.pumpAndSettle();

      controller.scrollToLine(3); // pendingScrollToLine = 2
      controller.revealRange(const TextRange(start: 9, end: 17));
      await tester.pump();
      await tester.pump();

      // The exact range wins (selection is the range, not collapsed at a line
      // start), and only its own pending request is cleared.
      expect(findTextField(tester).controller!.selection.baseOffset, 9);
      expect(findTextField(tester).controller!.selection.extentOffset, 17);
      expect(controller.pendingSelectionRange, isNull);
    });
  });
}
