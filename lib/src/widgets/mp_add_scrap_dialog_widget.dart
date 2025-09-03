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
  final TH2FileEditController? fileEditController;
  final String? initialScrapTHID;
  final ValueChanged<String>? onValidScrapTHIDChanged;
  final ValueChanged<THProjectionCommandOption?>? onProjectionChanged;
  final ValueChanged<THScrapScaleCommandOption?>? onScaleChanged;
  final ValueChanged<bool>? onValidityChanged;
  final bool showActionButtons;
  final VoidCallback? onPressedCreate;
  final VoidCallback? onPressedCancel;

  const MPAddScrapDialogWidget({
    super.key,
    this.fileEditController,
    this.initialScrapTHID,
    this.onValidScrapTHIDChanged,
    this.onProjectionChanged,
    this.onScaleChanged,
    this.onValidityChanged,
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
  bool _isValid = false;
  bool _pendingValidation = false;
  bool _hasSentInitialValidityCallback = false;
  bool _isInitializing = true; // avoids setState during init/build

  final GlobalKey<MPProjectionOptionWidgetState> _projectionKey = GlobalKey();
  final GlobalKey<MPScrapScaleOptionWidgetState> _scaleKey = GlobalKey();
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;

  @override
  void initState() {
    super.initState();
    _scrapTHIDController = TextEditingController(
      text: widget.initialScrapTHID ?? '',
    );
    // Compute initial error without setState to avoid build-phase mutation.
    _scrapTHIDError = _computeScrapIDError(_scrapTHIDController.text.trim());
    // Defer full validation (which may call setState) until after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _isInitializing = false;
      _validateScrap();
    });
  }

  @override
  void dispose() {
    _scrapTHIDController.dispose();
    super.dispose();
  }

  String? _computeScrapIDError(String text) {
    if (text.isEmpty) {
      return appLocalizations.mpIDMissingErrorMessage;
    } else if (!RegExp(r'^[a-zA-Z0-9_][a-zA-Z0-9_\-]*$').hasMatch(text)) {
      return appLocalizations.mpIDInvalidValueErrorMessage;
    } else if (widget.fileEditController?.thFile.hasElementByTHID(text) ??
        false) {
      return appLocalizations.mpIDNonUniqueValueErrorMessage;
    }
    return null;
  }

  void _validateScrapID() {
    final String text = _scrapTHIDController.text.trim();
    final String? err = _computeScrapIDError(text);

    if (_isInitializing) {
      // Direct assignment; no setState during build.
      _scrapTHIDError = err;
    } else if (_scrapTHIDError != err) {
      setState(() => _scrapTHIDError = err);
    }
    final bool isValidNow = err == null;
    // Always notify (deferred parent handles its own post-frame safety).
    widget.onValidScrapTHIDChanged?.call(isValidNow ? text : '');
  }

  void _validateScrap() {
    // Ensure scrap ID error & callback updated before overall validation aggregation.
    _validateScrapID();

    final bool scrapIDValid = _isValidScrapID;
    final bool projectionValid = _projectionKey.currentState?.isValid ?? true;
    final bool scaleValid = _scaleKey.currentState?.isValid ?? true;
    final bool newValid = scrapIDValid && projectionValid && scaleValid;

    if ((newValid == _isValid) || _pendingValidation) {
      return;
    }

    _pendingValidation = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pendingValidation = false;
      if (!mounted) {
        return;
      }
      if (_isValid != newValid) {
        setState(() => _isValid = newValid);
        widget.onValidityChanged?.call(newValid);
      } else {
        // Still notify if state unchanged but we never notified before (initial call path)
        if (!_hasSentInitialValidityCallback) {
          widget.onValidityChanged?.call(newValid);
        }
      }
      _hasSentInitialValidityCallback = true;
    });
  }

  bool get _isCreateEnabled => _isValid;

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
          onChanged: (_) => _validateScrap(),
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
          onValidOptionChanged: (opt) {
            widget.onScaleChanged?.call(opt);
            _validateScrap();
          },
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
          onValidOptionChanged: (opt) {
            widget.onProjectionChanged?.call(opt);
            _validateScrap();
          },
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
