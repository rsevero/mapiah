import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
import 'package:mapiah/src/widgets/mp_add_scrap_dialog_widget.dart';
import 'package:mapiah/src/widgets/mp_encoding_widget.dart';

class MPAddFileDialogWidget extends StatefulWidget {
  final VoidCallback onPressedClose;

  const MPAddFileDialogWidget({super.key, required this.onPressedClose});

  @override
  State<MPAddFileDialogWidget> createState() => _MPAddFileDialogWidgetState();
}

class _MPAddFileDialogWidgetState extends State<MPAddFileDialogWidget> {
  String _selectedEncoding = mpDefaultEncoding;
  String _validScrapTHID = '';
  THProjectionCommandOption? _projectionOption;
  THScrapScaleCommandOption? _scaleOption;
  bool _scrapConfigValid = false;

  final GlobalKey<MPEncodingWidgetState> _encodingKey = GlobalKey();
  final GlobalKey _scrapKernelKey = GlobalKey();

  bool get _isOkEnabled => _scrapConfigValid;

  final AppLocalizations appLocalizations = mpLocator.appLocalizations;

  void _onOkPressed() {
    if (!_isOkEnabled) return;
    final String scrapTHID = _validScrapTHID;
    final String encoding = _selectedEncoding;
    final List<THCommandOption> scrapOptions = [];

    if (_projectionOption != null) {
      scrapOptions.add(_projectionOption!);
    }
    if (_scaleOption != null) {
      scrapOptions.add(_scaleOption!);
    }

    final TH2FileEditController th2FileEditController = mpLocator
        .mpGeneralController
        .getTH2FileEditControllerForNewFile(
          scrapTHID: scrapTHID,
          scrapOptions: scrapOptions,
          encoding: encoding,
        );
    final String fileName = th2FileEditController.thFile.filename;

    th2FileEditController.setCanvasScale(thDefaultTHFileScale);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TH2FileEditPage(
          key: ValueKey("TH2FileEditPage|$fileName"),
          filename: fileName,
          th2FileEditController: th2FileEditController,
        ),
      ),
    );

    widget.onPressedClose();
  }

  void _onCancelPressed() {
    widget.onPressedClose();
  }

  // Generic helper to defer a state update until after the current frame,
  // avoiding setState() during build and reducing repeated boilerplate.
  void _deferUpdate<T>(
    T newValue,
    T Function() currentGetter,
    void Function(T) assign,
  ) {
    if ((!mounted) || (currentGetter() == newValue)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (currentGetter() != newValue) {
        setState(() => assign(newValue));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          appLocalizations.mpNewScrapDialogCreateNewScrap,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: mpButtonSpace),

        // 1. Encoding widget (dropdown)
        Text(
          appLocalizations.mpEncodingLabel,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        MPEncodingWidget(
          key: _encodingKey,
          currentEncoding: null,
          showActionButtons: false,
          onValidOptionChanged: (enc) {
            if (enc != null) _selectedEncoding = enc;
          },
        ),

        // 2. Scrap configuration (id + scale + projection)
        const SizedBox(height: mpButtonSpace * 2),
        MPAddScrapDialogWidget(
          key: _scrapKernelKey,
          initialScrapTHID: '${mpScrapTHIDPrefix}1',
          showActionButtons: false,
          onValidScrapTHIDChanged: (id) => _deferUpdate<String>(
            id,
            () => _validScrapTHID,
            (v) => _validScrapTHID = v,
          ),
          onProjectionChanged: (opt) => _projectionOption = opt,
          onScaleChanged: (opt) => _scaleOption = opt,
          onValidityChanged: (isValid) => _deferUpdate<bool>(
            isValid,
            () => _scrapConfigValid,
            (v) => _scrapConfigValid = v,
          ),
        ),

        // Action buttons
        const SizedBox(height: mpButtonSpace),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _onCancelPressed,
              child: Text(appLocalizations.mpButtonCancel),
            ),
            const SizedBox(width: mpButtonSpace),
            ElevatedButton(
              onPressed: _isOkEnabled ? _onOkPressed : null,
              child: Text(appLocalizations.mpButtonOK),
            ),
          ],
        ),
      ],
    );
  }
}
