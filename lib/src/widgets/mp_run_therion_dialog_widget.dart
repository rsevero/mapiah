import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_therion_runner.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPRunTherionDialogWidget extends StatefulWidget {
  final String therionExecutablePath;
  final String thConfigFilePath;

  const MPRunTherionDialogWidget({
    required this.therionExecutablePath,
    required this.thConfigFilePath,
    super.key,
  });

  @override
  State<MPRunTherionDialogWidget> createState() =>
      _MPRunTherionDialogWidgetState();
}

class _MPRunTherionDialogWidgetState extends State<MPRunTherionDialogWidget> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = <int, GlobalKey>{};

  late final MPTherionRunner _therionRunner;
  StreamSubscription<String>? _outputSubscription;

  @override
  void initState() {
    super.initState();

    _therionRunner = MPTherionRunner(
      therionExecutablePath: widget.therionExecutablePath,
      thConfigFilePath: widget.thConfigFilePath,
      onError: (error, stackTrace) {
        mpLocator.mpLog.e(
          'Failed to run Therion',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    _outputSubscription = _therionRunner.outputStream.listen(_appendOutput);

    _therionRunner.start();
  }

  @override
  void dispose() {
    _outputSubscription?.cancel();
    _therionRunner.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _appendOutput(String text) {
    if (text.isEmpty || !mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final ThemeData theme = Theme.of(context);

    return AlertDialog(
      title: Text(appLocalizations.mapiahTherionRunDialogTitle),
      content: SizedBox(
        width: mpTherionRunDialogWidth,
        height: mpTherionRunDialogHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<MPTherionRunStatus>(
              valueListenable: _therionRunner.statusNotifier,
              builder:
                  (
                    BuildContext context,
                    MPTherionRunStatus runStatus,
                    Widget? child,
                  ) {
                    final String statusText = _statusText(
                      appLocalizations,
                      runStatus,
                    );
                    final Color statusBackgroundColor = _statusBackgroundColor(
                      runStatus,
                    );

                    return Row(
                      children: [
                        Text(appLocalizations.mapiahTherionRunStatusLabel),
                        const SizedBox(width: mpTherionRunDialogSpacing),
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: mpTherionRunStatusBoxMinWidth,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: mpSettingsPageFieldSpacing,
                            horizontal: mpSettingsPageCardPadding,
                          ),
                          decoration: BoxDecoration(
                            color: statusBackgroundColor,
                            border: Border.all(
                              color: theme.colorScheme.outline,
                              width: mpTherionRunOutputBorderWidth,
                            ),
                            borderRadius: BorderRadius.circular(
                              mpDefaultButtonRadius,
                            ),
                          ),
                          child: Text(statusText),
                        ),
                      ],
                    );
                  },
            ),
            const SizedBox(height: mpTherionRunDialogSpacing),
            Text(appLocalizations.mapiahTherionRunOutputLabel),
            const SizedBox(height: mpSettingsPageFieldSpacing),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(mpSettingsPageCardPadding),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: mpTherionRunOutputBorderWidth,
                  ),
                  borderRadius: BorderRadius.circular(mpDefaultButtonRadius),
                ),
                child: ValueListenableBuilder<List<String>>(
                  valueListenable: _therionRunner.outputLinesNotifier,
                  builder:
                      (
                        BuildContext context,
                        List<String> outputLines,
                        Widget? child,
                      ) {
                        return SingleChildScrollView(
                          controller: _scrollController,
                          child: SelectionArea(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: outputLines.asMap().entries.map((
                                MapEntry<int, String> entry,
                              ) {
                                final int lineIndex = entry.key;
                                final String lineText = entry.value;
                                final GlobalKey lineKey = _lineKeys.putIfAbsent(
                                  lineIndex,
                                  () => GlobalKey(),
                                );
                                final List<TextSpan> highlightedSpans =
                                    _buildHighlightedSpans(lineText);

                                return Container(
                                  key: lineKey,
                                  alignment: Alignment.centerLeft,
                                  child: Text.rich(
                                    TextSpan(
                                      style: theme.textTheme.bodyMedium,
                                      children: highlightedSpans,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                ),
              ),
            ),
            const SizedBox(height: mpTherionRunDialogSpacing),
            ValueListenableBuilder<List<MPTherionIssue>>(
              valueListenable: _therionRunner.issuesNotifier,
              builder:
                  (
                    BuildContext context,
                    List<MPTherionIssue> issues,
                    Widget? child,
                  ) {
                    if (issues.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return SizedBox(
                      height: mpTherionRunIssuesListHeight,
                      child: ListView.builder(
                        itemCount: issues.length,
                        itemBuilder: (BuildContext context, int index) {
                          final MPTherionIssue issue = issues[index];
                          final bool isError =
                              issue.kind == MPTherionIssueKind.error;
                          final String issuePrefix = isError
                              ? appLocalizations.mapiahTherionRunStatusError
                              : appLocalizations.mapiahTherionRunStatusWarning;
                          final Color issueColor = isError
                              ? mpTherionRunOutputErrorColor
                              : mpTherionRunOutputWarningColor;

                          return InkWell(
                            onTap: () => _jumpToLine(issue.lineIndex),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: mpSettingsPageFieldSpacing,
                              ),
                              child: Text(
                                '$issuePrefix: ${issue.lineText}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: issueColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _therionRunner.stop();
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.buttonClose),
        ),
      ],
    );
  }

  void _jumpToLine(int lineIndex) {
    final GlobalKey? lineKey = _lineKeys[lineIndex];

    if (lineKey == null) {
      return;
    }

    final BuildContext? lineContext = lineKey.currentContext;

    if (lineContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      lineContext,
      duration: mpTherionRunScrollAnimationDuration,
      alignment: 0.1,
    );
  }

  String _statusText(
    AppLocalizations appLocalizations,
    MPTherionRunStatus status,
  ) {
    switch (status) {
      case MPTherionRunStatus.running:
        return appLocalizations.mapiahTherionRunStatusRunning;
      case MPTherionRunStatus.ok:
        return appLocalizations.mapiahTherionRunStatusOk;
      case MPTherionRunStatus.warning:
        return appLocalizations.mapiahTherionRunStatusWarning;
      case MPTherionRunStatus.error:
        return appLocalizations.mapiahTherionRunStatusError;
    }
  }

  Color _statusBackgroundColor(MPTherionRunStatus status) {
    switch (status) {
      case MPTherionRunStatus.running:
        return mpTherionRunStatusBackgroundRunningColor;
      case MPTherionRunStatus.ok:
        return mpTherionRunStatusBackgroundOkColor;
      case MPTherionRunStatus.warning:
        return mpTherionRunStatusBackgroundWarningColor;
      case MPTherionRunStatus.error:
        return mpTherionRunStatusBackgroundErrorColor;
    }
  }

  List<TextSpan> _buildHighlightedSpans(String lineText) {
    final RegExp keywordRegex = RegExp(
      '($mpTherionWarningWord|$mpTherionErrorWord)',
      caseSensitive: false,
    );
    final List<TextSpan> spans = <TextSpan>[];
    int currentIndex = 0;

    for (final RegExpMatch match in keywordRegex.allMatches(lineText)) {
      if (match.start > currentIndex) {
        final String plainChunk = lineText.substring(currentIndex, match.start);
        spans.add(TextSpan(text: plainChunk));
      }

      final String matchedText = match.group(0) ?? '';
      final String loweredText = matchedText.toLowerCase();
      final bool isError = loweredText == mpTherionErrorWord;
      final Color keywordColor = isError
          ? mpTherionRunOutputErrorColor
          : mpTherionRunOutputWarningColor;

      spans.add(
        TextSpan(
          text: matchedText,
          style: TextStyle(color: keywordColor, fontWeight: FontWeight.bold),
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < lineText.length) {
      final String trailingChunk = lineText.substring(currentIndex);
      spans.add(TextSpan(text: trailingChunk));
    }

    return spans;
  }
}
