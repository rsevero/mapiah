// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// Outcome of draining the pending re-parse work for one canonical path at a
/// specific revision, via `THProjectController.flushPendingReparse` /
/// `THTextEditorController.flushPendingReparse`.
enum THProjectReparseFlushStatus {
  /// The requested revision's content was (re)parsed and the writable node is
  /// now tagged with it.
  reparsed,

  /// The requested revision was already the parsed-node revision; no work was
  /// needed.
  alreadyCurrent,

  /// A newer revision has already superseded the requested one; its own
  /// re-parse queues/follows.
  superseded,

  /// The captured project epoch/root no longer matches; no current state was
  /// touched.
  projectChanged,

  /// The re-parse work itself failed; the prior tree and all pending state are
  /// left intact.
  failed,
}

class THProjectReparseFlushResult {
  final String canonicalPath;

  final int projectEpoch;

  final int expectedRevision;

  /// The revision the writable node is tagged with after the flush, or `null`
  /// when the flush did not (re)parse anything for this path.
  final int? parsedRevision;

  final THProjectReparseFlushStatus status;

  const THProjectReparseFlushResult({
    required this.canonicalPath,
    required this.projectEpoch,
    required this.expectedRevision,
    required this.parsedRevision,
    required this.status,
  });

  /// Whether the save boundary may proceed: the parsed node represents exactly
  /// the requested revision. It does not guarantee that revision stays current
  /// long enough to write.
  bool get canProceedToSave =>
      (status == THProjectReparseFlushStatus.reparsed ||
          status == THProjectReparseFlushStatus.alreadyCurrent) &&
      parsedRevision == expectedRevision;
}
