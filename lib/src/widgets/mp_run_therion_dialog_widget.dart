import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_therion_runner.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:path/path.dart' as p;

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
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;
  VoidCallback? _statusListener;
  bool _hasAppendedPostRunOutput = false;

  @override
  void initState() {
    super.initState();

    _startTime = DateTime.now();

    final MPTherionRunner? injectedRunner = widget.therionRunner;

    if (injectedRunner != null) {
      _therionRunner = injectedRunner;
    } else {
      _therionRunner = MPTherionRunner(
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

    // Stop the timer only when the runner stops running (process exit).
    _statusListener = () {
      final bool isRunning = _therionRunner.isRunningNotifier.value;

      if (!isRunning) {
        _onTherionRunFinished();
      }
    };

    _therionRunner.isRunningNotifier.addListener(_statusListener!);
  }

  Future<void> _onTherionRunFinished() async {
    if (_hasAppendedPostRunOutput) {
      return;
    }

    _hasAppendedPostRunOutput = true;

    if (!mpIsFlathub) {
      final AppLocalizations appLocalizations = mpLocator.appLocalizations;
      final List<String> therionOutputLines = List<String>.from(
        _therionRunner.outputLinesNotifier.value,
      );

      final List<String> therionLogLines = await _readTherionLogLines(
        appLocalizations,
      );

      final List<String> postRunOutputLines = <String>[];
      postRunOutputLines.addAll(
        _buildSectionLines(
          beginHeader: appLocalizations.mapiahTherionRunTherionOutputBegin,
          endHeader: appLocalizations.mapiahTherionRunTherionOutputEnd,
          contentLines: therionOutputLines,
        ),
      );
      postRunOutputLines.addAll(
        _buildSectionLines(
          beginHeader: appLocalizations.mapiahTherionRunTherionLogBegin,
          endHeader: appLocalizations.mapiahTherionRunTherionLogEnd,
          contentLines: therionLogLines,
        ),
      );

      _therionRunner.outputLinesNotifier.value = <String>[];
      _therionRunner.issuesNotifier.value = <MPTherionIssue>[];
      _therionRunner.appendOutputLines(postRunOutputLines);
    }

    if (mounted && (_startTime != null)) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    }
  }

  List<String> _buildSectionLines({
    required String beginHeader,
    required String endHeader,
    required List<String> contentLines,
  }) {
    final List<String> sectionLines = <String>[];

    sectionLines.add(
      '$mpTherionOutputSectionDelimiter $beginHeader '
      '$mpTherionOutputSectionDelimiter',
    );
    sectionLines.addAll(contentLines);
    sectionLines.add(
      '$mpTherionOutputSectionDelimiter $endHeader '
      '$mpTherionOutputSectionDelimiter',
    );

    return sectionLines;
  }

  Future<List<String>> _readTherionLogLines(
    AppLocalizations appLocalizations,
  ) async {
    final DateTime? startTime = _startTime;

    if (startTime == null) {
      return <String>[appLocalizations.mapiahTherionRunNoTherionOutputFound];
    }

    final String thConfigDirectoryPath = p.dirname(widget.thConfigFilePath);
    final String therionLogFilePath = p.join(
      thConfigDirectoryPath,
      mpTherionLogFileName,
    );
    final File therionLogFile = File(therionLogFilePath);
    final bool therionLogFileExists = await therionLogFile.exists();

    if (!therionLogFileExists) {
      return <String>[appLocalizations.mapiahTherionRunNoTherionOutputFound];
    }

    final DateTime therionLogLastModified = await therionLogFile.lastModified();
    final bool therionLogIsNewerThanStartTime = therionLogLastModified.isAfter(
      startTime,
    );

    if (!therionLogIsNewerThanStartTime) {
      return <String>[appLocalizations.mapiahTherionRunNoTherionOutputFound];
    }

    final List<String> therionLogLines = await therionLogFile.readAsLines();

    return therionLogLines;
  }

  @override
  void dispose() {
    _outputSubscription?.cancel();
    if (_statusListener != null) {
      _therionRunner.isRunningNotifier.removeListener(_statusListener!);
    }

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
            // Elapsed time display (updates every second until run finishes)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  appLocalizations.mapiahTherionRunElapsedLabel(
                    _formatDuration(_elapsed),
                  ),
                ),
              ],
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
        outputSpans.add(const TextSpan(text: mpUnixLineBreak));
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

  String _formatDuration(Duration d) {
    final int hours = d.inHours;
    final int minutes = d.inMinutes.remainder(60);
    final double totalSeconds = d.inMilliseconds / 1000.0;
    final double seconds = totalSeconds - (hours * 3600) - (minutes * 60);

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String secondsWithTenth() {
      final String s = seconds.toStringAsFixed(1);
      // Ensure two-digit integer part for seconds (e.g. 09.3)
      if (seconds < 10) {
        return '0$s';
      }
      return s;
    }

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${secondsWithTenth()}';
    } else if (minutes > 0) {
      return '${twoDigits(minutes)}:${secondsWithTenth()}';
    }

    return secondsWithTenth();
  }
}
