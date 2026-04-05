// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/widgets/mp_help_dialog_widget.dart';

void main() {
  test('help heading anchors match internal fragments', () {
    const String markdown = '''
## Index
## Top bar
### Bottom right corner
### Bézier curve line segments
### Bézier curve line segments
## Zoom and panning
''';

    final Map<String, int> anchors = mpBuildHelpHeadingAnchorToIndexMap(
      markdown,
    );

    expect(anchors['index'], 0);
    expect(anchors['top-bar'], 1);
    expect(anchors['bottom-right-corner'], 2);
    expect(anchors['bézier-curve-line-segments'], 3);
    expect(anchors['bézier-curve-line-segments-1'], 4);
    expect(anchors['zoom-and-panning'], 5);
  });

  test('help heading formatting is stripped before slugifying', () {
    expect(
      mpSlugifyHelpHeading(
        mpStripMarkdownFormattingFromHeading(
          '`Default options` and [Search and select](#search-and-select)',
        ),
      ),
      'default-options-and-search-and-select',
    );
  });
}
