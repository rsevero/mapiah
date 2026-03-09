#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

/// Generates `assets/releases/releases_summary.json` from local git tags.
///
/// - Considers tags that match `vX.Y.Z` (only three numeric components).
/// - Uses the tagger date for annotated tags, otherwise the commit date.
/// - Counts commits between consecutive releases. For the oldest release
///   the count is the number of commits up to that tag.

Future<int> main(List<String> args) async {
  try {
    final List<Release> releases = await _collectReleases();
    final List<Map<String, dynamic>> out = <Map<String, dynamic>>[];

    for (final Release r in releases) {
      final Map<String, dynamic> entry = <String, dynamic>{
        'name': r.name,
        'datetime': r.date.toUtc().toIso8601String(),
        'commits': r.commits,
      };

      out.add(entry);
    }

    final File file = File('assets/releases/releases_summary.json');
    if (await file.exists()) {
      await file.delete();
    }
    await file.create(recursive: true);
    final String jsonText = const JsonEncoder.withIndent('  ').convert(out);
    await file.writeAsString(jsonText);
    stdout.writeln('Wrote ${out.length} releases to ${file.path}');
    return 0;
  } catch (e, st) {
    stderr.writeln('Error: $e');
    stderr.writeln(st);
    return 2;
  }
}

class Release {
  Release({
    required this.name,
    required this.date,
    required this.sha,
    required this.commits,
  });

  final String name;
  final DateTime date;
  final String sha;
  int commits;
}

Future<List<Release>> _collectReleases() async {
  final List<String> tagNames = await _gitTagList();
  final RegExp tagPattern = RegExp(r'^v\d+\.\d+\.\d+$');

  final List<Release> releasesRaw = <Release>[];

  for (final String t in tagNames) {
    if (!tagPattern.hasMatch(t)) {
      continue;
    }

    final String? sha = await _gitRevParse(t);
    if (sha == null || sha.isEmpty) {
      continue;
    }

    final bool annotated = await _isAnnotatedTag(t);
    DateTime? date;

    if (annotated) {
      final String? tagDate = await _gitForEachRefTaggerDate(t);
      if (tagDate != null && tagDate.isNotEmpty) {
        date = DateTime.parse(tagDate);
      }
    }

    if (date == null) {
      final String? commitDate = await _gitCommitDate(sha);
      if (commitDate != null && commitDate.isNotEmpty) {
        date = DateTime.parse(commitDate);
      }
    }

    if (date == null) {
      // Skip tags we couldn't determine a date for.
      continue;
    }

    final Release r = Release(name: t, date: date, sha: sha, commits: 0);
    releasesRaw.add(r);
  }

  // Sort by date descending (newest first)
  releasesRaw.sort((Release a, Release b) => b.date.compareTo(a.date));

  // Compute commits between releases
  for (int i = 0; i < releasesRaw.length; i++) {
    final Release current = releasesRaw[i];

    if (i + 1 < releasesRaw.length) {
      final Release previous = releasesRaw[i + 1];
      final int? count = await _gitCountCommitsBetween(
        previous.name,
        current.name,
      );
      current.commits = count ?? 0;
    } else {
      final int? count = await _gitCountCommitsUpTo(current.name);
      current.commits = count ?? 0;
    }
  }

  return releasesRaw;
}

Future<List<String>> _gitTagList() async {
  final ProcessResult result = await Process.run('git', <String>[
    'tag',
    '--list',
  ]);
  if (result.exitCode != 0) {
    throw Exception('git tag failed: ${result.stderr}');
  }

  final String out = (result.stdout as String).toString();
  final List<String> lines = out
      .split('\n')
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList();
  return lines;
}

Future<String?> _gitRevParse(String ref) async {
  final ProcessResult result = await Process.run('git', <String>[
    'rev-parse',
    '--verify',
    ref,
  ]);
  if (result.exitCode != 0) {
    return null;
  }

  return (result.stdout as String).toString().trim();
}

Future<bool> _isAnnotatedTag(String tag) async {
  final ProcessResult result = await Process.run('git', <String>[
    'cat-file',
    '-t',
    tag,
  ]);
  if (result.exitCode != 0) {
    return false;
  }

  final String type = (result.stdout as String).toString().trim();
  return type == 'tag';
}

Future<String?> _gitForEachRefTaggerDate(String tag) async {
  final String ref = 'refs/tags/$tag';
  final ProcessResult result = await Process.run('git', <String>[
    'for-each-ref',
    '--format=%(taggerdate:iso8601)',
    ref,
  ]);

  if (result.exitCode != 0) {
    return null;
  }

  final String out = (result.stdout as String).toString().trim();
  if (out.isEmpty) {
    return null;
  }

  return out;
}

Future<String?> _gitCommitDate(String sha) async {
  final ProcessResult result = await Process.run('git', <String>[
    'show',
    '-s',
    '--format=%cI',
    sha,
  ]);
  if (result.exitCode != 0) {
    return null;
  }

  final String out = (result.stdout as String).toString().trim();
  if (out.isEmpty) {
    return null;
  }

  return out;
}

Future<int?> _gitCountCommitsBetween(String olderRef, String newerRef) async {
  final ProcessResult result = await Process.run('git', <String>[
    'rev-list',
    '--count',
    '$olderRef..$newerRef',
  ]);
  if (result.exitCode != 0) {
    return null;
  }

  final String out = (result.stdout as String).toString().trim();
  return int.tryParse(out);
}

Future<int?> _gitCountCommitsUpTo(String ref) async {
  final ProcessResult result = await Process.run('git', <String>[
    'rev-list',
    '--count',
    ref,
  ]);
  if (result.exitCode != 0) {
    return null;
  }

  final String out = (result.stdout as String).toString().trim();
  return int.tryParse(out);
}
