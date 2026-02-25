import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_therion_runner.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPRunTherionDialogWidget extends StatefulWidget {
  final String therionExecutablePath;
  final String thConfigFilePath;
  final MPTherionRunner? therionRunner;

  const MPRunTherionDialogWidget({
    required this.therionExecutablePath,
    required this.thConfigFilePath,
    this.therionRunner,
    super.key,
  });

  @override
  State<MPRunTherionDialogWidget> createState() =>
      _MPRunTherionDialogWidgetState();
}

class _MPRunTherionDialogWidgetState extends State<MPRunTherionDialogWidget> {
  final ScrollController _scrollController = ScrollController();

  late final MPTherionRunner _therionRunner;
  StreamSubscription<String>? _outputSubscription;

  @override
  void initState() {
    super.initState();

    final MPTherionRunner? injectedRunner = widget.therionRunner;

    if (injectedRunner != null) {
      _therionRunner = injectedRunner;
    } else {
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
    }

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
                        final TextSpan outputTextSpan = _buildOutputTextSpan(
                          outputLines: outputLines,
                          baseStyle: theme.textTheme.bodyMedium,
                        );

                        return SingleChildScrollView(
                          controller: _scrollController,
                          child: SelectionArea(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text.rich(
                                outputTextSpan,
                                textAlign: TextAlign.left,
                              ),
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
    final bool hasScrollClients = _scrollController.hasClients;
    final List<String> outputLines = _therionRunner.outputLinesNotifier.value;
    final int lineCount = outputLines.length;
    final bool hasEnoughLinesToScroll = lineCount > 1;

    if (!hasScrollClients || !hasEnoughLinesToScroll) {
      return;
    }

    final int lastLineIndex = lineCount - 1;
    final int clampedLineIndex = lineIndex.clamp(0, lastLineIndex);
    final double maxScrollExtent = _scrollController.position.maxScrollExtent;
    final double lineProgress = clampedLineIndex / lastLineIndex;
    final double targetOffset = (lineProgress * maxScrollExtent).clamp(
      0.0,
      maxScrollExtent,
    );

    _scrollController.animateTo(
      targetOffset,
      duration: mpTherionRunScrollAnimationDuration,
      curve: mpTherionRunScrollAnimationCurve,
    );
  }

  TextSpan _buildOutputTextSpan({
    required List<String> outputLines,
    required TextStyle? baseStyle,
  }) {
    final List<TextSpan> outputSpans = <TextSpan>[];
    final int outputLineCount = outputLines.length;

    for (int lineIndex = 0; lineIndex < outputLineCount; lineIndex++) {
      final String outputLineText = outputLines[lineIndex];
      final List<TextSpan> highlightedLineSpans = _buildHighlightedSpans(
        outputLineText,
      );
      outputSpans.addAll(highlightedLineSpans);

      final bool isLastOutputLine = lineIndex == outputLineCount - 1;
      if (!isLastOutputLine) {
        outputSpans.add(const TextSpan(text: thUnixLineBreak));
      }
    }

    return TextSpan(style: baseStyle, children: outputSpans);
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
