import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_text_field_input_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPStationNamesOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPStationNamesOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPStationNamesOptionWidget> createState() =>
      _MPStationNamesOptionWidgetState();
}

class _MPStationNamesOptionWidgetState
    extends State<MPStationNamesOptionWidget> {
  late String _selectedChoice;
  late TextEditingController _prefixController;
  late TextEditingController _suffixController;
  final FocusNode _prefixFieldFocusNode = FocusNode();
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  late final String _initialPrefix;
  late final String _initialSuffix;
  late final String _initialSelectedChoice;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  String? _prefixWarningMessage;
  String? _suffixWarningMessage;
  bool _isValid = false;
  bool _isOkButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THStationNamesCommandOption currentOption =
            widget.optionInfo.option! as THStationNamesCommandOption;

        _prefixController = TextEditingController(
          text: currentOption.prefix.trim(),
        );
        _suffixController = TextEditingController(
          text: currentOption.suffix.trim(),
        );
        _selectedChoice = mpNonMultipleChoiceSetID;
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _prefixController = TextEditingController(text: '');
        _suffixController = TextEditingController(text: '');
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _prefixController = TextEditingController(text: '');
        _suffixController = TextEditingController(text: '');
        _selectedChoice = mpUnsetOptionID;
    }

    _initialPrefix = _prefixController.text;
    _initialSuffix = _suffixController.text;
    _initialSelectedChoice = _selectedChoice;

    _updateIsValid();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasExecutedSingleRunOfPostFrameCallback) {
        _hasExecutedSingleRunOfPostFrameCallback = true;
        _executeOnceAfterBuild();
      }
    });
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _suffixController.dispose();
    _prefixFieldFocusNode.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _prefixFieldFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      /// The THFileMPID is used only as a placeholder for the actual
      /// parentMPID of the option(s) to be set. THFile isn't even a
      /// THHasOptionsMixin so it can't actually be the parent of an option,
      /// i.e., is has no options at all.
      newOption = THStationNamesCommandOption.forCWJM(
        parentMPID: widget.th2FileEditController.thFileMPID,
        originalLineInTH2File: '',
        prefix: _prefixController.text.trim(),
        suffix: _suffixController.text.trim(),
      );
    }

    widget.th2FileEditController.userInteractionController.prepareSetOption(
      option: newOption,
      optionType: widget.optionInfo.type,
    );
  }

  void _cancelButtonPressed() {
    widget.th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.optionChoices,
      false,
    );
  }

  void _updateIsValid() {
    switch (_selectedChoice) {
      case mpUnsetOptionID:
        _isValid = true;
      case mpNonMultipleChoiceSetID:
        final bool isPrefixValid = _prefixController.text.trim().isNotEmpty;
        final bool isSuffixValid = _suffixController.text.trim().isNotEmpty;

        _prefixWarningMessage = isPrefixValid
            ? null
            : appLocalizations.mpStationNamesPrefixMessageEmpty;
        _suffixWarningMessage = isSuffixValid
            ? null
            : appLocalizations.mpStationNamesSuffixMessageEmpty;
        _isValid = isPrefixValid && isSuffixValid;
      default:
        _isValid = false;
    }

    _updateIsOkButtonEnabled();
  }

  void _updateIsOkButtonEnabled() {
    final bool isChanged =
        ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            ((_prefixController.text != _initialPrefix) ||
                (_suffixController.text != _initialSuffix))));

    setState(() {
      _isOkButtonEnabled = _isValid && isChanged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionStationNames,
      overlayWindowType: MPOverlayWindowType.secondary,
      outerAnchorPosition: widget.outerAnchorPosition,
      innerAnchorType: widget.innerAnchorType,
      th2FileEditController: widget.th2FileEditController,
      children: [
        const SizedBox(height: mpButtonSpace),
        MPOverlayWindowBlockWidget(
          overlayWindowBlockType: MPOverlayWindowBlockType.secondary,
          padding: mpOverlayWindowBlockEdgeInsets,
          children: [
            RadioListTile<String>(
              title: Text(appLocalizations.mpChoiceUnset),
              value: mpUnsetOptionID,
              groupValue: _selectedChoice,
              contentPadding: EdgeInsets.zero,
              onChanged: (String? value) {
                if (value != null) {
                  _selectedChoice = value;
                  _updateIsValid();
                }
              },
            ),
            RadioListTile<String>(
              title: Text(appLocalizations.mpChoiceSet),
              value: mpNonMultipleChoiceSetID,
              groupValue: _selectedChoice,
              contentPadding: EdgeInsets.zero,
              onChanged: (String? value) {
                if (value != null) {
                  _selectedChoice = value;
                  _updateIsValid();
                }
              },
            ),

            // Additional Inputs for "Set" Option
            if (_selectedChoice == mpNonMultipleChoiceSetID) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MPTextFieldInputWidget(
                    controller: _prefixController,
                    errorText: _prefixWarningMessage,
                    labelText: appLocalizations.mpStationNamesPrefixLabel,
                    autofocus: true,
                    focusNode: _prefixFieldFocusNode,
                    onChanged: (value) {
                      _updateIsValid();
                    },
                  ),
                  const SizedBox(width: mpButtonSpace),
                  MPTextFieldInputWidget(
                    labelText: appLocalizations.mpStationNamesSuffixLabel,
                    controller: _suffixController,
                    errorText: _suffixWarningMessage,
                    onChanged: (value) {
                      _updateIsValid();
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: mpButtonSpace),
        Row(
          children: [
            ElevatedButton(
              onPressed: _isOkButtonEnabled ? _okButtonPressed : null,
              style: ElevatedButton.styleFrom(
                elevation: _isOkButtonEnabled ? null : 0.0,
              ),
              child: Text(appLocalizations.mpButtonOK),
            ),
            const SizedBox(width: mpButtonSpace),
            ElevatedButton(
              onPressed: _cancelButtonPressed,
              child: Text(appLocalizations.mpButtonCancel),
            ),
          ],
        ),
      ],
    );
  }
}
