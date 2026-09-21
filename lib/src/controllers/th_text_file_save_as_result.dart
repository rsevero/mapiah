// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// Revision-aware outcome of `THProjectController.saveTextProjectFileAs`,
/// reused as the return type of `THTextEditorController.saveAs()` itself
/// (the editor-only [cancelled] value below is never produced by the
/// project-controller boundary — a cancelled picker is handled entirely
/// inside `saveAs()`, before that boundary is ever called).
enum THTextFileSaveAsStatus {
  /// The destination was written and the project graph was rebuilt around
  /// the new location (or, for an untracked/standalone source, written
  /// directly to disk). Only this status adopts the new identity.
  saved,

  /// The picker was dismissed without a chosen path. Editor-only; disk,
  /// controller identity, dirty state, and tab order are all unchanged.
  cancelled,

  /// A newer revision appeared after flush but before serialization/write;
  /// no stale write attempted.
  supersededBeforeWrite,

  /// The captured epoch/root no longer matched before I/O started; no write
  /// attempted, no current-project state touched.
  projectChangedBeforeWrite,

  /// The project changed after I/O had started and bytes reached disk; the
  /// destination file is a known, accepted residue and the stale operation
  /// mutates nothing else.
  writtenAfterProjectChange,

  /// No parsed node representing the requested revision is safe to
  /// serialize; the caller is responsible for having flushed first.
  reparseFailed,

  /// `oldCanonicalPath` has no writable config/data node.
  unknownPath,

  /// `oldCanonicalPath` resolves to a non-writable node type.
  unsupportedNode,

  /// The destination is already a project node or an open tab.
  destinationCollision,

  /// Writer construction/serialization threw.
  serializationFailed,

  /// Filesystem I/O threw.
  writeFailed,

  /// The destination write succeeded, but the subsequent in-memory project
  /// rebuild failed; the pre-Save-As tree/dirty state is restored and the
  /// destination file is left on disk as a known, accepted residue.
  rebuildFailed,
}

class THTextFileSaveAsResult {
  final String oldCanonicalPath;

  final String newCanonicalPath;

  final int projectEpoch;

  final int requestedRevision;

  /// The revision whose bytes reached disk, or `null` when no write
  /// occurred.
  final int? writtenRevision;

  final THTextFileSaveAsStatus status;

  /// Whether `oldCanonicalPath` was `rootConfigPath` at the time of the
  /// request.
  final bool isRootChange;

  const THTextFileSaveAsResult({
    required this.oldCanonicalPath,
    required this.newCanonicalPath,
    required this.projectEpoch,
    required this.requestedRevision,
    required this.writtenRevision,
    required this.status,
    required this.isRootChange,
  });

  bool get isComplete => status == THTextFileSaveAsStatus.saved;
}
