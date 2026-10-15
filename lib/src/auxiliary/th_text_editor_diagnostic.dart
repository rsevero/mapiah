// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';

/// Ordered from most to least severe.
enum THTextEditorDiagnosticSeverity { error, warning, information }

/// One diagnostic shown by the text editor. Information diagnostics never
/// block anything.
class THTextEditorDiagnostic {
  /// 0-based line, or `null` for a line-less diagnostic.
  final int? line;

  final String message;

  final THTextEditorDiagnosticSeverity severity;

  /// The file a project diagnostic came from.
  final String? filePath;

  final int? _lineNumber;

  const THTextEditorDiagnostic({
    required this.line,
    required this.message,
    required this.severity,
    this.filePath,
    int? lineNumber,
  }) : _lineNumber = lineNumber;

  /// A project error with `lineNumber <= 0` has no line.
  factory THTextEditorDiagnostic.fromProjectParseError(
    THProjectParseError error,
  ) {
    return THTextEditorDiagnostic(
      line: (error.lineNumber <= 0) ? null : error.lineNumber - 1,
      message: error.message,
      severity: switch (error.severity) {
        THProjectParseErrorSeverity.error =>
          THTextEditorDiagnosticSeverity.error,
        THProjectParseErrorSeverity.warning =>
          THTextEditorDiagnosticSeverity.warning,
      },
      filePath: error.filePath,
      lineNumber: error.lineNumber,
    );
  }

  /// 1-based line, as project errors report it; the original value for an
  /// adapted project error, else 0 for a line-less diagnostic.
  int get lineNumber => _lineNumber ?? ((line == null) ? 0 : line! + 1);

  @override
  String toString() =>
      'THTextEditorDiagnostic(line: $line, severity: ${severity.name}, '
      'message: $message)';
}

/// The diagnostics of one line, or the line-less ones, grouped for display.
class THTextEditorDiagnosticGroup {
  /// 0-based line, or `null` for the line-less diagnostics.
  final int? line;

  /// Most severe first, in their original order within each severity.
  final List<THTextEditorDiagnostic> diagnostics;

  const THTextEditorDiagnosticGroup({
    required this.line,
    required this.diagnostics,
  });

  THTextEditorDiagnosticSeverity get severity => diagnostics.first.severity;
}

/// [diagnostics] sorted most severe first, keeping the original order within
/// each severity.
List<THTextEditorDiagnostic> thTextEditorDiagnosticsBySeverity(
  Iterable<THTextEditorDiagnostic> diagnostics,
) {
  final List<THTextEditorDiagnostic> sorted = <THTextEditorDiagnostic>[];

  for (final THTextEditorDiagnosticSeverity severity
      in THTextEditorDiagnosticSeverity.values) {
    sorted.addAll(
      diagnostics.where(
        (THTextEditorDiagnostic diagnostic) => diagnostic.severity == severity,
      ),
    );
  }

  return sorted;
}

/// Groups [diagnostics] with a line by line, in line order.
List<THTextEditorDiagnosticGroup> thTextEditorDiagnosticGroupsByLine(
  List<THTextEditorDiagnostic> diagnostics,
) {
  final Map<int, List<THTextEditorDiagnostic>> byLine =
      <int, List<THTextEditorDiagnostic>>{};

  for (final THTextEditorDiagnostic diagnostic in diagnostics) {
    final int? line = diagnostic.line;

    if (line != null) {
      byLine.putIfAbsent(line, () => <THTextEditorDiagnostic>[]).add(
        diagnostic,
      );
    }
  }

  final List<int> lines = byLine.keys.toList()..sort();

  return <THTextEditorDiagnosticGroup>[
    for (final int line in lines)
      THTextEditorDiagnosticGroup(
        line: line,
        diagnostics: thTextEditorDiagnosticsBySeverity(byLine[line]!),
      ),
  ];
}

/// The line-less diagnostics of [diagnostics], most severe first.
List<THTextEditorDiagnostic> thTextEditorLinelessDiagnostics(
  List<THTextEditorDiagnostic> diagnostics,
) {
  return thTextEditorDiagnosticsBySeverity(
    diagnostics.where(
      (THTextEditorDiagnostic diagnostic) => diagnostic.line == null,
    ),
  );
}
