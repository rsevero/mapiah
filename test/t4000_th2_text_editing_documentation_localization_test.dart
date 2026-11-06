// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_pt.dart';

void main() {
  final Directory projectDirectory = Directory.current;

  String projectFile(String relativePath) =>
      File('${projectDirectory.path}/$relativePath').readAsStringSync();

  Map<String, dynamic> arb(String locale) =>
      jsonDecode(projectFile('lib/l10n/intl_$locale.arb'))
          as Map<String, dynamic>;

  const List<String> textModeKeys = <String>[
    'th2EditModeTextTooltip',
    'th2EditModeCanvasTooltip',
    'th2TextLeaveBrokenFileTooltip',
    'th2TextDiscardChangesButton',
    'th2TextEditorDiscardTooltip',
    'th2TextCantApplyBanner',
    'th2TextKeepEditingButton',
    'th2TextUnsupportedLineEndingMessage',
    'th2TextDiagnosticUnsupportedLineEnding',
    'th2TextDiagnosticUnencodableCharacter',
    'th2TextDiagnosticUnreadableText',
    'th2TextDiagnosticValidationFailed',
    'mpCommandDescriptionReplaceTH2FileContents',
    'th2TextDiagnosticRemovedDuplicateLinePoint',
    'th2TextDiagnosticRemovedShortLine',
    'th2TextDiagnosticRemovedBorderOfShortLine',
    'th2TextDiagnosticRemovedEmptyArea',
    'th2TextDiagnosticRewrittenLine',
    'th2TextDiagnosticGenericRewrite',
    'th2TextDiagnosticMovedSetting',
    'th2TextDiagnosticAddedLine',
    'th2TextDiagnosticAddedEnding',
    'th2TextEditorReopenFailedMessage',
    'th2BrokenFileEditAsText',
    'th2BrokenFileEditAsTextTooltip',
    'th2BrokenFileExplanation',
    'th2BrokenFileTextUnreadableMessage',
    'th2BrokenFileTextInvalidEncodingMessage',
    'th2BrokenFileTextUnknownEncodingMessage',
    'th2ActiveScrapCantBeHiddenTooltip',
    'th2SaveAsTargetOpenMessage',
    'th2SaveAsTargetOpenEmptiedMessage',
    'mapiahTherionRunBrokenFilesWarning',
    'mapiahTherionRunBrokenFileUnsavedFix',
    'th2ElementTreeBrokenFile',
  ];

  test('EN/PT catalogs keep key parity and every text mode key is set', () {
    final Map<String, dynamic> english = arb('en');
    final Map<String, dynamic> portuguese = arb('pt');
    final Set<String> englishKeys = english.keys
        .where((String key) => !key.startsWith('@'))
        .toSet();
    final Set<String> portugueseKeys = portuguese.keys
        .where((String key) => !key.startsWith('@'))
        .toSet();

    expect(portugueseKeys, equals(englishKeys));

    for (final String key in textModeKeys) {
      expect(english[key], isA<String>(), reason: 'EN $key');
      expect((english[key] as String).trim(), isNotEmpty, reason: 'EN $key');
      expect(portuguese[key], isA<String>(), reason: 'PT $key');
      expect(
        (portuguese[key] as String).trim(),
        isNotEmpty,
        reason: 'PT $key',
      );
    }
  });

  test('text mode strings with placeholders render their arguments', () {
    for (final AppLocalizations localizations in <AppLocalizations>[
      AppLocalizationsEn(),
      AppLocalizationsPt(),
    ]) {
      expect(
        localizations.th2TextDiagnosticUnencodableCharacter('ISO8859-1'),
        contains('ISO8859-1'),
      );
      expect(localizations.th2TextDiagnosticMovedSetting(3), contains('3'));

      final String invalidEncoding = localizations
          .th2BrokenFileTextInvalidEncodingMessage('a.th2', 'ISO8859-2');

      expect(invalidEncoding, contains('a.th2'));
      expect(invalidEncoding, contains('ISO8859-2'));
      expect(
        localizations.mapiahTherionRunBrokenFileUnsavedFix('a.th2'),
        contains('a.th2'),
      );
    }
  });

  test('reviewed strings say what the user can do now', () {
    final AppLocalizationsEn en = AppLocalizationsEn();
    final AppLocalizationsPt pt = AppLocalizationsPt();

    expect(en.th2ElementTreeBrokenFile, contains('Edit as text'));
    expect(pt.th2ElementTreeBrokenFile, contains('Editar como texto'));
    expect(pt.th2ActiveScrapCantBeHiddenTooltip, contains('croqui'));
    expect(
      en.th2TextEditorReopenFailedMessage.toLowerCase(),
      isNot(contains('changes were applied')),
    );
    expect(
      pt.th2TextEditorReopenFailedMessage.toLowerCase(),
      isNot(contains('alterações foram aplicadas')),
    );
  });

  test('Run Therion help mentions the unsaved fix mark', () {
    expect(
      projectFile('assets/help/en/run_therion_help.md'),
      contains('fix not saved'),
    );
    expect(
      projectFile('assets/help/pt/run_therion_help.md'),
      contains('correção não salva'),
    );
  });

  test('TH2 help documents text mode in both locales', () {
    final Map<String, List<String>> expected = <String, List<String>>{
      'en': <String>['## Text mode', '](#text-mode)', 'Edit as text'],
      'pt': <String>['## Modo texto', '](#modo-texto)', 'Editar como texto'],
    };
    final Map<String, List<String>> forbidden = <String, List<String>>{
      'en': <String>[
        'Hiding the active scrap activates',
        'Mapiah cannot save it',
      ],
      'pt': <String>['Ao ocultar o croqui ativo', 'o Mapiah não pode salvá-lo'],
    };

    for (final String locale in <String>['en', 'pt']) {
      final String help = projectFile(
        'assets/help/$locale/th2_file_edit_page_help.md',
      );

      for (final String text in expected[locale]!) {
        expect(help, contains(text), reason: '$locale: $text');
      }
      expect(help, contains('F2'));
      for (final String text in forbidden[locale]!) {
        expect(help, isNot(contains(text)), reason: '$locale: $text');
      }
    }
  });

  test('keyboard shortcut pages list F2 in alphabetical position', () {
    for (final String locale in <String>['en', 'pt']) {
      final List<String> functions = projectFile(
        'assets/help/$locale/keyboard_shortcuts_edit.md',
      ).split('\n').where((String line) => line.startsWith('| ')).map((
        String line,
      ) {
        final List<String> cells = line.split('|');

        return '${cells[1].trim()}|${cells[2].trim()}';
      }).toList();
      final int index = functions.indexWhere(
        (String row) => row.endsWith('|F2'),
      );

      expect(index, greaterThan(1), reason: locale);
      expect(index, lessThan(functions.length - 1), reason: locale);

      String name(int i) => functions[i].split('|').first.toLowerCase();

      expect(
        name(index - 1).compareTo(name(index)),
        lessThan(0),
        reason: locale,
      );
      expect(
        name(index).compareTo(name(index + 1)),
        lessThan(0),
        reason: locale,
      );
    }
  });
}
