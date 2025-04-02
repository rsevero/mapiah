import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPDistOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPDistOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPDistOptionWidget> createState() => _MPDistOptionWidgetState();
}

class _MPDistOptionWidgetState extends State<MPDistOptionWidget> {
  late TextEditingController _distanceController;
  late String _selectedUnit;
  late String _selectedChoice;
  final FocusNode _valueTextFieldFocusNode = FocusNode();
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  late final Map<String, String> _unitMap;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;

  @override
  void initState() {
    super.initState();
    _unitMap = MPTextToUser.getOrderedChoices(
      MPTextToUser.getLengthUnitsChoices(),
    );

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THCommandOption currentOption = widget.optionInfo.option!;

        if (currentOption is THDistCommandOption) {
          _distanceController = TextEditingController(
            text: currentOption.length.value.toString(),
          );
          _selectedChoice = mpNonMultipleChoiceSetID;
          _selectedUnit = currentOption.unit.unit.name;
        } else {
          throw Exception(
            'Unsupported option type: ${widget.optionInfo.type} in _MPDistOptionWidgetState.initState()',
          );
        }
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _distanceController = TextEditingController(text: '0');
        _selectedChoice = '';
        _selectedUnit = '';
      case MPOptionStateType.unset:
        _distanceController = TextEditingController(text: '0');
        _selectedChoice = mpUnsetOptionID;
        _selectedUnit = thDefaultLengthUnitAsString;
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
    _distanceController.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _valueTextFieldFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      final double? distance = double.tryParse(_distanceController.text);

      if (distance != null) {
        /// The THFileMPID is used only as a placeholder for the actual
        /// parentMPID of the option(s) to be set. THFile isn't even a
        /// THHasOptionsMixin so it can't actually be the parent of an option,
        /// i.e., is has no options at all.
        newOption = THDistCommandOption.fromStringWithParentMPID(
          parentMPID: widget.th2FileEditController.thFileMPID,
          distance: distance.toString(),
          unit: _selectedUnit,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.mpDistInvalidValueErrorMessage),
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

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionDist,
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
                setState(() {
                  _selectedChoice = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(appLocalizations.mpChoiceSet),
              value: mpNonMultipleChoiceSetID,
              groupValue: _selectedChoice,
              contentPadding: EdgeInsets.zero,
              onChanged: (String? value) {
                setState(() {
                  _selectedChoice = value!;
                });
                _valueTextFieldFocusNode.requestFocus();
              },
            ),

            // Additional Inputs for "Set" Option
            if (_selectedChoice == mpNonMultipleChoiceSetID) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MPInteractionAux.calculateTextFieldWidth(
                      mpDefaultMaxDigitsForTextFields,
                    ),
                    child: TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      focusNode: _valueTextFieldFocusNode,
                      decoration: InputDecoration(
                        labelText: appLocalizations.mpDistDistanceLabel,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: mpButtonSpace),
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
                      setState(() {
                        _selectedUnit = value ?? thDefaultLengthUnitAsString;
                      });
                    },
                    searchCallback: (entries, query) {
                      final index =
                          entries.indexWhere((entry) => entry.label == query);

                      return index >= 0 ? index : null;
                    },
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
              onPressed: _okButtonPressed,
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
