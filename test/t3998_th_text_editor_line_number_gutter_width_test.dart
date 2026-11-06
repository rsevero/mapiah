// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_diagnostic.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/widgets/th_text_editor_line_number_gutter_widget.dart';
import 'package:material_ui/material_ui.dart';

import 'th_test_aux.dart';

/// The line-number gutter is wide enough for its widest number, the bold
/// current line's included, next to a diagnostic dot.
void main() {
  THTestAux.ensureTestEnvironment();

  setUpAll(() async {
    final FontLoader loader = FontLoader(mpMonospaceFontFamily);

    for (final String file in <String>[
      'assets/fonts/NotoSansMono-Regular.ttf',
      'assets/fonts/NotoSansMono-Bold.ttf',
    ]) {
      final Uint8List bytes = File(file).readAsBytesSync();

      loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  });

  for (final double fontSize in <double>[mpTextEditorFontSize, 6, 48]) {
    for (final int lineCount in <int>[9, 99, 100, 999, 1000, 10000]) {
      testWidgets('$lineCount lines at font size $fontSize fit', (
        WidgetTester tester,
      ) async {
        final int last = lineCount - 1;

        tester.view.physicalSize = const Size(800, 200000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: THTextEditorLineNumberGutterWidget(
                  lineCount: lineCount,
                  currentLine: last,
                  diagnosticLines: <int, THTextEditorDiagnosticSeverity>{
                    last: THTextEditorDiagnosticSeverity.error,
                  },
                  scrollController: ScrollController(
                    initialScrollOffset:
                        (last * fontSize * mpTextEditorLineHeight) - 100,
                  ),
                  lineHeight: fontSize * mpTextEditorLineHeight,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        /// The last line is bold, has a dot and has the most digits.
        final Finder number = find.text('$lineCount');
        final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
          number,
        );

        expect(number, findsOneWidget);
        expect(
          paragraph.getMaxIntrinsicWidth(double.infinity),
          lessThanOrEqualTo(paragraph.size.width),
        );
      });
    }
  }
}
