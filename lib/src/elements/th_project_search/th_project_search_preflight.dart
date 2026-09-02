// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_project_search/th_project_search_failure.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_scope.dart';

/// One writable target of a Replace All run, with its precomputed replacement
/// string and the exact content/revision it was computed against.
class THProjectSearchReplaceTarget {
  final String canonicalPath;
  final String displayPath;
  final String searchedContent;
  final int searchedRevision;
  final String replacementContent;
  final int matchCount;

  /// Whether an open editor tab is currently registered for this path (so the
  /// pipeline reuses it instead of a temporary controller).
  final bool hasOpenTab;

  const THProjectSearchReplaceTarget({
    required this.canonicalPath,
    required this.displayPath,
    required this.searchedContent,
    required this.searchedRevision,
    required this.replacementContent,
    required this.matchCount,
    required this.hasOpenTab,
  });
}

/// Immutable snapshot captured before the Replace All confirmation dialog and
/// revalidated in full after it returns and before the first mutation.
class THProjectSearchReplacePreflight {
  final int replaceGeneration;
  final int searchGeneration;
  final int projectEpoch;
  final String rootPath;
  final String query;
  final String replacement;
  final bool caseSensitive;
  final THProjectSearchScope scope;
  final List<THProjectSearchReplaceTarget> targets;
  final int eligibleMatchCount;
  final int excludedStandaloneFileCount;
  final int excludedStandaloneMatchCount;
  final List<THProjectSearchFailure> preflightFailures;

  const THProjectSearchReplacePreflight({
    required this.replaceGeneration,
    required this.searchGeneration,
    required this.projectEpoch,
    required this.rootPath,
    required this.query,
    required this.replacement,
    required this.caseSensitive,
    required this.scope,
    required this.targets,
    required this.eligibleMatchCount,
    required this.excludedStandaloneFileCount,
    required this.excludedStandaloneMatchCount,
    required this.preflightFailures,
  });

  int get eligibleFileCount => targets.length;

  bool get hasEligibleWork => targets.isNotEmpty && eligibleMatchCount > 0;
}
