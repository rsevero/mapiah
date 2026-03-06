import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_version_check_aux.dart';

void main() {
  group('countNewerVersions', () {
    test('counts only newer stable tags', () {
      final List<dynamic> tags = <dynamic>[
        <String, dynamic>{'name': 'v0.2.42'},
        <String, dynamic>{'name': 'v0.2.41'},
        <String, dynamic>{'name': 'v0.2.40-rc11'},
        <String, dynamic>{'name': 'v0.2.40'},
        <String, dynamic>{'name': 'v0.2.39'},
      ];

      final int newerVersionCount = countNewerVersions(
        tags: tags,
        currentVersion: '0.2.40',
      );

      expect(newerVersionCount, 2);
    });

    test('returns zero when current version is not stable', () {
      final List<dynamic> tags = <dynamic>[
        <String, dynamic>{'name': 'v0.2.41'},
      ];

      final int newerVersionCount = countNewerVersions(
        tags: tags,
        currentVersion: '0.2.40-rc11',
      );

      expect(newerVersionCount, 0);
    });
  });

  group('summarizeNewerVersions', () {
    test('tracks the latest stable tag and ignores invalid tags', () {
      final List<dynamic> tags = <dynamic>[
        <String, dynamic>{'name': 'v0.2.41'},
        <String, dynamic>{'name': 'v0.2.43-rc1'},
        <String, dynamic>{'name': 'v0.2.42'},
        <String, dynamic>{'name': 'invalid'},
      ];

      final MPVersionCheckResult? versionCheckResult = summarizeNewerVersions(
        tags: tags,
        currentVersion: '0.2.40',
      );

      expect(versionCheckResult, isNotNull);
      expect(versionCheckResult!.latestStableTagName, 'v0.2.42');
      expect(versionCheckResult.latestStableVersion, '0.2.42');
      expect(versionCheckResult.newerVersionCount, 2);
    });
  });
}
