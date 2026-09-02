// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// How a per-file failure arose during multi-file search or replacement.
enum THProjectSearchFailureKind { read, parse, save }

/// Immutable record of one file that could not be read, parsed, or saved.
/// [technicalMessage] is for logs only; the UI renders localized summaries.
class THProjectSearchFailure {
  final String canonicalPath;

  /// Project-relative path, or the canonical path for an out-of-project tab.
  final String displayPath;

  final THProjectSearchFailureKind kind;

  final String technicalMessage;

  const THProjectSearchFailure({
    required this.canonicalPath,
    required this.displayPath,
    required this.kind,
    required this.technicalMessage,
  });
}
