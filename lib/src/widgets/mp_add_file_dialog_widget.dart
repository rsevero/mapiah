import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
import 'package:mapiah/src/widgets/mp_encoding_widget.dart';
import 'package:mapiah/src/widgets/options/mp_projection_option_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';

class MPAddFileDialogWidget extends StatefulWidget {
  final VoidCallback onPressedClose;

  const MPAddFileDialogWidget({super.key, required this.onPressedClose});

  @override
  State<MPAddFileDialogWidget> createState() => _MPAddFileDialogWidgetState();
}

class _MPAddFileDialogWidgetState extends State<MPAddFileDialogWidget> {
  final TextEditingController _scrapTHIDController = TextEditingController();
  final FocusNode _scrapTHIDFocusNode = FocusNode();
  String? _scrapTHIDError;

  // Projection & Encoding selections
  THProjectionCommandOption? _selectedProjectionOption;
  String _selectedEncoding = mpDefaultEncoding;

  // Keys (if parent later wants to pull state, kept internal now)
  final GlobalKey<MPProjectionOptionWidgetState> _projectionKey =
      GlobalKey<MPProjectionOptionWidgetState>();
  final GlobalKey<MPEncodingWidgetState> _encodingKey =
      GlobalKey<MPEncodingWidgetState>();

  bool get _isValidScrapID => _scrapTHIDError == null;
  bool get _isOkEnabled => _isValidScrapID;

  final AppLocalizations appLocalizations = mpLocator.appLocalizations;

  @override
  void initState() {
    super.initState();
    _scrapTHIDController.text = "${mpScrapTHIDPrefix}1";
    _validateScrapID();
  }

  @override
  void dispose() {
    _scrapTHIDController.dispose();
    _scrapTHIDFocusNode.dispose();
    super.dispose();
  }

  void _validateScrapID() {
    final String text = _scrapTHIDController.text.trim();

    String? err;

    if (text.isEmpty) {
      err = appLocalizations.mpIDMissingErrorMessage;
    } else if (!RegExp(r'^[a-zA-Z0-9_][a-zA-Z0-9_\-]*$').hasMatch(text)) {
      err = appLocalizations.mpIDInvalidValueErrorMessage;
    }

    setState(() {
      _scrapTHIDError = err;
    });
  }

  void _onOkPressed() {
    if (!_isOkEnabled) return;

    final String scrapTHID = _scrapTHIDController.text.trim();
    final THProjectionCommandOption? proj = _selectedProjectionOption;
    final String encoding = _selectedEncoding;
    final TH2FileEditController th2FileEditController = mpLocator
        .mpGeneralController
        .getTH2FileEditControllerForNewFile(
          scrapTHID: scrapTHID,
          projectionOption: proj,
          encoding: encoding,
        );
    final String fileName = th2FileEditController.thFile.filename;

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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MPOptionInfo projectionOptionInfo = MPOptionInfo(
      type: THCommandOptionType.projection,
      state: MPOptionStateType.unset,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          appLocalizations.mpNewScrapDialogCreateNewScrap,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: mpButtonSpace),

        // 1. Scrap name field
        TextField(
          controller: _scrapTHIDController,
          focusNode: _scrapTHIDFocusNode,
          autofocus: true,
          onChanged: (_) => _validateScrapID(),
          decoration: InputDecoration(
            labelText: appLocalizations.mpNewScrapDialogCreateScrapIDLabel,
            errorText: _scrapTHIDError,
            hintText: appLocalizations.mpNewScrapDialogCreateScrapIDHint,
          ),
        ),
        const SizedBox(height: mpButtonSpace),

        // 2. Encoding widget (dropdown)
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
        const SizedBox(height: mpButtonSpace * 2),

        // 3. Projection option widget (no internal buttons)
        Text(appLocalizations.thProjection, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        MPProjectionOptionWidget(
          key: _projectionKey,
          optionInfo: projectionOptionInfo,
          showActionButtons: false,
          onValidOptionChanged: (opt) {
            _selectedProjectionOption = opt;
          },
        ),
        const SizedBox(height: mpButtonSpace),

        // Action buttons
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
