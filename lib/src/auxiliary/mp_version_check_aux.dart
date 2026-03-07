import 'package:mapiah/src/constants/mp_constants.dart';

class MPVersionCheckResult {
  final String? latestStableTagName;
  final String? latestStableVersion;
  final int newerVersionCount;

  const MPVersionCheckResult({
    required this.latestStableTagName,
    required this.latestStableVersion,
    required this.newerVersionCount,
  });

  bool get hasNewerVersion =>
      (newerVersionCount > 0) &&
      (latestStableTagName != null) &&
      (latestStableVersion != null);

  bool get hasStableVersion =>
      (latestStableTagName != null) && (latestStableVersion != null);
}

int countNewerVersions({
  required List<dynamic> tags,
  required String currentVersion,
}) {
  final MPVersionCheckResult? versionCheckResult = summarizeNewerVersions(
    tags: tags,
    currentVersion: currentVersion,
  );

  return versionCheckResult?.newerVersionCount ?? 0;
}

MPVersionCheckResult? summarizeNewerVersions({
  required List<dynamic> tags,
  required String currentVersion,
}) {
  final _MPSemanticVersion? parsedCurrentVersion = _MPSemanticVersion.tryParse(
    input: currentVersion,
    pattern: mpMapiahStableReleaseTagPattern,
  );

  if (parsedCurrentVersion == null) {
    return null;
  }

  int newerVersionCount = 0;
  String? latestStableTagName;
  String? latestStableVersion;
  _MPSemanticVersion? latestParsedStableVersion;

  for (final dynamic tag in tags) {
    if (tag is! Map<Object?, Object?>) {
      continue;
    }

    final Object? rawTagName = tag['name'];
    final String tagName = rawTagName?.toString().trim() ?? '';
    final _MPSemanticVersion? parsedTagVersion = _MPSemanticVersion.tryParse(
      input: tagName,
      pattern: mpMapiahStableReleaseTagPattern,
    );

    if (parsedTagVersion == null) {
      continue;
    }

    final bool isNewLatestStableVersion =
        (latestParsedStableVersion == null) ||
        (parsedTagVersion.compareTo(latestParsedStableVersion) > 0);

    if (isNewLatestStableVersion) {
      latestParsedStableVersion = parsedTagVersion;
      latestStableTagName = tagName;
      latestStableVersion = parsedTagVersion.asString;
    }

    if (parsedTagVersion.compareTo(parsedCurrentVersion) > 0) {
      newerVersionCount += 1;
    }
  }

  return MPVersionCheckResult(
    latestStableTagName: latestStableTagName,
    latestStableVersion: latestStableVersion,
    newerVersionCount: newerVersionCount,
  );
}

class _MPSemanticVersion implements Comparable<_MPSemanticVersion> {
  final int major;
  final int minor;
  final int patch;

  const _MPSemanticVersion({
    required this.major,
    required this.minor,
    required this.patch,
  });

  String get asString => '$major.$minor.$patch';

  static _MPSemanticVersion? tryParse({
    required String input,
    required String pattern,
  }) {
    final String trimmedInput = input.trim();
    final RegExp versionRegex = RegExp(pattern);
    final RegExpMatch? match = versionRegex.firstMatch(trimmedInput);

    if ((match == null) ||
        (match.groupCount < mpSemanticVersionComponentCount)) {
      return null;
    }

    final int? major = int.tryParse(match.group(1) ?? '');
    final int? minor = int.tryParse(match.group(2) ?? '');
    final int? patch = int.tryParse(match.group(3) ?? '');

    if ((major == null) || (minor == null) || (patch == null)) {
      return null;
    }

    return _MPSemanticVersion(major: major, minor: minor, patch: patch);
  }

  @override
  int compareTo(_MPSemanticVersion other) {
    final int majorComparison = major.compareTo(other.major);

    if (majorComparison != 0) {
      return majorComparison;
    }

    final int minorComparison = minor.compareTo(other.minor);

    if (minorComparison != 0) {
      return minorComparison;
    }

    return patch.compareTo(other.patch);
  }
}
