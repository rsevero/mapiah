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
  'packaging/linux/flatpak/built-on-flathub/io.github.rsevero.mapiah/flatpak-flutter.yml',
  '.github/workflows/windows.yml',
  'codemagic.yaml',
  'packaging/linux/io.github.rsevero.mapiah.metainfo.xml',
];

Future<int> main(List<String> args) async {
  final String? version = await getFlutterVersion();
  final String? mapiahVersion = await getMapiahVersion();
  final String today = DateTime.now().toIso8601String().split('T').first;

  if (version == null) {
    stderr.writeln('Could not determine Flutter version.');

    return 2;
  }
  if (mapiahVersion == null) {
    stderr.writeln('Could not determine Mapiah version from pubspec.yaml.');

    return 2;
  }

  stdout.writeln('Detected Flutter framework version: $version');
  stdout.writeln('Detected Mapiah version: $mapiahVersion');

  List<String> changedFiles = <String>[];

  final RegExp flutterVersionRegex = RegExp(
    r"""(^\s*flutter-version:\s*)(["\']?)[0-9]+(?:\.[0-9]+)*(["\']?)""",
    multiLine: true,
  );
  final RegExp flutterSimpleRegex = RegExp(
    r"""(^\s*flutter:\s*)(["\']?)[0-9]+(?:\.[0-9]+)*(["\']?)""",
    multiLine: true,
  );
  final RegExp flutterFlatpakTagRegex = RegExp(
    r"""(url:\s*https://github.com/flutter/flutter\.git\s*\n(?:.*?\n)*?\s*tag:\s*)([^\n]+)""",
    multiLine: true,
    dotAll: true,
  );
  final RegExp mapiahFlatpakTagRegex = RegExp(
    r"""(url:\s*https://github.com/rsevero/mapiah\.git\s*\n(?:.*?\n)*?\s*tag:\s*)([^\n]+)""",
    multiLine: true,
    dotAll: true,
  );
  final RegExp flatpakCommitRegex = RegExp(
    r"""^\s*commit:\s*.*\n""",
    multiLine: true,
  );
  final RegExp releasesBlockRegex = RegExp(
    r"""(<releases>\s*\n)""",
    multiLine: true,
  );

  for (final path in targetFiles) {
    final File file = File(path);

    if (!await file.exists()) {
      continue;
    }

    String content = await file.readAsString();
    String newContent = content;

    if (path.endsWith('flatpak-flutter.yml')) {
      newContent = newContent.replaceAllMapped(
        flutterFlatpakTagRegex,
        (m) => '${m[1]}$version',
      );
      final String mapiahTag = 'v${mapiahVersion.split('+').first}';
      newContent = newContent.replaceAllMapped(
        mapiahFlatpakTagRegex,
        (m) => '${m[1]}$mapiahTag',
      );
      newContent = newContent.replaceAll(flatpakCommitRegex, '');
    } else if (path.endsWith('io.github.rsevero.mapiah.metainfo.xml')) {
      final RegExp releaseVersionRegex = RegExp(
        '<release\\b[^>]*\\bversion\\s*=\\s*"${RegExp.escape(mapiahVersion)}"',
      );

      if (!releaseVersionRegex.hasMatch(newContent)) {
        final String releaseEntry =
            '    <release version="$mapiahVersion" date="$today">\n'
            '      <description>\n'
            '        <p>Release description</p>\n'
            '      </description>\n'
            '    </release>\n';
        if (releasesBlockRegex.hasMatch(newContent)) {
          newContent = newContent.replaceFirstMapped(
            releasesBlockRegex,
            (m) => '${m[1]}$releaseEntry',
          );
        }
      }
    } else {
      newContent = newContent.replaceAllMapped(
        flutterVersionRegex,
        (m) => '${m[1]}$version',
      );
      newContent = newContent.replaceAllMapped(
        flutterSimpleRegex,
        (m) => '${m[1]}$version',
      );
    }

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
  stdout.writeln('Mapiah version: $mapiahVersion');
  stdout.writeln(
    'Files updated: ${changedFiles.isEmpty ? 'none' : changedFiles.join(', ')}',
  );
  return 0;
}

Future<String?> getMapiahVersion() async {
  final File pubspec = File('pubspec.yaml');

  if (!await pubspec.exists()) {
    return null;
  }

  final String content = await pubspec.readAsString();
  final RegExpMatch? match = RegExp(
    r'^version:\s*([^\s]+)\s*$',
    multiLine: true,
  ).firstMatch(content);

  return match?.group(1);
}

/// Attempts to get the Flutter framework version. Prefer machine-readable
/// output, fallback to parsing human output.
Future<String?> getFlutterVersion() async {
  try {
    final ProcessResult result = await Process.run('flutter', [
      '--version',
      '--machine',
    ]);

    if (result.exitCode == 0) {
      final String out = result.stdout.toString();
      final dynamic map = json.decode(out);

      if (map is Map && map['frameworkVersion'] is String) {
        return (map['frameworkVersion'] as String).trim();
      }
    }
  } catch (_) {
    // ignore and try fallback
  }

  // Fallback: parse `flutter --version` first line like "Flutter 3.38.7 • channel stable"
  try {
    final ProcessResult result = await Process.run('flutter', ['--version']);

    if (result.exitCode == 0) {
      final String firstLine = result.stdout
          .toString()
          .split('\n')
          .firstWhere((_) => true, orElse: () => '');
      final RegExpMatch? match = RegExp(
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
