import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_text_field_input_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPSubtypeOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPSubtypeOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPSubtypeOptionWidget> createState() => _MPSubtypeOptionWidgetState();
}

class _MPSubtypeOptionWidgetState extends State<MPSubtypeOptionWidget> {
  late String _selectedChoice;
  late TextEditingController _subtypeController;
  final FocusNode _subtypeFieldFocusNode = FocusNode();
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  late final String _initialSubtype;
  late final String _initialSelectedChoice;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  String? _subtypeWarningMessage;
  bool _isValid = false;
  bool _isOkButtonEnabled = false;
  String? _defaultSubtype;

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THSubtypeCommandOption currentOption =
            widget.optionInfo.option! as THSubtypeCommandOption;

        _subtypeController = TextEditingController(
          text: currentOption.subtype.trim(),
        );
        _selectedChoice = mpNonMultipleChoiceSetID;
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _subtypeController = TextEditingController(text: '');
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _subtypeController = TextEditingController(text: '');
        _selectedChoice = mpUnsetOptionID;
    }

    _initialSubtype = _subtypeController.text;
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
    _subtypeController.dispose();
    _subtypeFieldFocusNode.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _subtypeFieldFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      /// The THFileMPID is used only as a placeholder for the actual
      /// parentMPID of the option(s) to be set. THFile isn't even a
      /// THHasOptionsMixin so it can't actually be the parent of an option,
      /// i.e., is has no options at all.
      newOption = THSubtypeCommandOption.forCWJM(
        parentMPID: widget.th2FileEditController.thFileMPID,
        originalLineInTH2File: '',
        subtype: _subtypeController.text.trim(),
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
        _isValid = _subtypeController.text.trim().isNotEmpty;
        _subtypeWarningMessage = _isValid
            ? null
            : appLocalizations.mpSubtypeEmpty;

      default:
        _isValid = false;
    }
    _updateIsOkButtonEnabled();
  }

  void _updateIsOkButtonEnabled() {
    final bool isChanged =
        ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            (_subtypeController.text != _initialSubtype)));

    setState(() {
      _isOkButtonEnabled = _isValid && isChanged;
    });
  }

  Widget _buildTextFieldInput() {
    return MPTextFieldInputWidget(
      controller: _subtypeController,
      errorText: _subtypeWarningMessage,
      labelText: appLocalizations.mpSubtypeLabel,
      autofocus: true,
      focusNode: _subtypeFieldFocusNode,
      onChanged: (value) {
        _updateIsValid();
      },
    );
  }

  Widget _buildOptionInput() {
    final mpSelectedElements = widget
        .th2FileEditController
        .selectionController
        .mpSelectedElementsLogical;

    if (mpSelectedElements.length == 1) {
      final THElement selectedElement =
          mpSelectedElements.values.first.originalElementClone;
      late String elementTypeAsString;
      late String plaTypeTypeAsString;

      switch (selectedElement) {
        case THPoint _:
          elementTypeAsString = 'point';
          plaTypeTypeAsString = selectedElement.plaType;
        case THLine _:
          elementTypeAsString = 'line';
          plaTypeTypeAsString = selectedElement.plaType;
        case THArea _:
          elementTypeAsString = 'area';
          plaTypeTypeAsString = selectedElement.plaType;
        default:
          throw Exception(
            'Unsupported element type: ${selectedElement.runtimeType} at MPSubtypeOptionWidget._buildOptionInput()',
          );
      }

      if (plaTypeTypeAsString == 'u') {
        return _buildTextFieldInput();
      } else {
        final Map<String, Object> allowedSubtypesInfo = MPCommandOptionAux
            .allowedSubtypes[elementTypeAsString]![plaTypeTypeAsString]!;
        final Set<String> allowedSubtypes =
            allowedSubtypesInfo['subtypes'] as Set<String>;
        final Map<String, String> options = {};

        _defaultSubtype = allowedSubtypesInfo['default'] as String;

        for (final subtype in allowedSubtypes) {
          options[subtype] = MPTextToUser.getSubtypeAsString(
            '$elementTypeAsString|$plaTypeTypeAsString|${subtype}',
          );
        }

        List<String> orderedOptions = options.keys.toList();
        orderedOptions.sort((a, b) {
          return MPTextToUser.compareStringsUsingLocale(
            MPTextToUser.getSubtypeAsString(a),
            MPTextToUser.getSubtypeAsString(b),
          );
        });

        return DropdownMenu<String>(
          initialSelection: _subtypeController.text,
          dropdownMenuEntries: orderedOptions.map((value) {
            final String label = options[value] ?? value;

            return DropdownMenuEntry<String>(
              value: value,
              label: label,
              labelWidget: value == _defaultSubtype
                  ? Row(
                      children: [
                        Text(label),
                        const Text(
                          ' *',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(label),
            );
          }).toList(),
          onSelected: (String? value) {
            if (value != null) {
              setState(() {
                _subtypeController.text = value;
                _updateIsValid();
              });
            }
          },
        );
      }
    } else {
      return _buildTextFieldInput();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionSubtype,
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
            RadioGroup<String>(
              groupValue: _selectedChoice,
              onChanged: (String? value) {
                setState(() {
                  _selectedChoice = value!;
                  _updateIsValid();
                });
                if (_selectedChoice == mpNonMultipleChoiceSetID) {
                  _subtypeFieldFocusNode.requestFocus();
                }
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(appLocalizations.mpChoiceUnset),
                    value: mpUnsetOptionID,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: Text(appLocalizations.mpChoiceSet),
                    value: mpNonMultipleChoiceSetID,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Additional Inputs for "Set" Option
            if (_selectedChoice == mpNonMultipleChoiceSetID) ...[
              _buildOptionInput(),
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
