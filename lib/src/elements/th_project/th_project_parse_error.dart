// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// Severity level for a [THProjectParseError].
enum THProjectParseErrorSeverity { warning, error }

/// Diagnostic produced while assembling a Therion project tree.
class THProjectParseError {
  final String message;

  final THProjectParseErrorSeverity severity;

  final String filePath;

  final int lineNumber;

  const THProjectParseError({
    required this.message,
    required this.severity,
    required this.filePath,
    required this.lineNumber,
  });
}
