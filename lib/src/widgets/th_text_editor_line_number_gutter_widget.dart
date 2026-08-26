// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:material_ui/material_ui.dart';

/// Line-number gutter for [THTextEditorWidget], synchronized with the
/// editor's vertical scroll offset via [scrollController].
///
/// One number per logical line, right-aligned and padded to the width of
/// the longest visible line number. The current line is highlighted, and
/// lines with diagnostics get an error dot.
class THTextEditorLineNumberGutterWidget extends StatelessWidget {
  final int lineCount;

  final int currentLine;

  final Set<int> diagnosticLines;

  final ScrollController scrollController;

  const THTextEditorLineNumberGutterWidget({
    super.key,
    required this.lineCount,
    required this.currentLine,
    required this.diagnosticLines,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double digitWidth = (lineCount.toString().length * 8.0).clamp(
      mpTextEditorLineNumberGutterMinWidth,
      double.infinity,
    );

    return SizedBox(
      width: digitWidth + mpTextEditorLineNumberGutterPadding * 2,
      child: ListView.builder(
        controller: scrollController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: lineCount,
        itemExtent: mpTextEditorFontSize * mpTextEditorLineHeight,
        itemBuilder: (BuildContext context, int index) {
          final bool isCurrentLine = index == currentLine;
          final bool hasDiagnostic = diagnosticLines.contains(index);

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: mpTextEditorLineNumberGutterPadding,
            ),
            child: Row(
              children: <Widget>[
                if (hasDiagnostic)
                  Container(
                    width: mpTextEditorDiagnosticMarkerSize,
                    height: mpTextEditorDiagnosticMarkerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.error,
                    ),
                  )
                else
                  SizedBox(width: mpTextEditorDiagnosticMarkerSize),
                Expanded(
                  child: Text(
                    '${index + 1}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: mpTextEditorFontSize,
                      color: isCurrentLine
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isCurrentLine
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Convenience for building the diagnostic-line set consumed by
/// [THTextEditorLineNumberGutterWidget.diagnosticLines] from raw parse
/// errors, mapping the 1-based [THProjectParseError.lineNumber] to a
/// 0-based editor line.
Set<int> thTextEditorDiagnosticLines(List<THProjectParseError> diagnostics) =>
    diagnostics
        .map((THProjectParseError error) => error.lineNumber - 1)
        .toSet();
