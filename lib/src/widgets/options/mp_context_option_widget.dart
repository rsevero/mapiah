import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/inputs/mp_pla_type_input_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPContextOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPContextOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPContextOptionWidget> createState() => _MPContextOptionWidgetState();
}

class _MPContextOptionWidgetState extends State<MPContextOptionWidget> {
  late String _elementType;
  late String _plaType;
  late String _selectedChoice;
  late final String _initialElementType;
  late final String _initialPLAType;
  late final String _initialSelectedChoice;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  bool _isElementTypeValid = false;
  bool _isPLATypeValid = false;
  bool _isOkButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THContextCommandOption currentOption =
            widget.optionInfo.option! as THContextCommandOption;

        _elementType = currentOption.elementType;
        _plaType = currentOption.symbolType;
        _selectedChoice = mpNonMultipleChoiceSetID;
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _elementType = '';
        _plaType = '';
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _elementType = '';
        _plaType = '';
        _selectedChoice = mpUnsetOptionID;
    }

    _initialElementType = _elementType;
    _initialPLAType = _plaType;
    _initialSelectedChoice = _selectedChoice;
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      if (_elementType.isNotEmpty && _plaType.isNotEmpty) {
        newOption = THContextCommandOption.fromStringWithParentMPID(
          parentMPID: mpParentMPIDPlaceholder,
          elementType: _elementType,
          symbolType: _plaType,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.mpContextInvalidValueErrorMessage),
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

  void _onElementTypeChanged(String value, bool isValid) {
    if ((value != _elementType) || (_isElementTypeValid != isValid)) {
      {
        setState(() {
          _elementType = value;
          _isElementTypeValid = isValid;
          _plaType = '';
          _isPLATypeValid = false;
          _updateIsOkButtonEnabled();
        });
      }
    }
  }

  void _onPLATypeChanged(String value, bool isValid) {
    if ((value != _plaType) || (_isPLATypeValid != isValid)) {
      {
        setState(() {
          _plaType = value;
          _isPLATypeValid = isValid;
          _updateIsOkButtonEnabled();
        });
      }
    }
  }

  void _updateIsOkButtonEnabled() {
    final bool isChanged =
        ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            ((_elementType != _initialElementType) ||
                (_plaType != _initialPLAType))));

    _isOkButtonEnabled = _isElementTypeValid && _isPLATypeValid && isChanged;
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionContext,
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
                });
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    key: ValueKey(
                      "MPContextOptionWidget|RadioListTile|$mpUnsetOptionID",
                    ),
                    title: Text(appLocalizations.mpChoiceUnset),
                    value: mpUnsetOptionID,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    key: ValueKey(
                      "MPContextOptionWidget|RadioListTile|$mpNonMultipleChoiceSetID",
                    ),
                    title: Text(appLocalizations.mpChoiceSet),
                    value: mpNonMultipleChoiceSetID,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Additional Inputs for "Set" Option
            if (_selectedChoice == mpNonMultipleChoiceSetID) ...[
              MPPLATypeRadioButtonWidget(
                initialValue: _elementType,
                onChanged: _onElementTypeChanged,
                onChangedPLAType: _onPLATypeChanged,
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
