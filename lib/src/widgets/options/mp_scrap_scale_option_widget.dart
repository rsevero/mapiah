import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_text_field_input_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPScrapScaleOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPScrapScaleOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPScrapScaleOptionWidget> createState() =>
      _MPScrapScaleOptionWidgetState();
}

class _MPScrapScaleOptionWidgetState extends State<MPScrapScaleOptionWidget> {
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
    _unitMap = MPTextToUser.getOrderedChoices(
      MPTextToUser.getLengthUnitsChoices(),
    );

    for (int i = 0; i < mpScrapScaleMaxValues; i++) {
      _lengthControllers.add(TextEditingController());
      _initialLengths.add('');
      _lengthWarningMessages.add(null);
    }

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THScrapScaleCommandOption currentOption =
            widget.optionInfo.option as THScrapScaleCommandOption;

        int i = 0;
        for (final numericSpecification
            in currentOption.numericSpecifications) {
          _lengthControllers[i].text = numericSpecification.value.toString();
          i++;
        }

        switch (currentOption.numericSpecifications.length) {
          case 1:
            _selectedChoice = mpScrapScale1ValueID;
          case 2:
            _selectedChoice = mpScrapScale2ValuesID;
          case 8:
            _selectedChoice = mpScrapScale8ValuesID;
          default:
            throw Exception(
              'Invalid length "${currentOption.numericSpecifications.length}" at MPScrapScaleOptionWidget.initState()',
            );
        }

        _selectedUnit = currentOption.unitPart.unit.name;

      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _selectedChoice = '';
        _selectedUnit = thDefaultLengthUnitAsString;
      case MPOptionStateType.unset:
        _selectedChoice = mpUnsetOptionID;
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
    switch (_selectedChoice) {
      case mpUnsetOptionID:
      case '':
        return 0;
      case mpScrapScale1ValueID:
        return 1;
      case mpScrapScale2ValuesID:
        return 2;
      case mpScrapScale8ValuesID:
        return 8;
      default:
        throw Exception(
          'Invalid choice "$_selectedChoice" at MPScrapScaleOptionWidget._getRefCount()',
        );
    }
  }

  void _updateIsValid() {
    int refsCount = 0;
    _isValid = true;

    switch (_selectedChoice) {
      case mpUnsetOptionID:
        _isValid = true;
      case '':
        _isValid = false;
      case mpScrapScale1ValueID:
        refsCount = 1;
      case mpScrapScale2ValuesID:
        refsCount = 2;
      case mpScrapScale8ValuesID:
        refsCount = 8;
      default:
        throw Exception(
          'Invalid choice "$_selectedChoice" at MPScrapScaleOptionWidget._updateIsValid()',
        );
    }

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

  void _okButtonPressed() {
    THCommandOption? newOption;

    late final int refCounts;

    switch (_selectedChoice) {
      case mpScrapScale1ValueID:
      case mpScrapScale2ValuesID:
      case mpScrapScale8ValuesID:
        final List<THDoublePart> numericSpecifications = [];

        refCounts = _getRefCount();

        for (int i = 0; i < refCounts; i++) {
          final double? value = double.tryParse(_lengthControllers[i].text);

          if (value != null) {
            numericSpecifications.add(
              THDoublePart.fromString(valueString: _lengthControllers[i].text),
            );
          } else {
            throw Exception(
              'Invalid value "${_lengthControllers[i].text}" at MPScrapScaleOptionWidget._okButtonPressed()',
            );
          }
        }
        newOption = THScrapScaleCommandOption.fromStringWithParentMPID(
          parentMPID: widget.th2FileEditController.thFileMPID,
          numericSpecifications: numericSpecifications,
          unitPart: THLengthUnitPart.fromString(unitString: _selectedUnit),
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
          title: Text(label),
          value: value,
          contentPadding: EdgeInsets.zero,
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
          children: [
            RadioGroup(
              groupValue: _selectedChoice,
              onChanged: (value) {
                _selectedChoice = value ?? '';
                _updateIsValid();
              },
              child: Column(children: optionWidgets),
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
