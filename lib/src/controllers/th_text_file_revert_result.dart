// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/controllers/th_text_project_content_snapshot.dart';

/// Revision-aware outcome of `THProjectController.revertTextProjectFile`.
enum THTextFileRevertStatus {
  reverted,
  alreadyClean,
  superseded,
  projectChanged,
  unknownPath,
  readFailed,
  reparseFailed,
}

class THTextFileRevertResult {
  final String canonicalPath;

  final int projectEpoch;

  final int requestedRevision;

  /// Non-null once disk content received a candidate revision, including when
  /// the operation later failed or was superseded — making the never-reuse
  /// rule observable.
  final int? reservedRevision;

  final THTextFileRevertStatus status;

  /// Lets the editor adopt content, revision, dirty status, epoch, and root
  /// atomically. Null for statuses that leave the editor buffer unchanged.
  final THTextProjectContentSnapshot? snapshot;

  const THTextFileRevertResult({
    required this.canonicalPath,
    required this.projectEpoch,
    required this.requestedRevision,
    required this.reservedRevision,
    required this.status,
    required this.snapshot,
  });

  bool get isCurrentRevisionReverted =>
      status == THTextFileRevertStatus.reverted ||
      status == THTextFileRevertStatus.alreadyClean;
}
