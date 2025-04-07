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

class MPProjectionOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPProjectionOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPProjectionOptionWidget> createState() =>
      _MPProjectionOptionWidgetState();
}

class _MPProjectionOptionWidgetState extends State<MPProjectionOptionWidget> {
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
    _unitMap =
        MPTextToUser.getOrderedChoices(MPTextToUser.getAngleUnitTypeChoices());

    if (widget.optionInfo.state == MPOptionStateType.set) {
      final THProjectionCommandOption currentOption =
          widget.optionInfo.option as THProjectionCommandOption;

      _indexController.text = currentOption.index;
      _selectedChoice = currentOption.mode.name;
      _angleController.text = currentOption.elevationAngle?.toString() ?? '';
      _selectedUnit = currentOption.elevationUnit == null
          ? thDefaultAngleUnitAsString
          : currentOption.elevationUnit!.unit.name;
    } else {
      _selectedChoice = '';
      _selectedUnit = thDefaultAngleUnitAsString;
      _indexController.text = '';
      _angleController.text = '';
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
    switch (_selectedChoice) {
      case mpUnsetOptionID:
      case 'extended':
      case 'none':
      case 'plan':
        _isValid = true;
      case '':
        _isValid = false;
      case 'elevation':
        final double? angle = double.tryParse(_angleController.text);

        _isValid = _angleController.text.isEmpty ||
            ((angle != null) &&
                (_selectedUnit.isNotEmpty) &&
                ((angle >= 0) && (angle < 360)));
        _angleWarningMessage =
            _isValid ? null : appLocalizations.mpProjectionAngleWarning;
      default:
        throw Exception(
            'Invalid choice "$_selectedChoice" at MPProjectionOptionWidget._updateIsValid()');
    }

    _updateOkButtonEnabled();
  }

  void _updateOkButtonEnabled() {
    final bool isChanged = (_selectedChoice != _initialSelectedChoice) ||
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

    late final String labelText;

    switch (option) {
      case 'elevation':
      case 'extended':
      case 'plan':
        labelText = appLocalizations.mpProjectionIndexLabel;
      case 'none':
        return const SizedBox.shrink();
      default:
        throw Exception(
            'Invalid choice "$option" at MPProjectionOptionWidget._buildFormForOption()');
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

  void _okButtonPressed() {
    THCommandOption? newOption;

    switch (_selectedChoice) {
      case 'elevation':
        newOption = THProjectionCommandOption.fromStringWithParentMPID(
          parentMPID: widget.th2FileEditController.thFileMPID,
          index: _indexController.text.trim(),
          mode: THProjectionModeType.values.byName(_selectedChoice),
          elevationAngle: _angleController.text,
          elevationUnit: _selectedUnit,
        );
      case 'extended':
      case 'plan':
        newOption = THProjectionCommandOption.fromStringWithParentMPID(
          parentMPID: widget.th2FileEditController.thFileMPID,
          index: _indexController.text.trim(),
          mode: THProjectionModeType.values.byName(_selectedChoice),
        );
      case 'none':
        newOption = THProjectionCommandOption.fromStringWithParentMPID(
          parentMPID: widget.th2FileEditController.thFileMPID,
          mode: THProjectionModeType.values.byName(_selectedChoice),
        );
    }

    widget.th2FileEditController.userInteractionController.prepareSetOption(
      option: newOption,
      optionType: widget.optionInfo.type,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> optionWidgets = [];

    optionWidgets.add(
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
    );

    final choices = MPTextToUser.getProjectionModeTypeChoices();

    for (final entry in choices.entries) {
      final String value = entry.key;
      final String label = entry.value;

      optionWidgets.add(
        RadioListTile<String>(
          title: Text(label),
          value: value,
          groupValue: _selectedChoice,
          contentPadding: EdgeInsets.zero,
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
          children: optionWidgets,
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
