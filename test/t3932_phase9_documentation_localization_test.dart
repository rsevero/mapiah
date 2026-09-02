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

  test('EN/PT catalogs keep exact key parity including Phase 9 keys', () {
    final Map<String, dynamic> english =
        jsonDecode(projectFile('lib/l10n/intl_en.arb')) as Map<String, dynamic>;
    final Map<String, dynamic> portuguese =
        jsonDecode(projectFile('lib/l10n/intl_pt.arb')) as Map<String, dynamic>;
    final Set<String> englishKeys = english.keys
        .where((String key) => !key.startsWith('@'))
        .toSet();
    final Set<String> portugueseKeys = portuguese.keys
        .where((String key) => !key.startsWith('@'))
        .toSet();

    expect(portugueseKeys, equals(englishKeys));

    for (final String key in <String>[
      'projectSearchTitle',
      'projectSearchScopeOpenTabs',
      'projectSearchScopeProjectFiles',
      'projectSearchStandaloneIndicator',
      'projectSearchReplaceConfirmBody',
      'projectSearchReplaceCompleteMaterialized',
    ]) {
      expect(englishKeys, contains(key));
      expect(portugueseKeys, contains(key));
    }
  });

  test('Phase 9 localized strings render in both locales', () {
    final AppLocalizationsEn en = AppLocalizationsEn();
    final AppLocalizationsPt pt = AppLocalizationsPt();

    expect(en.projectSearchTitle, isNotEmpty);
    expect(pt.projectSearchTitle, isNotEmpty);
    expect(en.projectSearchSummary(23, 4), contains('23'));
    expect(pt.projectSearchSummary(23, 4), contains('23'));
    expect(en.projectSearchSummary(1, 1), contains('1'));
    expect(en.projectSearchMatchLocation(12, 5), contains('12'));
    expect(pt.projectSearchMatchLocation(12, 5), contains('12'));
    expect(en.projectSearchReplaceConfirmBody(5, 2), contains('5'));
    expect(pt.projectSearchReplaceConfirmBody(5, 2), contains('5'));
    expect(en.projectSearchReplaceCompleteMaterialized(2), contains('2'));
  });

  test('keyboard-shortcut help documents both find shortcuts in both locales', () {
    for (final String locale in <String>['en', 'pt']) {
      final String edit = projectFile(
        'assets/help/$locale/keyboard_shortcuts_edit.md',
      );

      expect(edit, contains('Ctrl+F'));
      expect(edit, contains('Ctrl+Shift+F'));
      // .th2 is documented as never searched.
      expect(edit.toLowerCase(), contains('.th2'));
      // Replace All save/undo behavior is documented.
      expect(
        RegExp('undo|desfazer', caseSensitive: false).hasMatch(edit),
        isTrue,
      );
      // Standalone/search-only tabs are documented as navigable but excluded.
      expect(
        RegExp(
          'search only|somente pesquisa',
          caseSensitive: false,
        ).hasMatch(edit),
        isTrue,
      );
      // No claim that .th2 IS searched.
      expect(
        edit.toLowerCase().contains('.th2 files are searched'),
        isFalse,
      );
    }
  });
}
