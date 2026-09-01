// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// One immutable view of the project-owned state an editor adopts for a
/// canonical text path: its content, current allocated revision, whether that
/// revision is a pending (unsaved) edit, and the project-identity
/// (`projectEpoch` + `rootPath`) it belongs to.
///
/// Lookup and construction are synchronous so these fields can never be
/// stitched together from different revisions or lifecycle identities.
class THTextProjectContentSnapshot {
  final String canonicalPath;

  final String content;

  /// The path's current content revision. `0` for a freshly loaded clean
  /// disk-backed node, or for a path the project does not track.
  final int currentRevision;

  /// Whether [currentRevision] is a pending dirty edit (has a pending
  /// content record) rather than persisted disk content.
  final bool isDirty;

  /// The project epoch this snapshot was taken under. `-1` when the path is
  /// not tracked by any open project (an unbound editor).
  final int projectEpoch;

  /// The project's canonical root path at snapshot time. Empty when the path
  /// is not tracked by any open project.
  final String rootPath;

  /// Whether the project actually tracks this path (has a writable node and
  /// revision records for it).
  final bool isProjectTracked;

  const THTextProjectContentSnapshot({
    required this.canonicalPath,
    required this.content,
    required this.currentRevision,
    required this.isDirty,
    required this.projectEpoch,
    required this.rootPath,
    required this.isProjectTracked,
  });

  /// A snapshot for a path no open project tracks: revision `0`, clean, and
  /// explicitly unbound.
  const THTextProjectContentSnapshot.untracked({
    required this.canonicalPath,
    required this.content,
  }) : currentRevision = 0,
       isDirty = false,
       projectEpoch = -1,
       rootPath = '',
       isProjectTracked = false;
}
