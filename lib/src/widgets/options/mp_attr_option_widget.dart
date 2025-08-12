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
  late final TH2FileEditController th2FileEditController;
  late final Map<String, MPOptionInfo> attrOptions;
  final List<MPAttrEdit> _attrs = [];
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  final Map<String, String> _initials = {};
  final Map<String, String> _initialSelectedChoices = {};
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  bool _isValid = false;
  bool _isOkButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    th2FileEditController = widget.th2FileEditController;
    attrOptions = th2FileEditController.optionEditController.optionAttrStateMap;

    for (final entry in attrOptions.entries) {
      final String attrName = entry.key;
      final MPOptionInfo optionInfo = entry.value;
      final TextEditingController nameController = TextEditingController();
      final TextEditingController valueController = TextEditingController();
      final FocusNode nameFocusNode = FocusNode();
      final FocusNode valueFocusNode = FocusNode();

      switch (optionInfo.state) {
        case MPOptionStateType.set:
          final THAttrCommandOption currentOption =
              optionInfo.option! as THAttrCommandOption;

          nameController.text = currentOption.name.content;
          valueController.text = currentOption.value.content;
        case MPOptionStateType.setMixed:
        case MPOptionStateType.setUnsupported:
          nameController.text = '';
        case MPOptionStateType.unset:
      }

      _initials[attrName] = nameController.text;
      _attrs.add(MPAttrEdit(
        nameController: nameController,
        valueController: valueController,
      ));
      _updateIsValid(_attrs.length - 1);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasExecutedSingleRunOfPostFrameCallback) {
        _hasExecutedSingleRunOfPostFrameCallback = true;
        _executeOnceAfterBuild();
      }
    });
  }

  @override
  void dispose() {
    for (final attr in _attrs) {
      attr.nameController.dispose();
      attr.valueController.dispose();
      attr.nameFocusNode.dispose();
      attr.valueFocusNode.dispose();
    }
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_attrs.isNotEmpty) {
      _attrs.first.nameFocusNode.requestFocus();
    }
  }

  void _saveButtonPressed(int attrPosition) {
    if (attrPosition < 0 || attrPosition >= _attrs.length) {
      return;
    }

    THCommandOption? newOption;

    if (_selectedChoices[name] == mpNonMultipleChoiceSetID) {
      newOption = THAttrCommandOption.forCWJM(
        parentMPID: th2FileEditController.thFileMPID,
        originalLineInTH2File: '',
        name: THStringPart(content: _nameControllers[name]!.text.trim()),
        value: THStringPart(content: _valueControllers[name]!.text.trim()),
      );
    }

    th2FileEditController.userInteractionController.prepareSetOption(
      option: newOption,
      optionType: THCommandOptionType.attr,
    );
  }

  void _cancelButtonPressed() {
    th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.optionChoices,
      false,
    );
  }

  void _updateIsValid(int namePosition) {
    if (namePosition < 0 || namePosition >= names.length) {
      return;
    }

    final String name = names[namePosition];

    switch (_selectedChoices) {
      case mpUnsetOptionID:
        _isValid = true;
      case mpNonMultipleChoiceSetID:
        _isValid = true;
        _nameWarningMessages = _nameControllers.text.trim().isNotEmpty
            ? (RegExp(r'^[a-zA-Z0-9]+$').hasMatch(_nameControllers.text)
                ? ''
                : appLocalizations.mpAttrNameInvalid)
            : appLocalizations.mpAttrNameEmpty;
        _valueWarningMessages = _valueControllers.text.trim().isNotEmpty
            ? ''
            : appLocalizations.mpAttrValueEmpty;

        _isValid =
            _nameWarningMessages.isEmpty && _valueWarningMessages.isEmpty;
      default:
        _isValid = false;
    }

    _updateIsOkButtonEnabled();
  }

  void _updateIsOkButtonEnabled() {
    final bool isChanged = ((_selectedChoices != _initialSelectedChoices) ||
        ((_selectedChoices == mpNonMultipleChoiceSetID) &&
            (_nameControllers.text.trim() != _initials ||
                _valueControllers.text.trim() != _initialValue)));

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
      children: [
        const SizedBox(height: mpButtonSpace),
        MPOverlayWindowBlockWidget(
          overlayWindowBlockType: MPOverlayWindowBlockType.secondary,
          padding: mpOverlayWindowBlockEdgeInsets,
          children: [
            RadioListTile<String>(
              title: Text(appLocalizations.mpChoiceUnset),
              value: mpUnsetOptionID,
              groupValue: _selectedChoices,
              contentPadding: EdgeInsets.zero,
              onChanged: (String? value) {
                if (value != null) {
                  _selectedChoices = value;
                  _updateIsValid();
                }
              },
            ),
            RadioListTile<String>(
              title: Text(appLocalizations.mpChoiceSet),
              value: mpNonMultipleChoiceSetID,
              groupValue: _selectedChoices,
              contentPadding: EdgeInsets.zero,
              onChanged: (String? value) {
                if (value != null) {
                  _selectedChoices = value;
                  _updateIsValid();
                }
              },
            ),

            // Additional Inputs for "Set" Option
            if (_selectedChoices == mpNonMultipleChoiceSetID) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: mpButtonSpace),
                  Row(
                    children: [
                      Expanded(
                        child: MPTextFieldInputWidget(
                          controller: _nameControllers,
                          errorText: _nameWarningMessages,
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
                          controller: _valueControllers,
                          errorText: _valueWarningMessages,
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
              onPressed: _isOkButtonEnabled ? _saveButtonPressed : null,
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

class MPAttrEdit {
  final TextEditingController nameController;
  final TextEditingController valueController;
  final FocusNode nameFocusNode;
  final FocusNode valueFocusNode;
  String nameWarningMessage = '';
  String valueWarningMessage = '';
  bool isValid = false;

  MPAttrEdit({
    required this.nameController,
    required this.valueController,
    this.nameWarningMessage = '',
    this.valueWarningMessage = '',
  })  : nameFocusNode = FocusNode(),
        valueFocusNode = FocusNode();
}
