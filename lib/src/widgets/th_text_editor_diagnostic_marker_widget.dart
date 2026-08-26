// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:material_ui/material_ui.dart';

/// Renders a single [THProjectParseError] as a full-width line marker
/// (error/warning background) inside [THTextEditorWidget]'s text area,
/// with the parse-error message shown on hover.
///
/// A column-range squiggle under the affected token is not implemented in
/// Phase 5 since [THProjectParseError] does not carry column information;
/// the whole line gets the marker background instead.
class THTextEditorDiagnosticMarkerWidget extends StatelessWidget {
  final THProjectParseError diagnostic;

  final double height;

  const THTextEditorDiagnosticMarkerWidget({
    super.key,
    required this.diagnostic,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isError =
        diagnostic.severity == THProjectParseErrorSeverity.error;
    final Color markerColor = isError
        ? colorScheme.error
        : colorScheme.tertiary;

    return Tooltip(
      message: diagnostic.message,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: markerColor.withValues(alpha: 0.12),
          border: Border(
            bottom: BorderSide(color: markerColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
