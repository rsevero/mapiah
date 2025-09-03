import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_text_field_input_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';

/// Kernel (re-usable) projection option widget. No overlay specific UI.
class MPProjectionOptionWidget extends StatefulWidget {
  final MPOptionInfo optionInfo;
  final bool showActionButtons;
  final VoidCallback? onPressedOk;
  final VoidCallback? onPressedCancel;
  final ValueChanged<THProjectionCommandOption?>? onValidOptionChanged;

  const MPProjectionOptionWidget({
    super.key,
    required this.optionInfo,
    this.showActionButtons = false,
    this.onPressedOk,
    this.onPressedCancel,
    this.onValidOptionChanged,
  });

  @override
  State<MPProjectionOptionWidget> createState() =>
      MPProjectionOptionWidgetState();
}

class MPProjectionOptionWidgetState extends State<MPProjectionOptionWidget> {
  String _selectedChoice = '';
  final TextEditingController _indexController = TextEditingController();
  final TextEditingController _angleController = TextEditingController();
  final FocusNode _indexFocusNode = FocusNode();
  late final String _initialIndex;
  late final String _initialAngle;
  late final String _initialUnit;
  late final String _initialSelectedChoice;
  String? _angleWarningMessage;
  bool _isOkButtonEnabled = false;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  late final Map<String, String> _unitMap;
  late String _selectedUnit;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _unitMap = MPTextToUser.getOrderedChoicesMap(
      MPTextToUser.getAngleUnitTypeChoices(),
    );

    final state = widget.optionInfo.state;
    if (state == MPOptionStateType.set) {
      final THProjectionCommandOption currentOption =
          widget.optionInfo.option as THProjectionCommandOption;
      _indexController.text = currentOption.index;
      _selectedChoice = currentOption.mode.name;
      _angleController.text = currentOption.elevationAngle?.toString() ?? '';
      _selectedUnit = currentOption.elevationUnit == null
          ? thDefaultAngleUnitAsString
          : currentOption.elevationUnit!.unit.name;
    } else if (state == MPOptionStateType.unset) {
      _selectedChoice = mpUnsetOptionID;
      _selectedUnit = thDefaultAngleUnitAsString;
    } else {
      // mixed / unsupported
      _selectedChoice = '';
      _selectedUnit = thDefaultAngleUnitAsString;
    }

    _initialIndex = _indexController.text;
    _initialAngle = _angleController.text;
    _initialUnit = _selectedUnit;
    _initialSelectedChoice = _selectedChoice;

    _updateIsValid();
  }

  @override
  void dispose() {
    _indexController.dispose();
    _indexFocusNode.dispose();
    _angleController.dispose();
    super.dispose();
  }

  void _updateIsValid() {
    if (_selectedChoice == mpUnsetOptionID ||
        _selectedChoice == 'extended' ||
        _selectedChoice == 'none' ||
        _selectedChoice == 'plan') {
      _isValid = true;
      _angleWarningMessage = null;
    } else if (_selectedChoice == '') {
      _isValid = false;
      _angleWarningMessage = null;
    } else if (_selectedChoice == 'elevation') {
      final double? angle = double.tryParse(_angleController.text);
      _isValid =
          _angleController.text.isEmpty ||
          (angle != null &&
              _selectedUnit.isNotEmpty &&
              angle >= 0 &&
              angle < 360);
      _angleWarningMessage = _isValid
          ? null
          : appLocalizations.mpProjectionAngleWarning;
    } else {
      throw Exception(
        'Invalid choice "$_selectedChoice" at MPProjectionOptionWidgetState._updateIsValid()',
      );
    }
    _updateOkButtonEnabled();

    if (_isValid) {
      widget.onValidOptionChanged?.call(buildCurrentOption());
    } else {
      widget.onValidOptionChanged?.call(null);
    }
  }

  void _updateOkButtonEnabled() {
    final bool isChanged =
        (_selectedChoice != _initialSelectedChoice) ||
        (((_selectedChoice == 'extended') || (_selectedChoice == 'plan')) &&
            (_indexController.text != _initialIndex)) ||
        ((_selectedChoice == 'elevation') &&
            ((_angleController.text != _initialAngle) ||
                (_selectedUnit != _initialUnit) ||
                (_indexController.text != _initialIndex)));

    setState(() {
      _isOkButtonEnabled = _isValid && isChanged;
    });
  }

  Widget _buildFormForOption(String option) {
    Widget buildUnitDropdown() {
      return DropdownMenu<String>(
        initialSelection: _selectedUnit,
        dropdownMenuEntries: _unitMap.entries
            .map(
              (unit) =>
                  DropdownMenuEntry<String>(value: unit.key, label: unit.value),
            )
            .toList(),
        onSelected: (newUnit) {
          if (newUnit != null) {
            _selectedUnit = newUnit;
            _updateIsValid();
          }
        },
      );
    }

    late final String labelText;

    if (option == 'elevation' || option == 'extended' || option == 'plan') {
      labelText = appLocalizations.mpProjectionIndexLabel;
    } else if (option == 'none') {
      return const SizedBox.shrink();
    } else {
      throw Exception(
        'Invalid choice "$option" at MPProjectionOptionWidgetState._buildFormForOption()',
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MPTextFieldInputWidget(
          labelText: labelText,
          controller: _indexController,
          autofocus: true,
          focusNode: _indexFocusNode,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^[A-Za-z0-9_/][A-Za-z0-9_/-]*$'),
            ),
          ],
          onChanged: (value) => _updateIsValid(),
        ),
        if (option == 'elevation') ...[
          const SizedBox(width: mpButtonSpace),
          MPTextFieldInputWidget(
            controller: _angleController,
            labelText: appLocalizations.mpProjectionElevationAzimuthLabel,
            errorText: _angleWarningMessage,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _updateIsValid();
            },
          ),
          const SizedBox(width: mpButtonSpace),
          buildUnitDropdown(),
        ],
      ],
    );
  }

  THProjectionCommandOption? buildCurrentOption() {
    if (!_isValid) return null;
    if (_selectedChoice == mpUnsetOptionID) return null;
    if (_selectedChoice == 'elevation') {
      return THProjectionCommandOption.fromStringWithParentMPID(
        parentMPID: mpParentMPIDPlaceholder,
        index: _indexController.text.trim(),
        mode: THProjectionModeType.values.byName(_selectedChoice),
        elevationAngle: _angleController.text,
        elevationUnit: _selectedUnit,
      );
    } else if (_selectedChoice == 'extended' || _selectedChoice == 'plan') {
      return THProjectionCommandOption.fromStringWithParentMPID(
        parentMPID: mpParentMPIDPlaceholder,
        index: _indexController.text.trim(),
        mode: THProjectionModeType.values.byName(_selectedChoice),
      );
    } else if (_selectedChoice == 'none') {
      return THProjectionCommandOption.fromStringWithParentMPID(
        parentMPID: mpParentMPIDPlaceholder,
        mode: THProjectionModeType.values.byName(_selectedChoice),
      );
    }
    return null;
  }

  void _internalOkPressed() {
    if (!_isValid) return;
    widget.onPressedOk?.call();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> optionWidgets = [];

    optionWidgets.add(
      RadioListTile<String>(
        key: ValueKey(
          "MPProjectionOptionWidget|RadioListTile|$mpUnsetOptionID",
        ),
        title: Text(appLocalizations.mpChoiceUnset),
        value: mpUnsetOptionID,
        contentPadding: EdgeInsets.zero,
      ),
    );

    final Map<String, String> choices =
        MPTextToUser.getProjectionModeTypeChoices();

    for (final entry in choices.entries) {
      optionWidgets.add(
        RadioListTile<String>(
          key: ValueKey("MPProjectionOptionWidget|RadioListTile|${entry.key}"),
          title: Text(entry.value),
          value: entry.key,
          contentPadding: EdgeInsets.zero,
        ),
      );
      if (_selectedChoice == entry.key) {
        optionWidgets.add(_buildFormForOption(_selectedChoice));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioGroup(
          groupValue: _selectedChoice,
          onChanged: (value) {
            _selectedChoice = value ?? '';
            _updateIsValid();
          },
          child: Column(children: optionWidgets),
        ),
        if (widget.showActionButtons) ...[
          const SizedBox(height: mpButtonSpace),
          Row(
            children: [
              ElevatedButton(
                onPressed: _isOkButtonEnabled ? _internalOkPressed : null,
                child: Text(appLocalizations.mpButtonOK),
              ),
              const SizedBox(width: mpButtonSpace),
              ElevatedButton(
                onPressed: widget.onPressedCancel,
                child: Text(appLocalizations.mpButtonCancel),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
