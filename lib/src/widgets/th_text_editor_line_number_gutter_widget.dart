// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/th_text_editor_diagnostic.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/widgets/th_text_editor_diagnostic_marker_widget.dart';
import 'package:material_ui/material_ui.dart';

/// Line-number gutter for [THTextEditorWidget], synchronized with the
/// editor's vertical scroll offset via [scrollController].
///
/// One number per logical line, right-aligned and padded to the width of
/// the longest visible line number. The current line is highlighted, and
/// lines with diagnostics get a dot in their most severe diagnostic's
/// color.
class THTextEditorLineNumberGutterWidget extends StatelessWidget {
  final int lineCount;

  final int currentLine;

  /// Line → its most severe diagnostic severity.
  final Map<int, THTextEditorDiagnosticSeverity> diagnosticLines;

  final ScrollController scrollController;

  /// The height of one editor row.
  final double lineHeight;

  const THTextEditorLineNumberGutterWidget({
    super.key,
    required this.lineCount,
    required this.currentLine,
    required this.diagnosticLines,
    required this.scrollController,
    this.lineHeight = mpTextEditorFontSize * mpTextEditorLineHeight,
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
        itemExtent: lineHeight,
        itemBuilder: (BuildContext context, int index) {
          final bool isCurrentLine = index == currentLine;
          final THTextEditorDiagnosticSeverity? diagnosticSeverity =
              diagnosticLines[index];

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: mpTextEditorLineNumberGutterPadding,
            ),
            child: Row(
              children: <Widget>[
                if (diagnosticSeverity != null)
                  Container(
                    width: mpTextEditorDiagnosticMarkerSize,
                    height: mpTextEditorDiagnosticMarkerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: thTextEditorDiagnosticColor(
                        diagnosticSeverity,
                        colorScheme,
                      ),
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

/// Convenience for building the map consumed by
/// [THTextEditorLineNumberGutterWidget.diagnosticLines]: each diagnostic line
/// with its most severe severity. Line-less diagnostics are left out.
Map<int, THTextEditorDiagnosticSeverity> thTextEditorDiagnosticLines(
  List<THTextEditorDiagnostic> diagnostics,
) {
  final Map<int, THTextEditorDiagnosticSeverity> lines =
      <int, THTextEditorDiagnosticSeverity>{};

  for (final THTextEditorDiagnostic diagnostic in diagnostics) {
    final int? line = diagnostic.line;

    if (line == null) {
      continue;
    }

    final THTextEditorDiagnosticSeverity? current = lines[line];

    if ((current == null) || (diagnostic.severity.index < current.index)) {
      lines[line] = diagnostic.severity;
    }
  }

  return lines;
}
