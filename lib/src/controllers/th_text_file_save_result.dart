// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// Revision-aware outcome of persisting one writable text (config/data) file,
/// returned by `THProjectController.saveTextProjectFile` and, wrapped,
/// `THTextEditorController.save`. Callers read this directly; they never infer
/// success from `dirtyFilePaths`, `isDirty`, or a `projectErrors` diff.
enum THTextFileSaveStatus {
  /// The exact requested/flushed revision was written and was still current
  /// when the write completed. Only this status clears dirty state.
  saved,

  /// The requested revision is already the current parsed revision with no
  /// pending dirty-content record (loaded from disk or previously saved). No
  /// serialization or I/O performed.
  alreadySaved,

  /// A newer revision appeared after flush but before serialization/write; no
  /// stale write attempted.
  supersededBeforeWrite,

  /// The requested revision reached disk, but a newer edit appeared while the
  /// asynchronous write was in progress; the newer revision stays dirty.
  savedButSuperseded,

  /// The captured epoch/root no longer matched before I/O started; no write
  /// attempted, no current-project state touched.
  projectChangedBeforeWrite,

  /// The project changed after I/O had started and bytes reached disk; the
  /// side effect is recorded but the stale operation mutates nothing.
  writtenAfterProjectChange,

  /// No parsed node representing the requested revision is safe to serialize.
  reparseFailed,

  /// The canonical path has no writable config/data node.
  unknownPath,

  /// The canonical path resolves to a non-writable node type.
  unsupportedNode,

  /// Writer construction/serialization threw.
  serializationFailed,

  /// Filesystem I/O threw.
  writeFailed,
}

class THTextFileSaveResult {
  final String canonicalPath;

  final int projectEpoch;

  final int requestedRevision;

  /// The revision whose bytes reached disk, or `null` when no write occurred.
  final int? writtenRevision;

  /// The path's current revision at completion, or `null` when reading it
  /// would cross a project-epoch boundary.
  final int? currentRevision;

  final THTextFileSaveStatus status;

  const THTextFileSaveResult({
    required this.canonicalPath,
    required this.projectEpoch,
    required this.requestedRevision,
    required this.writtenRevision,
    required this.currentRevision,
    required this.status,
  });

  bool get isCurrentRevisionSaved =>
      status == THTextFileSaveStatus.saved ||
      status == THTextFileSaveStatus.alreadySaved;
}

/// Outcome of the `.th2` adapter branch of generic `saveProjectFile`. `.th2`
/// serialization/write stay owned by `TH2FileEditController.saveTH2File`,
/// which does not separate serialization from I/O, hence one `saveFailed`.
enum TH2FileSaveStatus { saved, alreadySaved, projectChanged, noOpenEditor, saveFailed }

/// Sealed result of the generic `THProjectController.saveProjectFile(path)`.
sealed class THProjectFileSaveResult {
  const THProjectFileSaveResult();

  String get canonicalPath;

  bool get isComplete;
}

/// Generic request that resolved to a tracked writable text node.
class THProjectTextFileSaveResult extends THProjectFileSaveResult {
  final THTextFileSaveResult textResult;

  const THProjectTextFileSaveResult(this.textResult);

  @override
  String get canonicalPath => textResult.canonicalPath;

  @override
  bool get isComplete => textResult.isCurrentRevisionSaved;
}

/// Generic request that resolved to a registered `.th2` editor.
class THProjectTH2FileSaveResult extends THProjectFileSaveResult {
  @override
  final String canonicalPath;

  final int projectEpoch;

  final String rootPath;

  final TH2FileSaveStatus status;

  const THProjectTH2FileSaveResult({
    required this.canonicalPath,
    required this.projectEpoch,
    required this.rootPath,
    required this.status,
  });

  @override
  bool get isComplete =>
      status == TH2FileSaveStatus.saved ||
      status == TH2FileSaveStatus.alreadySaved;
}

/// Generic request that is neither a tracked writable text node nor a
/// registered `.th2` editor.
class THProjectRejectedFileSaveResult extends THProjectFileSaveResult {
  @override
  final String canonicalPath;

  /// [THTextFileSaveStatus.unknownPath] or [THTextFileSaveStatus.unsupportedNode].
  final THTextFileSaveStatus reason;

  const THProjectRejectedFileSaveResult({
    required this.canonicalPath,
    required this.reason,
  });

  @override
  bool get isComplete => false;
}

/// Aggregate outcome of `THProjectController.saveAllModifiedFiles`.
class THSaveAllModifiedFilesResult {
  /// One result per captured descriptor, in canonical-path-sorted order.
  final List<THProjectFileSaveResult> results;

  /// The dirty paths still outstanding after Save All finished. Reporting
  /// context only — it may include edits created after Save All began, so it
  /// is not a proxy for any individual result.
  final List<String> remainingDirtyPaths;

  const THSaveAllModifiedFilesResult({
    required this.results,
    required this.remainingDirtyPaths,
  });

  bool get isComplete =>
      results.every((THProjectFileSaveResult result) => result.isComplete);
}
