// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:flutter_test/flutter_test.dart';

// The script is outside lib and therefore has no package import URI.
// ignore: always_use_package_imports
import '../scripts/update_flutter_and_mapiah_version.dart';

void main() {
  test('updates quoted workflow and CI Flutter versions', () {
    const String content = '''
flutter-version: '3.41.3'
flutter: "3.41.3"
''';

    final String updated = updateFlutterCiContent(content, '3.44.6');

    expect(updated, '''
flutter-version: '3.44.6'
flutter: "3.44.6"
''');
  });

  test('updates the Flutter Git tag in the Flatpak manifest', () {
    const String content = '''
      - type: git
        url: https://example.com/dependency.git
        tag: 1.2.3
        dest: dependency
      - type: git
        url: https://github.com/flutter/flutter.git
        tag: 3.41.3
        dest: flutter
''';

    final String updated = updateFlutterFlatpakManifestContent(
      content,
      '3.44.6',
    );

    expect(updated, '''
      - type: git
        url: https://example.com/dependency.git
        tag: 1.2.3
        dest: dependency
      - type: git
        url: https://github.com/flutter/flutter.git
        tag: 3.44.6
        dest: flutter
''');
  });
}
