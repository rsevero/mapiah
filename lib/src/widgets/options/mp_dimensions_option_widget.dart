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

class MPDimensionsOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPDimensionsOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPDimensionsOptionWidget> createState() =>
      _MPDimensionsOptionWidgetState();
}

class _MPDimensionsOptionWidgetState extends State<MPDimensionsOptionWidget> {
  late TextEditingController _aboveController;
  late TextEditingController _belowController;
  late String _selectedUnit;
  late String _selectedChoice;
  final FocusNode _aboveTextFieldFocusNode = FocusNode();
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  late final Map<String, String> _unitMap;
  late final String _initialAbove;
  late final String _initialBelow;
  late final String _initialUnit;
  late final String _initialSelectedChoice;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  String? _aboveWarningMessage;
  String? _belowWarningMessage;
  bool _isOkButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _unitMap = MPTextToUser.getOrderedChoicesMap(
      MPTextToUser.getLengthUnitsChoices(),
    );

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THCommandOption currentOption = widget.optionInfo.option!;

        if (currentOption is THDimensionsValueCommandOption) {
          _aboveController = TextEditingController(
            text: currentOption.above.toString(),
          );
          _belowController = TextEditingController(
            text: currentOption.below.toString(),
          );
          _selectedChoice = mpNonMultipleChoiceSetID;
          _selectedUnit = currentOption.unit;
        } else {
          throw Exception(
            'Unsupported option type: ${widget.optionInfo.type} in _MPDimensionsOptionWidgetState.initState()',
          );
        }
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _aboveController = TextEditingController(text: '0');
        _belowController = TextEditingController(text: '0');
        _selectedChoice = '';
        _selectedUnit = '';
      case MPOptionStateType.unset:
        _aboveController = TextEditingController(text: '0');
        _belowController = TextEditingController(text: '0');
        _selectedChoice = mpUnsetOptionID;
        _selectedUnit = thDefaultLengthUnitAsString;
    }

    _initialAbove = _aboveController.text;
    _initialBelow = _belowController.text;
    _initialUnit = _selectedUnit;
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
    _aboveController.dispose();
    _belowController.dispose();
    _aboveTextFieldFocusNode.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _aboveTextFieldFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      final double? above = double.tryParse(_aboveController.text);
      final double? below = double.tryParse(_belowController.text);

      if ((above != null) && (below != null)) {
        /// The THFileMPID is used only as a placeholder for the actual
        /// parentMPID of the option(s) to be set. THFile isn't even a
        /// THHasOptionsMixin so it can't actually be the parent of an option,
        /// i.e., is has no options at all.
        newOption = THDimensionsValueCommandOption.fromStringWithParentMPID(
          parentMPID: widget.th2FileEditController.thFileMPID,
          above: _aboveController.text,
          below: _belowController.text,
          unit: _selectedUnit,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appLocalizations.mpDimensionsInvalidValueErrorMessage,
            ),
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

  void _updateOkButtonEnabled() {
    final String aboveText = _aboveController.text.trim();
    final String belowText = _belowController.text.trim();
    final bool isValidAbove = (double.tryParse(aboveText) != null);
    final bool isValidBelow = (double.tryParse(belowText) != null);
    final bool isChanged =
        ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            ((aboveText != _initialAbove) ||
                (belowText != _initialBelow) ||
                (_selectedUnit != _initialUnit))));

    setState(() {
      _aboveWarningMessage = isValidAbove
          ? null
          : appLocalizations.mpDimensionsInvalidValueErrorMessage;
      _belowWarningMessage = isValidBelow
          ? null
          : appLocalizations.mpDimensionsInvalidValueErrorMessage;
      _isOkButtonEnabled = isValidAbove && isValidBelow && isChanged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionDimensionsValue,
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
                  _updateOkButtonEnabled();
                });
                if (_selectedChoice == mpNonMultipleChoiceSetID) {
                  _aboveTextFieldFocusNode.requestFocus();
                }
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    key: ValueKey(
                      "MPDimensionsOptionWidget|RadioListTile|$mpUnsetOptionID",
                    ),
                    title: Text(appLocalizations.mpChoiceUnset),
                    value: mpUnsetOptionID,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    key: ValueKey(
                      "MPDimensionsOptionWidget|RadioListTile|$mpNonMultipleChoiceSetID",
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  MPTextFieldInputWidget(
                    controller: _aboveController,
                    errorText: _aboveWarningMessage,
                    labelText: appLocalizations.mpDimensionsAboveLabel,
                    autofocus: true,
                    focusNode: _aboveTextFieldFocusNode,
                    onChanged: (value) {
                      _updateOkButtonEnabled();
                    },
                  ),
                  const SizedBox(width: mpButtonSpace),
                  MPTextFieldInputWidget(
                    controller: _belowController,
                    errorText: _belowWarningMessage,
                    labelText: appLocalizations.mpDimensionsBelowLabel,
                    onChanged: (value) {
                      _updateOkButtonEnabled();
                    },
                  ),
                  const SizedBox(width: mpButtonSpace),
                  DropdownMenu(
                    label: Text(appLocalizations.thCommandOptionLengthUnit),
                    initialSelection: _selectedUnit,
                    menuStyle: MenuStyle(
                      alignment: Alignment(
                        -1.0,
                        -_unitMap.entries.length.toDouble(),
                      ),
                    ),
                    dropdownMenuEntries: _unitMap.entries.map((entry) {
                      return DropdownMenuEntry<String>(
                        value: entry.key,
                        label: entry.value,
                      );
                    }).toList(),
                    onSelected: (String? value) {
                      _selectedUnit = value ?? thDefaultLengthUnitAsString;
                      _updateOkButtonEnabled();
                    },
                    searchCallback: (entries, query) {
                      final index = entries.indexWhere(
                        (entry) => entry.label == query,
                      );

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
