import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/options/mp_projection_option_widget.dart';
import 'package:mapiah/src/widgets/options/mp_scrap_scale_option_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';

/// Kernel widget that collects scrap parameters (id, scale, projection).
class MPAddScrapDialogWidget extends StatefulWidget {
  final TH2FileEditController fileEditController;
  final String? initialScrapTHID;
  final ValueChanged<String>? onValidScrapTHIDChanged;
  final ValueChanged<THProjectionCommandOption?>? onProjectionChanged;
  final ValueChanged<THScrapScaleCommandOption?>? onScaleChanged;
  final bool showActionButtons;
  final VoidCallback? onPressedCreate;
  final VoidCallback? onPressedCancel;

  const MPAddScrapDialogWidget({
    super.key,
    required this.fileEditController,
    this.initialScrapTHID,
    this.onValidScrapTHIDChanged,
    this.onProjectionChanged,
    this.onScaleChanged,
    this.showActionButtons = false,
    this.onPressedCreate,
    this.onPressedCancel,
  });

  @override
  State<MPAddScrapDialogWidget> createState() => _MPAddScrapDialogWidgetState();
}

class _MPAddScrapDialogWidgetState extends State<MPAddScrapDialogWidget> {
  late final TextEditingController _scrapTHIDController;
  String? _scrapTHIDError;
  bool get _isValidScrapID => _scrapTHIDError == null;

  final GlobalKey<MPProjectionOptionWidgetState> _projectionKey = GlobalKey();
  final GlobalKey<MPScrapScaleOptionWidgetState> _scaleKey = GlobalKey();
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;

  @override
  void initState() {
    super.initState();
    _scrapTHIDController = TextEditingController(
      text: widget.initialScrapTHID ?? '',
    );
    _validateScrapID();
  }

  @override
  void dispose() {
    _scrapTHIDController.dispose();
    super.dispose();
  }

  void _validateScrapID() {
    final String text = _scrapTHIDController.text.trim();

    String? err;

    if (text.isEmpty) {
      err = appLocalizations.mpIDMissingErrorMessage;
    } else if (!RegExp(r'^[a-zA-Z0-9_][a-zA-Z0-9_\-]*$').hasMatch(text)) {
      err = appLocalizations.mpIDInvalidValueErrorMessage;
    } else if (widget.fileEditController.thFile.hasElementByTHID(text)) {
      err = appLocalizations.mpIDNonUniqueValueErrorMessage;
    }
    setState(() {
      _scrapTHIDError = err;
    });
    if (err == null) {
      widget.onValidScrapTHIDChanged?.call(text);
    } else {
      widget.onValidScrapTHIDChanged?.call('');
    }
  }

  bool get _isCreateEnabled => _isValidScrapID;

  void _internalCreate() {
    if (!_isCreateEnabled) return;
    widget.onPressedCreate?.call();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MPOptionInfo projectionInfo = MPOptionInfo(
      type: THCommandOptionType.projection,
      state: MPOptionStateType.unset,
    );
    final MPOptionInfo scaleInfo = MPOptionInfo(
      type: THCommandOptionType.scrapScale,
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
        TextField(
          controller: _scrapTHIDController,
          autofocus: true,
          onChanged: (_) => _validateScrapID(),
          onSubmitted: (_) {
            if (_isCreateEnabled) _internalCreate();
          },
          decoration: InputDecoration(
            labelText: appLocalizations.mpNewScrapDialogCreateScrapIDLabel,
            errorText: _scrapTHIDError,
            hintText: appLocalizations.mpNewScrapDialogCreateScrapIDHint,
          ),
        ),

        const SizedBox(height: mpButtonSpace),
        const Divider(thickness: 1),
        const SizedBox(height: mpButtonSpace),
        Text(
          appLocalizations.thCommandOptionScrapScale,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: mpButtonSpace / 2),
        MPScrapScaleOptionWidget(
          key: _scaleKey,
          optionInfo: scaleInfo,
          showActionButtons: false,
          onValidOptionChanged: widget.onScaleChanged,
        ),
        const SizedBox(height: mpButtonSpace),
        const Divider(thickness: 1),
        const SizedBox(height: mpButtonSpace),
        Text(appLocalizations.thProjection, style: theme.textTheme.titleSmall),
        const SizedBox(height: mpButtonSpace / 2),
        MPProjectionOptionWidget(
          key: _projectionKey,
          optionInfo: projectionInfo,
          showActionButtons: false,
          onValidOptionChanged: widget.onProjectionChanged,
        ),

        if (widget.showActionButtons) ...[
          const SizedBox(height: mpButtonSpace * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onPressedCancel,
                child: Text(appLocalizations.mpButtonCancel),
              ),
              const SizedBox(width: mpButtonSpace),
              ElevatedButton(
                onPressed: _isCreateEnabled ? _internalCreate : null,
                child: Text(appLocalizations.mpButtonCreate),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
