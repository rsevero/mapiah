// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/th_text_editor_diagnostic.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:material_ui/material_ui.dart';

/// The information diagnostic color, distinct from the error and warning
/// colors of the color scheme.
const Color thTextEditorInformationDiagnosticColor = Color(0xFF1E88E5);

/// The color of a diagnostic of [severity].
Color thTextEditorDiagnosticColor(
  THTextEditorDiagnosticSeverity severity,
  ColorScheme colorScheme,
) {
  return switch (severity) {
    THTextEditorDiagnosticSeverity.error => colorScheme.error,
    THTextEditorDiagnosticSeverity.warning => colorScheme.tertiary,
    THTextEditorDiagnosticSeverity.information =>
      thTextEditorInformationDiagnosticColor,
  };
}

/// Renders the diagnostics of one line as a full-width line marker inside
/// [THTextEditorWidget]'s text area, in the color of the most severe one,
/// with every message shown on hover, most severe first.
///
/// A column-range squiggle under the affected token is not implemented since
/// diagnostics don't carry column information; the whole line gets the
/// marker background instead.
class THTextEditorDiagnosticMarkerWidget extends StatelessWidget {
  /// Most severe first.
  final List<THTextEditorDiagnostic> diagnostics;

  final double height;

  const THTextEditorDiagnosticMarkerWidget({
    super.key,
    required this.diagnostics,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final Color markerColor = thTextEditorDiagnosticColor(
      diagnostics.first.severity,
      Theme.of(context).colorScheme,
    );

    return Tooltip(
      message: diagnostics
          .map((THTextEditorDiagnostic diagnostic) => diagnostic.message)
          .join(mpUnixLineBreak),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: markerColor.withValues(alpha: 0.12),
          border: Border(bottom: BorderSide(color: markerColor, width: 1.5)),
        ),
      ),
    );
  }
}

/// The line-less diagnostics, one message per entry, colored by severity.
class THTextEditorLinelessDiagnosticsWidget extends StatelessWidget {
  /// Most severe first.
  final List<THTextEditorDiagnostic> diagnostics;

  const THTextEditorLinelessDiagnosticsWidget({
    super.key,
    required this.diagnostics,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: mpTextEditorLineNumberGutterPadding,
      ),
      child: Column(
        key: const ValueKey('THTextEditorWidget|LinelessDiagnostics'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final THTextEditorDiagnostic diagnostic in diagnostics)
            Row(
              children: <Widget>[
                Container(
                  width: mpTextEditorDiagnosticMarkerSize,
                  height: mpTextEditorDiagnosticMarkerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: thTextEditorDiagnosticColor(
                      diagnostic.severity,
                      colorScheme,
                    ),
                  ),
                ),
                const SizedBox(width: mpTextEditorLineNumberGutterPadding),
                Expanded(
                  child: Text(
                    diagnostic.message,
                    style: TextStyle(
                      color: thTextEditorDiagnosticColor(
                        diagnostic.severity,
                        colorScheme,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
