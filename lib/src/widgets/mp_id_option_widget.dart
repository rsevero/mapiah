import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPIDOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPIDOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPIDOptionWidget> createState() => _MPIDOptionWidgetState();
}

class _MPIDOptionWidgetState extends State<MPIDOptionWidget> {
  late TextEditingController _thIDController;
  late String _selectedChoice;
  final FocusNode _idTextFieldFocusNode = FocusNode();
  late final String _initialChoice;
  late final String _initialID;
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  String _warningMessage = '';
  bool _isValid = false;

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THIDCommandOption currentOption =
            (widget.optionInfo.option! as THIDCommandOption);

        _thIDController = TextEditingController(
          text: currentOption.thID,
        );

        _selectedChoice = mpNonMultipleChoiceSetID;
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _thIDController = TextEditingController(text: '');
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _thIDController = TextEditingController(text: '');
        _selectedChoice = mpUnsetOptionID;
    }

    _initialChoice = _selectedChoice;
    _initialID = _thIDController.text;

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
    _thIDController.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _idTextFieldFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      final String thID = _thIDController.text.trim();

      if (thID.isNotEmpty) {
        /// The THFileMPID is used only as a placeholder for the actual
        /// parentMPID of the option(s) to be set. THFile isn't even a
        /// THHasOptionsMixin so it can't actually be the parent of an option,
        /// i.e., is has no options at all.
        newOption = THIDCommandOption.fromStringWithParentMPID(
          parentMPID: widget.th2FileEditController.thFileMPID,
          thID: thID,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.mpIDInvalidValueErrorMessage),
          ),
        );
        return;
      }
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
    if (_selectedChoice == mpUnsetOptionID) {
      setState(
        () {
          _warningMessage = '';
          _isValid = true;
        },
      );
    } else if (MPInteractionAux.isValidID(_thIDController.text)) {
      if (widget.th2FileEditController.thFile
          .hasElementByTHID(_thIDController.text)) {
        setState(
          () {
            _warningMessage = appLocalizations.mpIDNonUniqueValueErrorMessage;
            _isValid = false;
          },
        );
      } else {
        setState(
          () {
            _warningMessage = '';
            _isValid = true;
          },
        );
      }
    } else {
      setState(
        () {
          _warningMessage = appLocalizations.mpIDInvalidValueErrorMessage;
          _isValid = false;
        },
      );
    }
  }

  bool _isChanged() {
    return ((_selectedChoice != _initialChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            (_thIDController.text != _initialID)));
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionId,
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
                _selectedChoice = value!;
                _updateIsValid();
              },
            ),
            RadioListTile<String>(
              title: Text(appLocalizations.mpChoiceSet),
              value: mpNonMultipleChoiceSetID,
              groupValue: _selectedChoice,
              contentPadding: EdgeInsets.zero,
              onChanged: (String? value) {
                _selectedChoice = value!;
                _updateIsValid();
                _idTextFieldFocusNode.requestFocus();
              },
            ),

            // Additional Inputs for "Set" Option
            if (_selectedChoice == mpNonMultipleChoiceSetID) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MPInteractionAux.calculateTextFieldWidth(
                      MPInteractionAux.insideRange(
                        value: max(
                          _thIDController.text.toString().length,
                          _warningMessage.length,
                        ),
                        min: mpDefaultMinDigitsForTextFields,
                        max: mpDefaultMaxCharsForTextFields,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: (_warningMessage.isEmpty) ? 0 : 16,
                      ),
                      child: TextField(
                        controller: _thIDController,
                        keyboardType: TextInputType.text,
                        autofocus: true,
                        focusNode: _idTextFieldFocusNode,
                        decoration: InputDecoration(
                          labelText: appLocalizations.mpIDIDLabel,
                          border: OutlineInputBorder(),
                          errorText: _warningMessage,
                        ),
                        onChanged: (value) {
                          _updateIsValid();
                        },
                      ),
                    ),
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
              onPressed: (_isValid && _isChanged()) ? _okButtonPressed : null,
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
