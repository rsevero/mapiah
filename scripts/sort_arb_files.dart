#!/usr/bin/env dart
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:convert';
import 'dart:io';

/// Script: sort_arb_files.dart
/// Usage: dart run scripts/sort_arb_files.dart
///
/// Sorts the entries of lib/l10n/intl_en.arb and lib/l10n/intl_pt.arb
/// alphabetically by key. The @@locale entry is always kept first.
/// In intl_en.arb, each entry's @key metadata block is kept immediately
/// after the entry it belongs to.

const List<String> arbFiles = ['lib/l10n/intl_en.arb', 'lib/l10n/intl_pt.arb'];

void main() {
  bool anyChanged = false;

  for (final String filePath in arbFiles) {
    final bool changed = _sortArbFile(filePath);

    if (changed) {
      anyChanged = true;
    }
  }

  if (anyChanged) {
    _runFlutterGenL10n();
  } else {
    stdout.writeln('No changes detected, skipping flutter gen-l10n.');
  }
}

void _runFlutterGenL10n() {
  final ProcessResult result = Process.runSync('flutter', [
    'gen-l10n',
  ], runInShell: true);

  if (result.stdout.toString().isNotEmpty) {
    stdout.write(result.stdout);
  }

  if (result.stderr.toString().isNotEmpty) {
    stderr.write(result.stderr);
  }

  if (result.exitCode != 0) {
    stderr.writeln('flutter gen-l10n failed with exit code ${result.exitCode}');
    exit(result.exitCode);
  }

  stdout.writeln('flutter gen-l10n completed successfully');
}

bool _sortArbFile(String filePath) {
  final File file = File(filePath);

  if (!file.existsSync()) {
    stderr.writeln('File not found: $filePath');
    exit(1);
  }

  final String content = file.readAsStringSync();
  final Map<String, dynamic> arb = jsonDecode(content) as Map<String, dynamic>;

  final Map<String, dynamic> sorted = _sortedArb(arb);
  final String output = _encodeArb(sorted);

  if (output == content) {
    stdout.writeln('No changes: $filePath');

    return false;
  }

  file.writeAsStringSync(output);
  stdout.writeln('Sorted: $filePath');

  return true;
}

Map<String, dynamic> _sortedArb(Map<String, dynamic> arb) {
  final Map<String, dynamic> result = <String, dynamic>{};

  // @@locale always comes first.
  if (arb.containsKey('@@locale')) {
    result['@@locale'] = arb['@@locale'];
  }

  // Collect all regular (non-@) keys and sort them.
  final List<String> regularKeys =
      arb.keys.where((String k) => !k.startsWith('@')).toList()..sort();

  for (final String key in regularKeys) {
    result[key] = arb[key];

    // Keep @key metadata immediately after the entry it belongs to.
    final String metaKey = '@$key';

    if (arb.containsKey(metaKey)) {
      result[metaKey] = arb[metaKey];
    }
  }

  // Append any orphaned @-prefixed keys (those without a matching regular key).
  for (final String key in arb.keys) {
    if (!key.startsWith('@') || key == '@@locale') {
      continue;
    }

    final String baseKey = key.substring(1);

    if (!arb.containsKey(baseKey)) {
      result[key] = arb[key];
    }
  }

  return result;
}

String _encodeArb(Map<String, dynamic> arb) {
  final StringBuffer buffer = StringBuffer();

  buffer.writeln('{');

  final List<String> keys = arb.keys.toList();

  for (int i = 0; i < keys.length; i++) {
    final String key = keys[i];
    final dynamic value = arb[key];
    final bool isLast = (i == keys.length - 1);
    final String comma = isLast ? '' : ',';

    if (value is String) {
      buffer.writeln('  ${_jsonKey(key)}: ${_jsonString(value)}$comma');
    } else if (value is Map) {
      buffer.write('  ${_jsonKey(key)}: ');
      _writeJsonObject(buffer, value as Map<String, dynamic>, indent: '  ');
      buffer.writeln(comma);
    } else {
      buffer.writeln('  ${_jsonKey(key)}: ${jsonEncode(value)}$comma');
    }
  }

  buffer.writeln('}');

  return buffer.toString();
}

void _writeJsonObject(
  StringBuffer buffer,
  Map<String, dynamic> obj, {
  required String indent,
}) {
  if (obj.isEmpty) {
    buffer.write('{}');

    return;
  }

  buffer.writeln('{');

  final List<String> keys = obj.keys.toList();

  for (int i = 0; i < keys.length; i++) {
    final String key = keys[i];
    final dynamic value = obj[key];
    final bool isLast = (i == keys.length - 1);
    final String comma = isLast ? '' : ',';
    final String childIndent = '$indent  ';

    if (value is String) {
      buffer.writeln(
        '$childIndent${_jsonKey(key)}: ${_jsonString(value)}$comma',
      );
    } else if (value is Map) {
      buffer.write('$childIndent${_jsonKey(key)}: ');
      _writeJsonObject(
        buffer,
        value as Map<String, dynamic>,
        indent: childIndent,
      );
      buffer.writeln(comma);
    } else {
      buffer.writeln(
        '$childIndent${_jsonKey(key)}: ${jsonEncode(value)}$comma',
      );
    }
  }

  buffer.write('$indent}');
}

String _jsonKey(String key) => '"$key"';

String _jsonString(String value) {
  // jsonEncode handles all escaping correctly.
  return jsonEncode(value);
}
