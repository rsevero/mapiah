// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/widgets/th_text_editor_line_number_gutter_widget.dart';
import 'package:mapiah/src/widgets/th_text_editor_widget.dart';
import 'package:material_ui/material_ui.dart';

import 'th_test_aux.dart';

const ValueKey<String> _textFieldKey = ValueKey<String>(
  'THTextEditorWidget|TextField',
);

void main() {
  THTestAux.ensureTestEnvironment();

  final MPLocator mpLocator = MPLocator();
  final List<THTextEditorController> controllers = <THTextEditorController>[];

  MPSettingsController settings() => mpLocator.mpSettingsController;

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

  Future<void> pumpEditor(WidgetTester tester) async {
    final THTextEditorController controller = THTextEditorController(
      projectController: mpLocator.thProjectController,
    );

    controller.setContent('survey s1\n  centreline\n  endcentreline\n');
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
  }

  double fieldFontSize(WidgetTester tester) => tester
      .widget<EditableText>(
        find.descendant(
          of: find.byKey(_textFieldKey),
          matching: find.byType(EditableText),
        ),
      )
      .style
      .fontSize!;

  THTextEditorLineNumberGutterWidget gutter(WidgetTester tester) => tester
      .widget<THTextEditorLineNumberGutterWidget>(
        find.byType(THTextEditorLineNumberGutterWidget),
      );

  group('TextEditor_FontSize setting', () {
    test('defaults to mpTextEditorFontSize', () {
      expect(
        settings().getDefaultDouble(MPSettingID.TextEditor_FontSize),
        mpTextEditorFontSize,
      );
      expect(settings().textEditorFontSize, mpTextEditorFontSize);
    });

    test('is clamped to the allowed range', () {
      settings().setDouble(MPSettingID.TextEditor_FontSize, 1);
      expect(settings().textEditorFontSize, mpTextEditorMinFontSize);

      settings().setDouble(MPSettingID.TextEditor_FontSize, 1000);
      expect(settings().textEditorFontSize, mpTextEditorMaxFontSize);

      settings().setDouble(MPSettingID.TextEditor_FontSize, 20);
      expect(settings().textEditorFontSize, 20);
    });

    testWidgets('the editor and its gutter use the default size', (
      WidgetTester tester,
    ) async {
      await pumpEditor(tester);

      expect(fieldFontSize(tester), mpTextEditorFontSize);
      expect(gutter(tester).fontSize, mpTextEditorFontSize);
    });

    testWidgets('changing the setting resizes an open editor', (
      WidgetTester tester,
    ) async {
      await pumpEditor(tester);

      final double defaultLineHeight = gutter(tester).lineHeight;

      settings().setDouble(MPSettingID.TextEditor_FontSize, 26);
      await tester.pump();

      expect(fieldFontSize(tester), 26);
      expect(gutter(tester).fontSize, 26);
      expect(gutter(tester).lineHeight, greaterThan(defaultLineHeight * 1.5));

      settings().resetDouble(MPSettingID.TextEditor_FontSize);
      await tester.pump();

      expect(fieldFontSize(tester), mpTextEditorFontSize);
      expect(gutter(tester).lineHeight, defaultLineHeight);
    });
  });
}
