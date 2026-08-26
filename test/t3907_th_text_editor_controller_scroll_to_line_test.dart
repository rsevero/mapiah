// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';

import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  group('THTextEditorController.scrollToLine', () {
    test('sets pendingScrollToLine to the 0-based equivalent', () {
      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );

      expect(controller.pendingScrollToLine, isNull);

      controller.scrollToLine(1);
      expect(controller.pendingScrollToLine, 0);

      controller.scrollToLine(12);
      expect(controller.pendingScrollToLine, 11);

      controller.dispose();
    });

    test('clearPendingScrollToLine resets it to null', () {
      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );

      controller.scrollToLine(5);
      expect(controller.pendingScrollToLine, isNotNull);

      controller.clearPendingScrollToLine();
      expect(controller.pendingScrollToLine, isNull);

      controller.dispose();
    });

    test('dispose() disposes textEditorFocusNode without throwing', () {
      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );

      expect(controller.textEditorFocusNode.hasFocus, isFalse);
      expect(controller.dispose, returnsNormally);
    });
  });
}
