// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th_project_search_controller.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_failure.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_file_result.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_match.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_preflight.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_replace_result.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_scope.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/th_project_search_result_widget.dart';
import 'package:material_ui/material_ui.dart';

/// Multi-file search sidebar view: query/replacement controls, scope selector,
/// grouped navigable results, and project-wide Replace All.
///
/// Visibility is decided solely by `THProjectTreeUIController.sidebarMode`;
/// this widget never reads or writes it. Query/replacement `TextEditingController`s
/// and field `FocusNode`s live in widget state.
class THProjectSearchWidget extends StatefulWidget {
  const THProjectSearchWidget({super.key});

  @override
  State<THProjectSearchWidget> createState() => _THProjectSearchWidgetState();
}

class _THProjectSearchWidgetState extends State<THProjectSearchWidget> {
  final TextEditingController _queryEditingController = TextEditingController();
  final TextEditingController _replacementEditingController =
      TextEditingController();
  final FocusNode _queryFocusNode = FocusNode();

  bool _isSyncingQueryFromController = false;
  bool _isSyncingReplacementFromController = false;
  bool _isReplaceRowExpanded = false;
  int _lastConsumedFocusGeneration = 0;

  THProjectSearchController get _controller =>
      mpLocator.thProjectSearchController;

  @override
  void initState() {
    super.initState();
    _queryEditingController.text = _controller.query;
    _replacementEditingController.text = _controller.replacement;
    _queryEditingController.addListener(_onQueryEditingChanged);
    _replacementEditingController.addListener(_onReplacementEditingChanged);
  }

  @override
  void dispose() {
    _queryEditingController.removeListener(_onQueryEditingChanged);
    _replacementEditingController.removeListener(_onReplacementEditingChanged);
    _queryEditingController.dispose();
    _replacementEditingController.dispose();
    _queryFocusNode.dispose();
    super.dispose();
  }

  void _onQueryEditingChanged() {
    if (_isSyncingQueryFromController) {
      return;
    }
    _controller.setQuery(_queryEditingController.text);
  }

  void _onReplacementEditingChanged() {
    if (_isSyncingReplacementFromController) {
      return;
    }
    _controller.setReplacement(_replacementEditingController.text);
  }

  void _consumeFocusGeneration(int generation) {
    if (generation == _lastConsumedFocusGeneration) {
      return;
    }
    _lastConsumedFocusGeneration = generation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          mpLocator.thProjectTreeUIController.projectSearchFocusRequestGeneration !=
              generation) {
        return;
      }
      _queryFocusNode.requestFocus();
      _queryEditingController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _queryEditingController.text.length,
      );
    });
  }

  Future<void> _activateMatch(THProjectSearchMatch match) async {
    THProjectSearchMatch target = match;

    if (!_controller.matchIsStillValid(target)) {
      await _controller.submitQuery();

      final THProjectSearchFileResult? refreshed = _controller.results
          .cast<THProjectSearchFileResult?>()
          .firstWhere(
            (THProjectSearchFileResult? r) =>
                r?.canonicalPath == match.canonicalPath,
            orElse: () => null,
          );

      if (refreshed == null || refreshed.matches.isEmpty) {
        return;
      }

      target = refreshed.matches.reduce(
        (THProjectSearchMatch a, THProjectSearchMatch b) =>
            (a.range.start - match.range.start).abs() <=
                (b.range.start - match.range.start).abs()
            ? a
            : b,
      );
    }

    final editor = mpLocator.mpGeneralController.getTextEditorController(
      target.canonicalPath,
    );

    editor.revealRange(target.range);
    mpLocator.mpGeneralController.addFileTab(target.canonicalPath);
  }

  Future<void> _handleReplaceAll() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final THProjectSearchReplacePreflight? preflight = await _controller
        .prepareReplaceAll();

    if (!mounted) {
      return;
    }

    if (preflight == null) {
      final String reason = _controller.replaceEligibleMatchCount == 0 &&
              _controller.standaloneMatchCount > 0
          ? appLocalizations.projectSearchReplaceOnlyStandalone
          : appLocalizations.projectSearchReplacePreflightFailed;
      await _showMessageDialog(
        appLocalizations.projectSearchReplaceConfirmTitle,
        reason,
      );
      return;
    }

    final bool confirmed = await _showConfirmDialog(preflight);

    if (!mounted || !confirmed) {
      return;
    }

    final THProjectSearchReplaceReport report = await _controller
        .executeReplaceAll(preflight);

    if (!mounted) {
      return;
    }

    await _showCompletionDialog(report);
  }

  Future<bool> _showConfirmDialog(
    THProjectSearchReplacePreflight preflight,
  ) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(appLocalizations.projectSearchReplaceConfirmTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                appLocalizations.projectSearchReplaceConfirmBody(
                  preflight.eligibleMatchCount,
                  preflight.eligibleFileCount,
                ),
              ),
              if (preflight.excludedStandaloneMatchCount > 0) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  appLocalizations.projectSearchReplaceConfirmExcluded(
                    preflight.excludedStandaloneMatchCount,
                    preflight.excludedStandaloneFileCount,
                  ),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(appLocalizations.projectSearchReplaceCancelButton),
            ),
            FilledButton(
              key: const ValueKey('THProjectSearchWidget|ReplaceConfirm'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(appLocalizations.projectSearchReplaceConfirmButton),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _showCompletionDialog(
    THProjectSearchReplaceReport report,
  ) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<String> lines = <String>[
      appLocalizations.projectSearchReplaceCompleteSummary(
        report.completedMatchCount,
        report.completedFileCount,
      ),
    ];

    final int incomplete = report.incomplete.length;
    final int skipped = report.skipped.length;
    final int failed = report.failed.length;
    final int materialized = report.materializedPaths.length;

    if (incomplete > 0) {
      lines.add(
        appLocalizations.projectSearchReplaceCompleteIncomplete(incomplete),
      );
    }
    if (skipped > 0) {
      lines.add(
        appLocalizations.projectSearchReplaceCompleteSkipped(skipped),
      );
    }
    if (failed > 0) {
      lines.add(appLocalizations.projectSearchReplaceCompleteFailed(failed));
    }
    if (materialized > 0) {
      lines.add(
        appLocalizations.projectSearchReplaceCompleteMaterialized(
          materialized,
        ),
      );
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(appLocalizations.projectSearchReplaceCompleteTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final String line in lines) ...<Widget>[
                  Text(line),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                appLocalizations.projectSearchReplaceCompleteCloseButton,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMessageDialog(String title, String message) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                AppLocalizations.of(
                  dialogContext,
                ).projectSearchReplaceCompleteCloseButton,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Observer(
      builder: (_) {
        _consumeFocusGeneration(
          mpLocator.thProjectTreeUIController.projectSearchFocusRequestGeneration,
        );

        if (_queryEditingController.text != _controller.query) {
          _isSyncingQueryFromController = true;
          _queryEditingController.text = _controller.query;
          _isSyncingQueryFromController = false;
        }
        if (_replacementEditingController.text != _controller.replacement) {
          _isSyncingReplacementFromController = true;
          _replacementEditingController.text = _controller.replacement;
          _isSyncingReplacementFromController = false;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeader(context, appLocalizations),
            _buildQueryRow(context, appLocalizations),
            if (_isReplaceRowExpanded)
              _buildReplacementRow(context, appLocalizations),
            _buildScopeAndActionsRow(context, appLocalizations),
            if (_controller.isSearching || _controller.isReplacing)
              const LinearProgressIndicator(),
            _buildSummary(context, appLocalizations),
            Expanded(child: _buildBody(context, appLocalizations)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return SizedBox(
      height: mpProjectTreeRowHeight,
      child: Row(
        children: <Widget>[
          IconButton(
            key: const ValueKey('THProjectSearchWidget|BackButton'),
            icon: const Icon(Icons.chevron_left),
            iconSize: mpSmallIconSize,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: mpProjectTreeRowHeight,
              minHeight: mpProjectTreeRowHeight,
            ),
            tooltip: appLocalizations.projectSearchBackToTreeTooltip,
            onPressed: mpLocator.thProjectTreeUIController.showTree,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              appLocalizations.projectSearchTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryRow(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Row(
      children: <Widget>[
        IconButton(
          key: const ValueKey('THProjectSearchWidget|ToggleReplaceButton'),
          icon: Icon(
            _isReplaceRowExpanded ? Icons.expand_less : Icons.expand_more,
          ),
          iconSize: mpSmallIconSize,
          tooltip: appLocalizations.projectSearchToggleReplaceTooltip,
          onPressed: () => setState(() {
            _isReplaceRowExpanded = !_isReplaceRowExpanded;
          }),
        ),
        Expanded(
          child: TextField(
            key: const ValueKey('THProjectSearchWidget|QueryField'),
            controller: _queryEditingController,
            focusNode: _queryFocusNode,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: appLocalizations.projectSearchQueryHint,
            ),
            onSubmitted: (_) => unawaited(_controller.submitQuery()),
          ),
        ),
        IconButton(
          key: const ValueKey('THProjectSearchWidget|CaseSensitiveToggle'),
          icon: Icon(
            Icons.text_fields,
            color: _controller.caseSensitive
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          iconSize: mpSmallIconSize,
          tooltip: appLocalizations.projectSearchCaseSensitiveTooltip,
          onPressed: () =>
              _controller.setCaseSensitive(!_controller.caseSensitive),
        ),
        IconButton(
          key: const ValueKey('THProjectSearchWidget|RefreshButton'),
          icon: const Icon(Icons.refresh),
          iconSize: mpSmallIconSize,
          tooltip: appLocalizations.projectSearchRefreshTooltip,
          onPressed: () => unawaited(_controller.submitQuery()),
        ),
      ],
    );
  }

  Widget _buildReplacementRow(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Row(
      children: <Widget>[
        const SizedBox(width: mpProjectTreeRowHeight),
        Expanded(
          child: TextField(
            key: const ValueKey('THProjectSearchWidget|ReplacementField'),
            controller: _replacementEditingController,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: appLocalizations.projectSearchReplacementHint,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScopeAndActionsRow(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: mpProjectSearchHeaderSpacing,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: DropdownButton<THProjectSearchScope>(
              key: const ValueKey('THProjectSearchWidget|ScopeSelector'),
              isDense: true,
              isExpanded: true,
              value: _controller.scope,
              onChanged: (THProjectSearchScope? scope) {
                if (scope != null) {
                  _controller.setScope(scope);
                }
              },
              items: <DropdownMenuItem<THProjectSearchScope>>[
                DropdownMenuItem<THProjectSearchScope>(
                  value: THProjectSearchScope.openTextTabs,
                  child: Text(appLocalizations.projectSearchScopeOpenTabs),
                ),
                DropdownMenuItem<THProjectSearchScope>(
                  value: THProjectSearchScope.projectFiles,
                  child: Text(appLocalizations.projectSearchScopeProjectFiles),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            key: const ValueKey('THProjectSearchWidget|ReplaceAllButton'),
            onPressed: _controller.canReplaceAll
                ? () => unawaited(_handleReplaceAll())
                : null,
            child: Text(appLocalizations.projectSearchReplaceAllButton),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    final String text;

    if (_controller.isSearching) {
      text = appLocalizations.projectSearchSearching;
    } else if (_controller.isReplacing) {
      text = appLocalizations.projectSearchReplacing;
    } else if (_controller.query.isEmpty) {
      text = '';
    } else {
      text = appLocalizations.projectSearchSummary(
        _controller.totalMatchCount,
        _controller.totalFileCount,
      );
    }

    if (text.isEmpty) {
      return const SizedBox(height: 0);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(
        text,
        key: const ValueKey('THProjectSearchWidget|Summary'),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    if (_controller.query.isEmpty) {
      return _centeredMessage(appLocalizations.projectSearchEmptyQuery);
    }

    if (_controller.scope == THProjectSearchScope.projectFiles &&
        mpLocator.thProjectController.rootConfigPath.isEmpty) {
      return _centeredMessage(appLocalizations.projectSearchNoProject);
    }

    if (_controller.isSearching && _controller.results.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_controller.results.isEmpty && _controller.failures.isEmpty) {
      if (_controller.scope == THProjectSearchScope.openTextTabs) {
        return _centeredMessage(appLocalizations.projectSearchNoOpenTabs);
      }
      return _centeredMessage(appLocalizations.projectSearchNoMatches);
    }

    final int readFailures = _controller.failures
        .where(
          (THProjectSearchFailure f) =>
              f.kind == THProjectSearchFailureKind.read,
        )
        .length;

    return ListView(
      children: <Widget>[
        if (readFailures > 0)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              appLocalizations.projectSearchReadFailures(readFailures),
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        for (final THProjectSearchFileResult fileResult in _controller.results)
          THProjectSearchResultWidget(
            fileResult: fileResult,
            onActivateMatch: (THProjectSearchMatch match) =>
                unawaited(_activateMatch(match)),
          ),
      ],
    );
  }

  Widget _centeredMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
