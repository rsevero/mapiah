import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
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

class MPPassageHeightOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPPassageHeightOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPPassageHeightOptionWidget> createState() =>
      _MPPassageHeightOptionWidgetState();
}

class _MPPassageHeightOptionWidgetState
    extends State<MPPassageHeightOptionWidget> {
  String _selectedChoice = '';
  late final TextEditingController _depthController = TextEditingController();
  late final TextEditingController _heightController = TextEditingController();
  final FocusNode _depthFocusNode = FocusNode();
  final FocusNode _heightFocusNode = FocusNode();
  late final String _initialDepth;
  late final String _initialHeight;
  late final String _initialUnit;
  late final String _initialSelectedChoice;
  String? _depthWarningMessage;
  String? _heigthWarningMessage;
  bool _isOkButtonEnabled = false;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  late final Map<String, String> _unitMap;
  String _selectedUnit = thDefaultLengthUnitAsString;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _unitMap =
        MPTextToUser.getOrderedChoices(MPTextToUser.getLengthUnitsChoices());

    if (widget.optionInfo.state == MPOptionStateType.set) {
      final THPassageHeightValueCommandOption currentOption =
          widget.optionInfo.option as THPassageHeightValueCommandOption;

      switch (currentOption.mode) {
        case THPassageHeightModes.height:
        case THPassageHeightModes.distanceBetweenFloorAndCeiling:
          _heightController.text = currentOption.plusNumber.toString();
        case THPassageHeightModes.depth:
          _depthController.text = currentOption.minusNumber.toString();
        case THPassageHeightModes.distanceToCeilingAndDistanceToFloor:
          _heightController.text = currentOption.plusNumber.toString();
          _depthController.text = currentOption.minusNumber.toString();
      }
      _selectedChoice = currentOption.mode.name;
      _selectedUnit = currentOption.unit.unit.name;
    } else {
      _selectedChoice = '';
    }

    _initialHeight = _heightController.text;
    _initialDepth = _depthController.text;
    _initialUnit = _selectedUnit;
    _initialSelectedChoice = _selectedChoice;

    _updateIsValid();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _depthController.dispose();
    _heightFocusNode.dispose();
    _depthFocusNode.dispose();
    super.dispose();
  }

  void _updateIsValid() {
    switch (_selectedChoice) {
      case mpUnsetOptionID:
        _isValid = true;
      case '':
      case mpNonMultipleChoiceSetID:
        _isValid = false;
      case 'height':
        final double? height = double.tryParse(_heightController.text);

        _isValid = (height != null) && (_selectedUnit.isNotEmpty);
        _heigthWarningMessage =
            _isValid ? null : appLocalizations.mpPassageHeightHeightWarning;
      case 'depth':
        final double? depth = double.tryParse(_depthController.text);

        _isValid = (depth != null) && (_selectedUnit.isNotEmpty);
        _depthWarningMessage =
            _isValid ? null : appLocalizations.mpPassageHeightDepthWarning;
      case 'distanceBetweenFloorAndCeiling':
        final double? height = double.tryParse(_heightController.text);

        _isValid = (height != null) && (_selectedUnit.isNotEmpty);
        _heigthWarningMessage =
            _isValid ? null : appLocalizations.mpPassageHeightHeightWarning;
      case 'distanceToCeilingAndDistanceToFloor':
        final double? height = double.tryParse(_heightController.text);
        final double? depth = double.tryParse(_depthController.text);

        _isValid =
            (height != null) && (depth != null) && (_selectedUnit.isNotEmpty);
        _heigthWarningMessage = height != null
            ? null
            : appLocalizations.mpPassageHeightHeightWarning;
        _depthWarningMessage =
            depth != null ? null : appLocalizations.mpPassageHeightDepthWarning;
      default:
        throw Exception(
            'Invalid choice "$_selectedChoice" at MPPassageHeightOptionWidget._updateIsValid()');
    }

    _updateOkButtonEnabled();
  }

  void _updateOkButtonEnabled() {
    final bool isChanged = (_selectedChoice != _initialSelectedChoice) ||
        (((_selectedChoice == 'height') ||
                (_selectedChoice == 'distanceBetweenFloorAndCeiling')) &&
            ((_selectedUnit != _initialUnit) ||
                (_heightController.text != _initialHeight))) ||
        ((_selectedChoice == 'depth') &&
            ((_depthController.text != _initialDepth) ||
                (_selectedUnit != _initialUnit))) ||
        ((_selectedChoice == 'distanceToCeilingAndDistanceToFloor') &&
            ((_heightController.text != _initialHeight) ||
                (_depthController.text != _initialDepth) ||
                (_selectedUnit != _initialUnit)));

    setState(() {
      _isOkButtonEnabled = _isValid && isChanged;
    });
  }

  Widget _buildFormForOption(String option) {
    Widget buildUnitDropdown() {
      return DropdownMenu<String>(
        initialSelection: _selectedUnit,
        dropdownMenuEntries: _unitMap.entries
            .map((unit) => DropdownMenuEntry<String>(
                  value: unit.key,
                  label: unit.value,
                ))
            .toList(),
        onSelected: (newUnit) {
          if (newUnit != null) {
            _selectedUnit = newUnit;
            _updateIsValid();
          }
        },
      );
    }

    switch (option) {
      case 'height':
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MPTextFieldInputWidget(
              labelText: appLocalizations.mpPassageHeightHeightLabel,
              textEditingController: _heightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              focusNode: _heightFocusNode,
              errorText: _heigthWarningMessage,
              onChanged: (value) => _updateIsValid(),
            ),
            const SizedBox(width: mpButtonSpace),
            buildUnitDropdown(),
          ],
        );
      case 'depth':
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MPTextFieldInputWidget(
              labelText: appLocalizations.mpPassageHeightDepthLabel,
              textEditingController: _depthController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              focusNode: _depthFocusNode,
              errorText: _depthWarningMessage,
              onChanged: (value) => _updateIsValid(),
            ),
            const SizedBox(width: mpButtonSpace),
            buildUnitDropdown(),
          ],
        );
      case 'distanceBetweenFloorAndCeiling':
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MPTextFieldInputWidget(
              labelText: appLocalizations
                  .mpPassageHeightDistanceBetweenFloorAndCeilingLabel,
              textEditingController: _heightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              errorText: _heigthWarningMessage,
              focusNode: _heightFocusNode,
              onChanged: (value) => _updateIsValid(),
            ),
            const SizedBox(width: mpButtonSpace),
            buildUnitDropdown(),
          ],
        );
      case 'distanceToCeilingAndDistanceToFloor':
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MPTextFieldInputWidget(
              labelText: appLocalizations.mpPassageHeightCeilingLabel,
              textEditingController: _heightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              errorText: _heigthWarningMessage,
              focusNode: _heightFocusNode,
              onChanged: (value) => _updateIsValid(),
            ),
            const SizedBox(width: mpButtonSpace),
            MPTextFieldInputWidget(
              labelText: appLocalizations.mpPassageHeightFloorLabel,
              textEditingController: _depthController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              errorText: _depthWarningMessage,
              focusNode: _depthFocusNode,
              onChanged: (value) => _updateIsValid(),
            ),
            const SizedBox(width: mpButtonSpace),
            buildUnitDropdown(),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    switch (_selectedChoice) {
      case 'height':
        newOption = THPassageHeightValueCommandOption.withParentMPID(
          parentMPID: widget.th2FileEditController.thFileMPID,
          plusNumber: _heightController.text,
          mode: THPassageHeightModes.height,
          unit: _selectedUnit,
        );
      case 'depth':
        newOption = THPassageHeightValueCommandOption.withParentMPID(
          parentMPID: widget.th2FileEditController.thFileMPID,
          minusNumber: _depthController.text,
          mode: THPassageHeightModes.depth,
          unit: _selectedUnit,
        );
      case 'distanceBetweenFloorAndCeiling':
        newOption = THPassageHeightValueCommandOption.withParentMPID(
          parentMPID: widget.th2FileEditController.thFileMPID,
          plusNumber: _heightController.text,
          mode: THPassageHeightModes.distanceBetweenFloorAndCeiling,
          unit: _selectedUnit,
        );
      case 'distanceToCeilingAndDistanceToFloor':
        newOption = THPassageHeightValueCommandOption.withParentMPID(
          parentMPID: widget.th2FileEditController.thFileMPID,
          plusNumber: _heightController.text,
          minusNumber: _depthController.text,
          mode: THPassageHeightModes.distanceToCeilingAndDistanceToFloor,
          unit: _selectedUnit,
        );
      default:
        throw Exception(
            'Invalid choice "$_selectedChoice" at MPPassageHeightOptionWidget._okButtonPressed()');
    }

    widget.th2FileEditController.userInteractionController.prepareSetOption(
      option: newOption,
      optionType: widget.optionInfo.type,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSet =
        (_selectedChoice.isNotEmpty && (_selectedChoice != mpUnsetOptionID));
    final List<Widget> optionWidgets = [];

    if (isSet) {
      final choices = MPTextToUser.getPassageHeightModesChoices();

      for (final entry in choices.entries) {
        final String value = entry.key;
        final String label = entry.value;

        optionWidgets.add(
          RadioListTile<String>(
            title: Text(label),
            value: value,
            groupValue: _selectedChoice,
            onChanged: (value) {
              _selectedChoice = value!;
              _updateIsValid();
            },
          ),
        );
        if (_selectedChoice == value) {
          optionWidgets.add(_buildFormForOption(_selectedChoice));
        }
      }
    }

    return MPOverlayWindowWidget(
      title: appLocalizations.thPointPassageHeight,
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
              onChanged: (value) {
                _selectedChoice = mpUnsetOptionID;
                _updateIsValid();
              },
            ),
            RadioListTile<String>(
              title: Text(appLocalizations.mpChoiceSet),
              value: mpNonMultipleChoiceSetID,
              groupValue: isSet ? mpNonMultipleChoiceSetID : _selectedChoice,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                _selectedChoice = mpNonMultipleChoiceSetID;
                _updateIsValid();
              },
            ),
            if (isSet)
              MPOverlayWindowBlockWidget(
                overlayWindowBlockType: MPOverlayWindowBlockType.secondarySet,
                padding: mpOverlayWindowBlockEdgeInsets,
                children: optionWidgets,
              ),
          ],
        ),
        const SizedBox(height: mpButtonSpace),
        Row(
          children: [
            ElevatedButton(
              onPressed: _isOkButtonEnabled ? _okButtonPressed : null,
              child: Text(appLocalizations.mpButtonOK),
            ),
            const SizedBox(width: mpButtonSpace),
            ElevatedButton(
              onPressed: () {
                widget.th2FileEditController.overlayWindowController
                    .setShowOverlayWindow(MPWindowType.optionChoices, false);
              },
              child: Text(appLocalizations.mpButtonCancel),
            ),
          ],
        ),
      ],
    );
  }
}
