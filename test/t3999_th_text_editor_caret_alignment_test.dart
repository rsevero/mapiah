// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/widgets/th_text_editor_widget.dart';
import 'package:material_ui/material_ui.dart';

import 'th_test_aux.dart';

const String _line =
    'survey cave -title "A long title that goes on for many characters"';

/// The editor draws the text with a colored overlay over a transparent
/// text field, so both must lay the text out identically: otherwise the
/// caret, which the field draws, isn't where the visible text is.
void main() {
  THTestAux.ensureTestEnvironment();

  final MPLocator mpLocator = MPLocator();
  final List<THTextEditorController> controllers = <THTextEditorController>[];

  MPSettingsController settings() => mpLocator.mpSettingsController;

  setUpAll(() async {
    final FontLoader loader = FontLoader(mpMonospaceFontFamily);

    for (final String file in <String>[
      'assets/fonts/NotoSansMono-Regular.ttf',
      'assets/fonts/NotoSansMono-Bold.ttf',
    ]) {
      final Uint8List bytes = File(file).readAsBytesSync();

      loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  });

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await settings().initialized;
    settings().resetDouble(MPSettingID.TextEditor_FontSize);
  });

  tearDown(() {
    settings().resetDouble(MPSettingID.TextEditor_FontSize);
    for (final THTextEditorController controller in controllers) {
      controller.cancelPendingReparse();
      controller.dispose();
    }
    controllers.clear();
    mpLocator.thProjectController.closeProject();
  });

  for (final double fontSize in <double>[mpTextEditorFontSize, 6, 48]) {
    testWidgets('the caret sits where the visible text is, at font size '
        '$fontSize', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(4000, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      settings().setDouble(MPSettingID.TextEditor_FontSize, fontSize);

      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );

      controller.setContent('$_line\n');
      controllers.add(controller);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(body: THTextEditorWidget(controller: controller)),
        ),
      );
      await tester.pump();

      final RenderEditable editable = tester
          .state<EditableTextState>(find.byType(EditableText).first)
          .renderEditable;
      final RenderParagraph overlay = tester.renderObject<RenderParagraph>(
        find.descendant(
          of: find.byKey(const ValueKey('THTextEditorWidget|SyntaxOverlay')),
          matching: find.byType(RichText),
        ),
      );

      for (final int offset in <int>[0, 10, 40, _line.length]) {
        final TextPosition position = TextPosition(offset: offset);
        final Offset caret = editable.localToGlobal(
          editable.getLocalRectForCaret(position).topLeft,
        );
        final Offset glyph = overlay.localToGlobal(
          overlay.getOffsetForCaret(position, Rect.zero),
        );

        expect(
          (caret.dx - glyph.dx).abs(),
          lessThan(1.0),
          reason: 'offset $offset: caret ${caret.dx}, text ${glyph.dx}',
        );
      }
    });
  }
}
