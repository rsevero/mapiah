import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_string_part.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_text_field_input_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPAttrOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPAttrOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPAttrOptionWidget> createState() => _MPAttrOptionWidgetState();
}

class _MPAttrOptionWidgetState extends State<MPAttrOptionWidget> {
  late String _selectedChoice;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  late final String _initialName;
  late final String _initialValue;
  late final String _initialSelectedChoice;
  String _nameWarningMessage = '';
  String _valueWarningMessage = '';
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  bool _isValid = false;
  bool _isOkButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THAttrCommandOption currentOption =
            widget.optionInfo.option! as THAttrCommandOption;

        _nameController.text = currentOption.name.content;
        _valueController.text = currentOption.value.content;
        _selectedChoice = mpNonMultipleChoiceSetID;
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _selectedChoice = mpUnsetOptionID;
    }

    _initialName = _nameController.text;
    _initialValue = _valueController.text;
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
    _nameController.dispose();
    _valueController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _nameFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      newOption = THAttrCommandOption.forCWJM(
        parentMPID: widget.th2FileEditController.thFileMPID,
        originalLineInTH2File: '',
        name: THStringPart(content: _nameController.text.trim()),
        value: THStringPart(content: _valueController.text.trim()),
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
        _isValid = true;
        _nameWarningMessage = _nameController.text.trim().isNotEmpty
            ? (RegExp(r'^[a-zA-Z0-9]+$').hasMatch(_nameController.text)
                ? ''
                : appLocalizations.mpAttrNameInvalid)
            : appLocalizations.mpAttrNameEmpty;
        _valueWarningMessage = _valueController.text.trim().isNotEmpty
            ? ''
            : appLocalizations.mpAttrValueEmpty;

        _isValid = _nameWarningMessage.isEmpty && _valueWarningMessage.isEmpty;
      default:
        _isValid = false;
    }

    _updateIsOkButtonEnabled();
  }

  void _updateIsOkButtonEnabled() {
    final bool isChanged = ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            (_nameController.text.trim() != _initialName ||
                _valueController.text.trim() != _initialValue)));

    setState(
      () {
        _isOkButtonEnabled = _isValid && isChanged;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionAttr,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: mpButtonSpace),
                  Row(
                    children: [
                      Expanded(
                        child: MPTextFieldInputWidget(
                          controller: _nameController,
                          errorText: _nameWarningMessage,
                          labelText: appLocalizations.mpAttrNameLabel,
                          onChanged: (value) {
                            _updateIsValid();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: mpButtonSpace),
                  Row(
                    children: [
                      Expanded(
                        child: MPTextFieldInputWidget(
                          controller: _valueController,
                          errorText: _valueWarningMessage,
                          labelText: appLocalizations.mpAttrValueLabel,
                          onChanged: (value) {
                            _updateIsValid();
                          },
                        ),
                      ),
                    ],
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
