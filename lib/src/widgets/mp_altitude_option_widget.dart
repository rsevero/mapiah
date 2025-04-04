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

class MPAltitudeOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPAltitudeOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPAltitudeOptionWidget> createState() => _MPAltitudeOptionWidgetState();
}

class _MPAltitudeOptionWidgetState extends State<MPAltitudeOptionWidget> {
  late TextEditingController _altitudeController;
  late bool _isFixed;
  late String _selectedUnit;
  late final Map<String, String> _unitMap;
  final FocusNode _textFieldFocusNode = FocusNode();
  late final String _initialAltitude;
  late final bool _initialIsFixed;
  late final String _initialSelectedUnit;
  late String _selectedChoice;
  late final String _initialSelectedChoice;
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  String? _warningMessage;
  bool _isValid = false;
  bool _isOkButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _unitMap =
        MPTextToUser.getOrderedChoices(MPTextToUser.getLengthUnitsChoices());

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THCommandOption currentOption = widget.optionInfo.option!;

        if (currentOption is THAltitudeCommandOption) {
          _altitudeController = TextEditingController(
            text: currentOption.length.toString(),
          );
          _isFixed = currentOption.isFix;
          _selectedChoice = mpNonMultipleChoiceSetID;
          _selectedUnit = currentOption.unit.unit.name;
        } else if (currentOption is THAltitudeValueCommandOption) {
          _altitudeController = TextEditingController(
            text: currentOption.length.toString(),
          );
          _isFixed = currentOption.isFix;
          _selectedChoice = mpNonMultipleChoiceSetID;
          _selectedUnit = currentOption.unit.unit.name;
        } else {
          throw Exception(
            'Unsupported option type: ${widget.optionInfo.type} in MPAltitudeOptionWidget.initState()',
          );
        }
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _altitudeController = TextEditingController(text: '0');
        _isFixed = false;
        _selectedChoice = '';
        _selectedUnit = '';
      case MPOptionStateType.unset:
        _altitudeController = TextEditingController(text: '0');
        _isFixed = false;
        _selectedChoice = mpUnsetOptionID;
        _selectedUnit = thDefaultLengthUnitAsString;
    }

    _initialAltitude = _altitudeController.text;
    _initialIsFixed = _isFixed;
    _initialSelectedUnit = _selectedUnit;
    _initialSelectedChoice = _selectedChoice;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasExecutedSingleRunOfPostFrameCallback) {
        _hasExecutedSingleRunOfPostFrameCallback = true;
        _executeOnceAfterBuild();
      }
    });
  }

  @override
  void dispose() {
    _altitudeController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _textFieldFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      final double? altitude = double.tryParse(_altitudeController.text);

      if (altitude != null) {
        /// The THFileMPID is used only as a placeholder for the actual
        /// parentMPID of the option(s) to be set. THFile isn't even a
        /// THHasOptionsMixin so it can't actually be the parent of an option,
        /// i.e., is has no options at all.
        switch (widget.optionInfo.type) {
          case THCommandOptionType.altitude:
            newOption = THAltitudeCommandOption.fromStringWithParentMPID(
              parentMPID: widget.th2FileEditController.thFileMPID,
              height: _altitudeController.text,
              isFix: _isFixed,
              unit: _selectedUnit,
            );
          case THCommandOptionType.altitudeValue:
            newOption = THAltitudeValueCommandOption.fromStringWithParentMPID(
              parentMPID: widget.th2FileEditController.thFileMPID,
              height: _altitudeController.text,
              isFix: _isFixed,
              unit: _selectedUnit,
            );
          default:
            throw Exception(
              'Unsupported option type: ${widget.optionInfo.type} in MPAltitudeOptionWidget._okButtonPressed()',
            );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.mpAltitudeInvalidValueErrorMessage),
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

  void _updateIsValid() {
    if (_selectedChoice == mpUnsetOptionID) {
      setState(
        () {
          _warningMessage = null;
          _isValid = true;
          _updateOkButtonEnabled();
        },
      );
    } else {
      final double? altitude = double.tryParse(_altitudeController.text);

      if (altitude == null) {
        setState(
          () {
            _warningMessage =
                appLocalizations.mpAltitudeInvalidValueErrorMessage;
            _isValid = false;
            _updateOkButtonEnabled();
          },
        );
      } else {
        setState(
          () {
            _warningMessage = null;
            _isValid = true;
            _updateOkButtonEnabled();
          },
        );
      }
    }
  }

  void _updateOkButtonEnabled() {
    final bool isChanged = ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            ((_altitudeController.text != _initialAltitude) ||
                (_isFixed != _initialIsFixed) ||
                (_selectedUnit != _initialSelectedUnit))));

    _isOkButtonEnabled = _isValid && isChanged;
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionAltitudeValue,
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
                _selectedChoice = value!;
                _updateIsValid();
              },
            ),
            RadioListTile<String>(
              title: Text(appLocalizations.mpChoiceSet),
              value: mpNonMultipleChoiceSetID,
              groupValue: _selectedChoice,
              contentPadding: EdgeInsets.zero,
              onChanged: (String? value) {
                _selectedChoice = value!;
                _updateIsValid();
              },
            ),

            // Additional Inputs for "Set" Option
            if (_selectedChoice == mpNonMultipleChoiceSetID) ...[
              // Switch for "Fix" Parameter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(appLocalizations.thCommandOptionAltitudeFix),
                  Transform.scale(
                    scale: mpSwitchScaleFactor,
                    child: Switch(
                      value: _isFixed,
                      onChanged: (bool value) {
                        _isFixed = value;
                        _updateIsValid();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: mpButtonSpace),
              // Numeric Input for Altitude
              MPTextFieldInputWidget(
                errorText: _warningMessage,
                textEditingController: _altitudeController,
                labelText: appLocalizations.thCommandOptionAltitudeValue,
                focusNode: _textFieldFocusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _updateIsValid();
                },
              ),

              const SizedBox(height: mpButtonSpace),
              DropdownMenu(
                label: Text(appLocalizations.thCommandOptionLengthUnit),
                initialSelection: _selectedUnit,
                menuStyle: MenuStyle(
                    alignment: Alignment(
                  -1.0,
                  -_unitMap.entries.length.toDouble(),
                )),
                dropdownMenuEntries: _unitMap.entries.map((entry) {
                  return DropdownMenuEntry<String>(
                    value: entry.key,
                    label: entry.value,
                  );
                }).toList(),
                onSelected: (String? value) {
                  _selectedUnit = value ?? thDefaultLengthUnitAsString;
                  _updateIsValid();
                },
                searchCallback: (entries, query) {
                  final int index =
                      entries.indexWhere((entry) => entry.label == query);

                  return index >= 0 ? index : null;
                },
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
