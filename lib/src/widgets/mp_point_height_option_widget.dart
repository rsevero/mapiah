import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class MPPointHeightOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPPointHeightOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPPointHeightOptionWidget> createState() =>
      _MPPointHeightOptionWidgetState();
}

class _MPPointHeightOptionWidgetState extends State<MPPointHeightOptionWidget> {
  String _selectedChoice = '';
  late final TextEditingController _lengthController = TextEditingController();
  final FocusNode _lengthFocusNode = FocusNode();
  late final bool _initalIsPresumed;
  late final String _initialLength;
  late final String _initialUnit;
  late final String _initialSelectedChoice;
  String? _lengthWarningMessage;
  bool _isOkButtonEnabled = false;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  late final Map<String, String> _unitMap;
  late String _selectedUnit;
  late bool _isPresumed;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _unitMap =
        MPTextToUser.getOrderedChoices(MPTextToUser.getLengthUnitsChoices());

    if (widget.optionInfo.state == MPOptionStateType.set) {
      final THPointHeightValueCommandOption currentOption =
          widget.optionInfo.option as THPointHeightValueCommandOption;

      _lengthController.text = currentOption.length.toString();
      _isPresumed = currentOption.isPresumed;
      _selectedChoice = currentOption.mode.name;
      _selectedUnit = currentOption.unit.unit.name;
    } else {
      _selectedChoice = '';
      _isPresumed = false;
      _selectedUnit = thDefaultLengthUnitAsString;
      _lengthController.text = '';
    }

    _initialLength = _lengthController.text;
    _initialUnit = _selectedUnit;
    _initalIsPresumed = _isPresumed;
    _initialSelectedChoice = _selectedChoice;

    _updateIsValid();
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _lengthFocusNode.dispose();
    super.dispose();
  }

  void _updateIsValid() {
    switch (_selectedChoice) {
      case mpUnsetOptionID:
        _isValid = true;
      case '':
      case mpNonMultipleChoiceSetID:
        _isValid = false;
      case 'chimney':
      case 'pit':
      case 'step':
        final double? length = double.tryParse(_lengthController.text);

        _isValid = (length != null) && (_selectedUnit.isNotEmpty);
        _lengthWarningMessage =
            _isValid ? null : appLocalizations.mpPointHeightLengthWarning;
      default:
        throw Exception(
            'Invalid choice "$_selectedChoice" at MPPointHeightOptionWidget._updateIsValid()');
    }

    _updateOkButtonEnabled();
  }

  void _updateOkButtonEnabled() {
    final bool isChanged = (_selectedChoice != _initialSelectedChoice) ||
        (((_selectedChoice == 'chimney') ||
                (_selectedChoice == 'pit') ||
                (_selectedChoice == 'step')) &&
            ((_selectedUnit != _initialUnit) ||
                (_lengthController.text != _initialLength) ||
                (_isPresumed != _initalIsPresumed)));

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

    late final String observation;
    late final String labelText;

    switch (option) {
      case 'chimney':
        observation = appLocalizations.mpPointHeightValueChimneyObservation;
        labelText = appLocalizations.mpPointHeightValueChimneyLabel;
      case 'pit':
        observation = appLocalizations.mpPointHeightValuePitObservation;
        labelText = appLocalizations.mpPointHeightValuePitLabel;
      case 'step':
        observation = appLocalizations.mpPointHeightValueStepObservation;
        labelText = appLocalizations.mpPointHeightValueStepLabel;
      default:
        throw Exception(
            'Invalid choice "$option" at MPPointHeightOptionWidget._buildFormForOption()');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(observation),
        const SizedBox(height: mpButtonSpace),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MPTextFieldInputWidget(
              labelText: labelText,
              textEditingController: _lengthController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9.]*$')),
              ],
              autofocus: true,
              focusNode: _lengthFocusNode,
              errorText: _lengthWarningMessage,
              onChanged: (value) => _updateIsValid(),
            ),
            const SizedBox(width: mpButtonSpace),
            buildUnitDropdown(),
          ],
        ),
      ],
    );
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    switch (_selectedChoice) {
      case 'chimney':
      case 'pit':
      case 'step':
        newOption = THPointHeightValueCommandOption.fromStringWithParentMPID(
          parentMPID: widget.th2FileEditController.thFileMPID,
          isPresumed: _isPresumed,
          length: _lengthController.text,
          mode: THPointHeightValueMode.values.byName(_selectedChoice),
          unit: _selectedUnit,
        );
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
      final choices = MPTextToUser.getPointHeightValueModeChoices();

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
      title: appLocalizations.thPointHeight,
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
