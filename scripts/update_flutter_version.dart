#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

/// Script: update_flutter_version.dart
/// Usage: dart run scripts/update_flutter_version.dart
///
/// Detects the installed Flutter SDK framework version and replaces
/// occurrences of `flutter-version:` and `flutter:` in workflow and
/// CI files listed below.

final List<String> targetFiles = [
  '.github/workflows/linux-appimage.yml',
  '.github/workflows/linux-flatpak.yml',
  '.github/workflows/windows.yml',
  'codemagic.yaml',
];

Future<int> main(List<String> args) async {
  final version = await getFlutterVersion();

  if (version == null) {
    stderr.writeln('Could not determine Flutter version.');

    return 2;
  }

  stdout.writeln('Detected Flutter framework version: $version');

  var changedFiles = <String>[];

  final flutterVersionRegex = RegExp(
    r"""(^\s*flutter-version:\s*)(["\']?)[0-9]+(?:\.[0-9]+)*(["\']?)""",
    multiLine: true,
  );
  final flutterSimpleRegex = RegExp(
    r"""(^\s*flutter:\s*)(["\']?)[0-9]+(?:\.[0-9]+)*(["\']?)""",
    multiLine: true,
  );

  for (final path in targetFiles) {
    final file = File(path);

    if (!await file.exists()) {
      continue;
    }
    var content = await file.readAsString();
    var newContent = content;

    newContent = newContent.replaceAllMapped(
      flutterVersionRegex,
      (m) => '${m[1]}$version',
    );
    newContent = newContent.replaceAllMapped(
      flutterSimpleRegex,
      (m) => '${m[1]}$version',
    );

    if (newContent != content) {
      await file.writeAsString(newContent);
      changedFiles.add(path);
      stdout.writeln('Updated: $path');
    } else {
      stdout.writeln('No change: $path');
    }
  }

  stdout.writeln('\nSummary:');
  stdout.writeln('Flutter version: $version');
  stdout.writeln(
    'Files updated: ${changedFiles.isEmpty ? 'none' : changedFiles.join(', ')}',
  );
  return 0;
}

/// Attempts to get the Flutter framework version. Prefer machine-readable
/// output, fallback to parsing human output.
Future<String?> getFlutterVersion() async {
  try {
    final result = await Process.run('flutter', ['--version', '--machine']);

    if (result.exitCode == 0) {
      final out = result.stdout.toString();
      final map = json.decode(out);

      if (map is Map && map['frameworkVersion'] is String) {
        return (map['frameworkVersion'] as String).trim();
      }
    }
  } catch (_) {
    // ignore and try fallback
  }

  // Fallback: parse `flutter --version` first line like "Flutter 3.38.7 • channel stable"
  try {
    final result = await Process.run('flutter', ['--version']);

    if (result.exitCode == 0) {
      final firstLine = result.stdout
          .toString()
          .split('\n')
          .firstWhere((_) => true, orElse: () => '');
      final match = RegExp(
        r"""Flutter\s+([0-9]+(?:\.[0-9]+)+)""",
      ).firstMatch(firstLine);

      if (match != null) {
        return match.group(1);
      }
    }
  } catch (_) {
    // give up
  }

  return null;
}
