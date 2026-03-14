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
  final String? version = await getFlutterVersion();
  final String? mapiahVersion = await getMapiahVersion();
  final ({String name, String url})? releaseInfo = await getChangelogReleaseInfo();

  if (version == null) {
    stderr.writeln('Could not determine Flutter version.');

    return 2;
  }
  if (mapiahVersion == null) {
    stderr.writeln('Could not determine Mapiah version from pubspec.yaml.');

    return 2;
  }
  if (releaseInfo == null) {
    stderr.writeln('Could not read CHANGELOG.md.');

    return 2;
  }

  stdout.writeln('Detected Flutter framework version: $version');
  stdout.writeln('Detected Mapiah version: $mapiahVersion');
  stdout.writeln('Detected release name: "${releaseInfo.name}"');
  stdout.writeln('Detected release URL: "${releaseInfo.url}"');

  List<String> changedFiles = <String>[];

  final RegExp flutterVersionRegex = RegExp(
    r"""(^\s*flutter-version:\s*)(["\']?)[0-9]+(?:\.[0-9]+)*(["\']?)""",
    multiLine: true,
  );
  final RegExp flutterSimpleRegex = RegExp(
    r"""(^\s*flutter:\s*)(["\']?)[0-9]+(?:\.[0-9]+)*(["\']?)""",
    multiLine: true,
  );

  for (final path in targetFiles) {
    final File file = File(path);

    if (!await file.exists()) {
      continue;
    }

    String content = await file.readAsString();
    String newContent = content;

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

  final bool constantsUpdated = await updateReleaseConstants(
    releaseName: releaseInfo.name,
    releaseURL: releaseInfo.url,
  );

  if (constantsUpdated) {
    stdout.writeln(
      'Updated: lib/src/constants/mp_constants.dart (mpReleaseName, mpReleaseURL)',
    );
  } else {
    stdout.writeln(
      'No change: lib/src/constants/mp_constants.dart (mpReleaseName, mpReleaseURL)',
    );
  }

  stdout.writeln('\nSummary:');
  stdout.writeln('Flutter version: $version');
  stdout.writeln('Mapiah version: $mapiahVersion');
  stdout.writeln('Release name: "${releaseInfo.name}"');
  stdout.writeln('Release URL: "${releaseInfo.url}"');
  stdout.writeln(
    'Files updated: ${changedFiles.isEmpty ? 'none' : changedFiles.join(', ')}',
  );
  // Run the release brief generator as the last step
  try {
    final ProcessResult genResult = await Process.run('dart', [
      'run',
      'scripts/generate_releases_brief.dart',
    ]);

    if (genResult.exitCode != 0) {
      stderr.writeln(
        'scripts/generate_releases_brief.dart failed:\n${genResult.stderr}',
      );
      return genResult.exitCode;
    }

    stdout.writeln('Ran scripts/generate_releases_brief.dart successfully.');
  } catch (e) {
    stderr.writeln('Failed to run scripts/generate_releases_brief.dart: $e');
    return 2;
  }

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

/// Reads the top entry of CHANGELOG.md and extracts the release name
/// (between square brackets) and optional URL (between parentheses) from a
/// line like:
/// `## 0.3.1 - 2026-03-13 - The [Release Name](https://example.com) release`
/// or:
/// `## 0.3.1 - 2026-03-13 - The [Release Name] release`
/// Returns a record with empty strings if no such pattern is found.
Future<({String name, String url})?> getChangelogReleaseInfo() async {
  final File changelog = File('CHANGELOG.md');

  if (!await changelog.exists()) {
    return null;
  }

  final String content = await changelog.readAsString();
  final RegExp sectionRegex = RegExp(r'^## .+$', multiLine: true);
  final RegExpMatch? firstSection = sectionRegex.firstMatch(content);

  if (firstSection == null) {
    return (name: '', url: '');
  }

  final String firstLine = firstSection.group(0)!;
  final RegExpMatch? nameUrlMatch = RegExp(
    r'\[([^\]]+)\]\(([^)]+)\)',
  ).firstMatch(firstLine);

  if (nameUrlMatch != null) {
    return (name: nameUrlMatch.group(1)!, url: nameUrlMatch.group(2)!);
  }

  final RegExpMatch? nameOnlyMatch = RegExp(
    r'\[([^\]]+)\]',
  ).firstMatch(firstLine);

  if (nameOnlyMatch != null) {
    return (name: nameOnlyMatch.group(1)!, url: '');
  }

  return (name: '', url: '');
}

/// Updates mpReleaseName and mpReleaseURL constants in mp_constants.dart.
/// Returns true if the file was changed.
Future<bool> updateReleaseConstants({
  required String releaseName,
  required String releaseURL,
}) async {
  final File constantsFile = File('lib/src/constants/mp_constants.dart');

  if (!await constantsFile.exists()) {
    stderr.writeln('Could not find lib/src/constants/mp_constants.dart.');

    return false;
  }

  final String content = await constantsFile.readAsString();
  String newContent = content;

  newContent = newContent.replaceFirstMapped(
    RegExp(r"(const String mpReleaseName = ')(.*)(';)"),
    (m) => "${m[1]}$releaseName${m[3]}",
  );
  newContent = newContent.replaceFirstMapped(
    RegExp(r"(const String mpReleaseURL = ')(.*)(';)"),
    (m) => "${m[1]}$releaseURL${m[3]}",
  );

  if (newContent == content) {
    return false;
  }

  await constantsFile.writeAsString(newContent);

  return true;
}
