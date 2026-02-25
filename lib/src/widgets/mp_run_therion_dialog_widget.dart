import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_therion_runner.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

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
  final StringBuffer _outputBuffer = StringBuffer();

  late final MPTherionRunner _therionRunner;
  StreamSubscription<String>? _outputSubscription;
  bool _isRunning = true;

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
    _therionRunner.isRunningNotifier.addListener(_onRunningChanged);

    _therionRunner.start();
  }

  @override
  void dispose() {
    _outputSubscription?.cancel();
    _therionRunner.isRunningNotifier.removeListener(_onRunningChanged);
    _therionRunner.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _onRunningChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      _isRunning = _therionRunner.isRunningNotifier.value;
    });
  }

  void _appendOutput(String text) {
    if (text.isEmpty) {
      return;
    }

    if (!mounted) {
      _outputBuffer.write(text);
      return;
    }

    setState(() {
      _outputBuffer.write(text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = mpLocator.appLocalizations;
    final ThemeData theme = Theme.of(context);
    final String status = _isRunning
        ? appLocalizations.mapiahTherionRunStatusRunning
        : appLocalizations.mapiahTherionRunStatusOk;

    return AlertDialog(
      title: Text(appLocalizations.mapiahTherionRunDialogTitle),
      content: SizedBox(
        width: mpTherionRunDialogWidth,
        height: mpTherionRunDialogHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: mpTherionRunOutputBorderWidth,
                    ),
                    borderRadius: BorderRadius.circular(mpDefaultButtonRadius),
                  ),
                  child: Text(status),
                ),
              ],
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
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: SelectableText(
                    _outputBuffer.toString(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.buttonClose),
        ),
      ],
    );
  }
}
