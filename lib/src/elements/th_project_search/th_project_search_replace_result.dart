// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/controllers/th_text_file_save_result.dart';

/// Why a Replace All target was intentionally skipped *before* `setContent()`
/// / `save()`, as opposed to a [THTextFileSaveStatus] describing an attempted
/// save.
enum THProjectSearchReplaceSkipReason {
  /// The replacement/search generation changed; all remaining targets stop.
  searchSuperseded,

  /// The project epoch/root changed; all remaining targets stop.
  projectChanged,

  /// The target no longer resolves to a writable config/data node (e.g. an
  /// earlier include/source edit removed it from the tree).
  eligibilityChanged,

  /// The target's current content/revision no longer matches the immutable
  /// replacement snapshot (a concurrent edit).
  contentChanged,
}

/// Per-target result of a Replace All run: either an attempted save (with its
/// typed [THTextFileSaveResult]) or a pre-mutation skip (with a reason).
class THProjectSearchReplaceOutcome {
  final String canonicalPath;
  final String displayPath;

  /// Number of matches this target carried in the immutable snapshot.
  final int matchCount;

  /// Set when a save was attempted for this target.
  final THTextFileSaveResult? saveResult;

  /// Set when the target was skipped before any mutation.
  final THProjectSearchReplaceSkipReason? skipReason;

  const THProjectSearchReplaceOutcome.saved({
    required this.canonicalPath,
    required this.displayPath,
    required this.matchCount,
    required THTextFileSaveResult this.saveResult,
  }) : skipReason = null;

  const THProjectSearchReplaceOutcome.skipped({
    required this.canonicalPath,
    required this.displayPath,
    required this.matchCount,
    required THProjectSearchReplaceSkipReason this.skipReason,
  }) : saveResult = null;

  bool get isComplete =>
      saveResult != null && saveResult!.isCurrentRevisionSaved;

  bool get isSkipped => skipReason != null;
}

/// Aggregate report shown in the localized completion dialog after a Replace
/// All run finishes.
class THProjectSearchReplaceReport {
  final List<THProjectSearchReplaceOutcome> outcomes;

  /// Canonical paths of failed/incomplete temporary targets that were opened
  /// as ordinary registered dirty editor tabs for recovery.
  final List<String> materializedPaths;

  /// Number of visible standalone (search-only) files excluded from the run.
  final int excludedStandaloneFileCount;

  /// Number of visible standalone matches excluded from the run.
  final int excludedStandaloneMatchCount;

  const THProjectSearchReplaceReport({
    required this.outcomes,
    required this.materializedPaths,
    required this.excludedStandaloneFileCount,
    required this.excludedStandaloneMatchCount,
  });

  Iterable<THProjectSearchReplaceOutcome> get completed =>
      outcomes.where((THProjectSearchReplaceOutcome o) => o.isComplete);

  Iterable<THProjectSearchReplaceOutcome> get skipped =>
      outcomes.where((THProjectSearchReplaceOutcome o) => o.isSkipped);

  Iterable<THProjectSearchReplaceOutcome> get incomplete => outcomes.where(
    (THProjectSearchReplaceOutcome o) =>
        !o.isComplete &&
        !o.isSkipped &&
        o.saveResult != null &&
        o.saveResult!.status != THTextFileSaveStatus.writeFailed &&
        o.saveResult!.status != THTextFileSaveStatus.serializationFailed,
  );

  Iterable<THProjectSearchReplaceOutcome> get failed => outcomes.where(
    (THProjectSearchReplaceOutcome o) =>
        o.saveResult != null &&
        (o.saveResult!.status == THTextFileSaveStatus.writeFailed ||
            o.saveResult!.status == THTextFileSaveStatus.serializationFailed),
  );

  int get completedFileCount => completed.length;

  int get completedMatchCount => completed.fold<int>(
    0,
    (int sum, THProjectSearchReplaceOutcome o) => sum + o.matchCount,
  );
}
