// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_pt.dart';

void main() {
  final Directory projectDirectory = Directory.current;

  String projectFile(String relativePath) =>
      File('${projectDirectory.path}/$relativePath').readAsStringSync();

  test('English and Portuguese catalogs have exact message-key parity', () {
    final Map<String, dynamic> english = jsonDecode(
      projectFile('lib/l10n/intl_en.arb'),
    ) as Map<String, dynamic>;
    final Map<String, dynamic> portuguese = jsonDecode(
      projectFile('lib/l10n/intl_pt.arb'),
    ) as Map<String, dynamic>;
    final Set<String> englishKeys = english.keys
        .where((String key) => !key.startsWith('@'))
        .toSet();
    final Set<String> portugueseKeys = portuguese.keys
        .where((String key) => !key.startsWith('@'))
        .toSet();

    expect(portugueseKeys, equals(englishKeys));
  });

  test('project workflow labels render in both locales', () {
    final AppLocalizationsEn english = AppLocalizationsEn();
    final AppLocalizationsPt portuguese = AppLocalizationsPt();

    expect(english.projectTreeOpenProjectButton, isNotEmpty);
    expect(english.projectTreeErrorSummary(2), contains('2'));
    expect(english.thProjectSaveFailed('/tmp/file.th', 'reason'), contains('reason'));
    expect(portuguese.projectTreeOpenProjectButton, isNotEmpty);
    expect(portuguese.projectTreeErrorSummary(2), contains('2'));
    expect(portuguese.thProjectSaveFailed('/tmp/file.th', 'motivo'), contains('motivo'));
  });

  test('registered help pages exist in both locales and contain current actions', () {
    final String pubspec = projectFile('pubspec.yaml');
    final List<String> helpPages = <String>[
      'keyboard_shortcuts_edit',
      'keyboard_shortcuts_main',
      'mapiah_home_help',
      'mp_settings_page_help',
      'no_therion_found',
      'run_therion_help',
      'telemetry_consent',
      'telemetry',
      'th2_file_edit_page_help',
    ];

    for (final String helpPage in helpPages) {
      for (final String locale in <String>['en', 'pt']) {
        final String assetPath = 'assets/help/$locale/$helpPage.md';
        expect(File('${projectDirectory.path}/$assetPath').existsSync(), isTrue);
        expect(pubspec, contains('    - $assetPath'));
      }
    }

    for (final String locale in <String>['en', 'pt']) {
      final String home = projectFile('assets/help/$locale/mapiah_home_help.md');
      final String run = projectFile('assets/help/$locale/run_therion_help.md');
      final String shortcuts = projectFile(
        'assets/help/$locale/keyboard_shortcuts_main.md',
      );
      final String edit = projectFile(
        'assets/help/$locale/keyboard_shortcuts_edit.md',
      );

      expect(home, isNot(contains('Choose THConfig')));
      expect(home, isNot(contains('Escolher THConfig')));
      expect(run, isNot(contains('choose a different THConfig')));
      expect(run, isNot(contains('escolher um arquivo diferente')));
      expect(shortcuts, isNot(contains('Choose THConfig')));
      expect(shortcuts, isNot(contains('Escolher arquivo THConfig')));
      expect(edit, isNot(contains('Choose THConfig')));
      expect(edit, isNot(contains('Escolher arquivo THConfig')));
      expect(home, contains('Ctrl/Cmd+O'));
      expect(home, isNot(contains('Ctrl/Cmd+O opens standalone')));
      expect(home, contains('--th2'));
    }
  });
}
