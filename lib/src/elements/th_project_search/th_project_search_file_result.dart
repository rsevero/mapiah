// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_project_search/th_project_search_match.dart';

/// Immutable per-file group of matches, plus the exact content/revision
/// snapshot that produced them so Replace All and stale-result validation
/// never have to reread the file between preview and replacement.
class THProjectSearchFileResult {
  final String canonicalPath;

  /// Project-relative path, or the canonical path for an open tab outside the
  /// loaded project. Data, not a localized string.
  final String displayPath;

  /// The exact file content the matches were computed against.
  final String searchedContent;

  /// Project-controller-owned revision paired with [searchedContent], or `null`
  /// for a standalone (non-project-tracked) file.
  final int? searchedRevision;

  /// Whether this file currently resolves to a writable
  /// `THConfigFileNode`/`THDataFileNode` and may take part in Replace All.
  final bool isReplaceEligible;

  final List<THProjectSearchMatch> matches;

  const THProjectSearchFileResult({
    required this.canonicalPath,
    required this.displayPath,
    required this.searchedContent,
    required this.searchedRevision,
    required this.isReplaceEligible,
    required this.matches,
  });

  int get matchCount => matches.length;
}
