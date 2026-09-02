// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_file_result.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_match.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// One file group in the multi-file search results: a header row with the
/// (relative) path, match count, optional search-only badge, and an
/// expand/collapse control, above the match rows.
class THProjectSearchResultWidget extends StatelessWidget {
  final THProjectSearchFileResult fileResult;
  final void Function(THProjectSearchMatch match) onActivateMatch;

  const THProjectSearchResultWidget({
    super.key,
    required this.fileResult,
    required this.onActivateMatch,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Observer(
      builder: (_) {
        final bool expanded = mpLocator.thProjectSearchController
            .expandedResultPaths
            .contains(fileResult.canonicalPath);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              key: ValueKey<String>(
                'THProjectSearchResultWidget|Group|${fileResult.canonicalPath}',
              ),
              onTap: () => mpLocator.thProjectSearchController.toggleExpanded(
                fileResult.canonicalPath,
              ),
              child: SizedBox(
                height: mpProjectSearchGroupRowHeight,
                child: Row(
                  children: <Widget>[
                    Icon(
                      expanded ? Icons.expand_more : Icons.chevron_right,
                      size: mpSmallIconSize,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        fileResult.displayPath,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    if (!fileResult.isReplaceEligible)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Tooltip(
                          message:
                              appLocalizations.projectSearchStandaloneTooltip,
                          child: Text(
                            appLocalizations.projectSearchStandaloneIndicator,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    Text(
                      appLocalizations.projectSearchFileMatchCount(
                        fileResult.matchCount,
                      ),
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
            if (expanded)
              for (final THProjectSearchMatch match in fileResult.matches)
                _MatchRow(
                  match: match,
                  onActivate: () => onActivateMatch(match),
                ),
          ],
        );
      },
    );
  }
}

class _MatchRow extends StatelessWidget {
  final THProjectSearchMatch match;
  final VoidCallback onActivate;

  const _MatchRow({required this.match, required this.onActivate});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final TextStyle baseStyle =
        theme.textTheme.bodySmall ?? const TextStyle();
    final int emphasisStart = match.previewMatchRange.start.clamp(
      0,
      match.linePreview.length,
    );
    final int emphasisEnd = match.previewMatchRange.end.clamp(
      emphasisStart,
      match.linePreview.length,
    );

    return InkWell(
      key: ValueKey<String>(
        'THProjectSearchResultWidget|Match|${match.canonicalPath}|'
        '${match.range.start}',
      ),
      onTap: onActivate,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: SizedBox(
          height: mpProjectSearchResultRowHeight,
          child: Row(
            children: <Widget>[
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: baseStyle,
                    children: <InlineSpan>[
                      TextSpan(
                        text: match.linePreview.substring(0, emphasisStart),
                      ),
                      TextSpan(
                        text: match.linePreview.substring(
                          emphasisStart,
                          emphasisEnd,
                        ),
                        style: baseStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          backgroundColor: theme
                              .colorScheme.primaryContainer,
                        ),
                      ),
                      TextSpan(
                        text: match.linePreview.substring(emphasisEnd),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                appLocalizations.projectSearchMatchLocation(
                  match.lineNumber,
                  match.columnNumber,
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
