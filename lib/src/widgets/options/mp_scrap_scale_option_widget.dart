import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_text_field_input_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';

/// Kernel (re-usable) scrap scale option widget (no overlay window chrome).
class MPScrapScaleOptionWidget extends StatefulWidget {
  final MPOptionInfo optionInfo;
  final bool showActionButtons;
  final VoidCallback? onPressedOk;
  final VoidCallback? onPressedCancel;
  final ValueChanged<THScrapScaleCommandOption?>? onValidOptionChanged;

  const MPScrapScaleOptionWidget({
    super.key,
    required this.optionInfo,
    this.showActionButtons = false,
    this.onPressedOk,
    this.onPressedCancel,
    this.onValidOptionChanged,
  });

  @override
  State<MPScrapScaleOptionWidget> createState() =>
      MPScrapScaleOptionWidgetState();
}

class MPScrapScaleOptionWidgetState extends State<MPScrapScaleOptionWidget> {
  String _selectedChoice = '';
  final List<TextEditingController> _lengthControllers = [];
  final FocusNode _lengthFocusNode = FocusNode();
  final List<String> _initialLengths = [];
  late final String _initialUnit;
  late final String _initialSelectedChoice;
  final List<String?> _lengthWarningMessages = [];
  bool _isOkButtonEnabled = false;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  late final Map<String, String> _unitMap;
  late String _selectedUnit;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _unitMap = MPTextToUser.getOrderedChoicesMap(
      MPTextToUser.getLengthUnitsChoices(),
    );

    for (int i = 0; i < mpScrapScaleMaxValues; i++) {
      _lengthControllers.add(TextEditingController());
      _initialLengths.add('');
      _lengthWarningMessages.add(null);
    }

    final MPOptionStateType state = widget.optionInfo.state;

    if (state == MPOptionStateType.set) {
      final THScrapScaleCommandOption currentOption =
          widget.optionInfo.option as THScrapScaleCommandOption;

      int i = 0;

      for (final spec in currentOption.numericSpecifications) {
        _lengthControllers[i].text = spec.value.toString();
        i++;
      }

      final int len = currentOption.numericSpecifications.length;

      if (len == 1) {
        _selectedChoice = mpScrapScale1ValueID;
      } else if (len == 2) {
        _selectedChoice = mpScrapScale2ValuesID;
      } else if (len == 8) {
        _selectedChoice = mpScrapScale8ValuesID;
      } else {
        throw Exception(
          'Invalid length "$len" at MPScrapScaleOptionWidgetState.initState()',
        );
      }
      _selectedUnit = currentOption.unitPart.unit.name;
    } else if (state == MPOptionStateType.unset) {
      _selectedChoice = mpUnsetOptionID;
      _selectedUnit = thDefaultLengthUnitAsString;
    } else {
      _selectedChoice = '';
      _selectedUnit = thDefaultLengthUnitAsString;
    }

    for (int i = 0; i < mpScrapScaleMaxValues; i++) {
      _initialLengths[i] = _lengthControllers[i].text;
    }
    _initialUnit = _selectedUnit;
    _initialSelectedChoice = _selectedChoice;

    _updateIsValid();
  }

  @override
  void dispose() {
    for (int i = 0; i < mpScrapScaleMaxValues; i++) {
      _lengthControllers[i].dispose();
    }
    _lengthFocusNode.dispose();

    super.dispose();
  }

  int _getRefCount() {
    if (_selectedChoice == mpScrapScale1ValueID) {
      return 1;
    }
    if (_selectedChoice == mpScrapScale2ValuesID) {
      return 2;
    }
    if (_selectedChoice == mpScrapScale8ValuesID) {
      return 8;
    }

    return 0; // unset or ''
  }

  void _updateIsValid() {
    final int refsCount = _getRefCount();

    _isValid = (_selectedChoice == mpUnsetOptionID) || (_selectedChoice != '');

    for (int i = 0; i < refsCount; i++) {
      final double? value = double.tryParse(_lengthControllers[i].text);

      if (value == null) {
        _lengthWarningMessages[i] =
            appLocalizations.mpScrapScaleInvalidValueError;
        _isValid = false;
      } else {
        _lengthWarningMessages[i] = null;
      }
    }

    _updateOkButtonEnabled();

    if (_isValid) {
      widget.onValidOptionChanged?.call(buildCurrentOption());
    } else {
      widget.onValidOptionChanged?.call(null);
    }
  }

  void _updateOkButtonEnabled() {
    bool isRefsChanged = false;
    final int refCount = _getRefCount();

    for (int i = 0; i < refCount; i++) {
      if (_lengthControllers[i].text != _initialLengths[i]) {
        isRefsChanged = true;
        break;
      }
    }

    final bool isChanged =
        (_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice != mpUnsetOptionID) &&
            (isRefsChanged || (_selectedUnit != _initialUnit)));

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

    Widget buildLengthTextField({
      required String labelText,
      required TextEditingController controller,
      required String? errorText,
      bool autofocus = false,
      FocusNode? focusNode,
    }) {
      return MPTextFieldInputWidget(
        labelText: labelText,
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^[0-9.\-+]*$')),
        ],
        autofocus: autofocus,
        focusNode: focusNode,
        errorText: errorText,
        onChanged: (value) => _updateIsValid(),
      );
    }

    switch (option) {
      case mpScrapScale1ValueID:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(appLocalizations.mpScrapScale1ValueObservation),
            const SizedBox(height: mpButtonSpace),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildLengthTextField(
                  labelText: appLocalizations.mpScrapScale11Label,
                  controller: _lengthControllers[0],
                  errorText: _lengthWarningMessages[0],
                  autofocus: true,
                  focusNode: _lengthFocusNode,
                ),
                const SizedBox(width: mpButtonSpace),
                buildUnitDropdown(),
              ],
            ),
          ],
        );
      case mpScrapScale2ValuesID:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(appLocalizations.mpScrapScale2ValueObservation),
            const SizedBox(height: mpButtonSpace),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildLengthTextField(
                  labelText: appLocalizations.mpScrapScale21Label,
                  controller: _lengthControllers[0],
                  errorText: _lengthWarningMessages[0],
                  autofocus: true,
                  focusNode: _lengthFocusNode,
                ),
                const SizedBox(width: mpButtonSpace),
                buildLengthTextField(
                  labelText: appLocalizations.mpScrapScale22Label,
                  controller: _lengthControllers[1],
                  errorText: _lengthWarningMessages[1],
                ),
                const SizedBox(width: mpButtonSpace),
                buildUnitDropdown(),
              ],
            ),
          ],
        );

      case mpScrapScale8ValuesID:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(appLocalizations.mpScrapScale8ValueObservation),
            const SizedBox(height: mpButtonSpace),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildLengthTextField(
                  labelText: appLocalizations.mpScrapScale81Label,
                  controller: _lengthControllers[0],
                  errorText: _lengthWarningMessages[0],
                  autofocus: true,
                  focusNode: _lengthFocusNode,
                ),
                const SizedBox(width: mpButtonSpace),
                buildLengthTextField(
                  labelText: appLocalizations.mpScrapScale82Label,
                  controller: _lengthControllers[1],
                  errorText: _lengthWarningMessages[1],
                ),
                const SizedBox(width: mpButtonSpace),
                buildLengthTextField(
                  labelText: appLocalizations.mpScrapScale83Label,
                  controller: _lengthControllers[2],
                  errorText: _lengthWarningMessages[2],
                ),
                const SizedBox(width: mpButtonSpace),
                buildLengthTextField(
                  labelText: appLocalizations.mpScrapScale84Label,
                  controller: _lengthControllers[3],
                  errorText: _lengthWarningMessages[3],
                ),
              ],
            ),
            const SizedBox(height: mpButtonSpace),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildLengthTextField(
                  labelText: appLocalizations.mpScrapScale85Label,
                  controller: _lengthControllers[4],
                  errorText: _lengthWarningMessages[4],
                ),
                const SizedBox(width: mpButtonSpace),
                buildLengthTextField(
                  labelText: appLocalizations.mpScrapScale86Label,
                  controller: _lengthControllers[5],
                  errorText: _lengthWarningMessages[5],
                ),
                const SizedBox(width: mpButtonSpace),
                buildLengthTextField(
                  labelText: appLocalizations.mpScrapScale87Label,
                  controller: _lengthControllers[6],
                  errorText: _lengthWarningMessages[6],
                ),
                const SizedBox(width: mpButtonSpace),
                buildLengthTextField(
                  labelText: appLocalizations.mpScrapScale88Label,
                  controller: _lengthControllers[7],
                  errorText: _lengthWarningMessages[7],
                ),
                const SizedBox(width: mpButtonSpace),
                buildUnitDropdown(),
              ],
            ),
          ],
        );
      default:
        throw Exception(
          'Invalid choice "$option" at MPScrapScaleOptionWidget._buildFormForOption()',
        );
    }
  }

  THScrapScaleCommandOption? buildCurrentOption() {
    if (!_isValid) {
      return null;
    }
    if (_selectedChoice == mpUnsetOptionID) {
      return null;
    }

    final int refCounts = _getRefCount();
    final List<THDoublePart> numericSpecifications = [];

    for (int i = 0; i < refCounts; i++) {
      final double? value = double.tryParse(_lengthControllers[i].text);

      if (value == null) {
        return null;
      }
      numericSpecifications.add(
        THDoublePart.fromString(valueString: _lengthControllers[i].text),
      );
    }

    return THScrapScaleCommandOption.fromStringWithParentMPID(
      parentMPID: mpParentMPIDPlaceholder,
      numericSpecifications: numericSpecifications,
      unitPart: THLengthUnitPart.fromString(unitString: _selectedUnit),
    );
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
          "MPScrapScaleOptionWidget|RadioListTile|$mpUnsetOptionID",
        ),
        title: Text(appLocalizations.mpChoiceUnset),
        value: mpUnsetOptionID,
        contentPadding: EdgeInsets.zero,
      ),
    );

    final Map<String, String> choices = {
      mpScrapScale1ValueID: appLocalizations.mpScrapScale1ValueLabel,
      mpScrapScale2ValuesID: appLocalizations.mpScrapScale2ValuesLabel,
      mpScrapScale8ValuesID: appLocalizations.mpScrapScale8ValuesLabel,
    };

    for (final entry in choices.entries) {
      final String value = entry.key;
      final String label = entry.value;

      optionWidgets.add(
        RadioListTile<String>(
          key: ValueKey("MPScrapScaleOptionWidget|RadioListTile|$value"),
          title: Text(label),
          value: value,
          contentPadding: EdgeInsets.zero,
        ),
      );
      if (_selectedChoice == value) {
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
