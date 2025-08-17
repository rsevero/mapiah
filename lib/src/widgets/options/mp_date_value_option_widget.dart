import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_date_interval_input_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPDateValueOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPDateValueOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPDateValueOptionWidget> createState() =>
      _MPDateValueOptionWidgetState();
}

class _MPDateValueOptionWidgetState extends State<MPDateValueOptionWidget> {
  late String _date;
  late String _selectedChoice;
  late final String _initialDate;
  late final String _initialSelectedChoice;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  bool _isDateValid = false;
  bool _isOkButtonEnabled = false;
  final FocusNode _dateFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THDateValueCommandOption currentOption =
            widget.optionInfo.option! as THDateValueCommandOption;

        _date = currentOption.datetime.toString();
        _selectedChoice = mpNonMultipleChoiceSetID;
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _date = '';
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _date = '';
        _selectedChoice = mpUnsetOptionID;
    }

    _initialDate = _date;
    _initialSelectedChoice = _selectedChoice;
  }

  @override
  void dispose() {
    _dateFieldFocusNode.dispose();
    super.dispose();
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      if (_date.isNotEmpty) {
        /// The THFileMPID is used only as a placeholder for the actual
        /// parentMPID of the option(s) to be set. THFile isn't even a
        /// THHasOptionsMixin so it can't actually be the parent of an option,
        /// i.e., is has no options at all.
        newOption = THDateValueCommandOption.fromStringWithParentMPID(
          parentMPID: widget.th2FileEditController.thFileMPID,
          datetime: _date,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.mpDateValueInvalidValueErrorMessage),
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

  void _onDateChanged(String value, bool isValid) {
    setState(() {
      _date = value;
      _isDateValid = isValid;
      _updateIsOkButtonEnabled();
    });
  }

  void _updateIsOkButtonEnabled() {
    final bool isChanged =
        ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            (_date != _initialDate)));

    _isOkButtonEnabled = _isDateValid && isChanged;
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionDateValue,
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
                if (_selectedChoice == mpNonMultipleChoiceSetID) {
                  _dateFieldFocusNode.requestFocus();
                }
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(appLocalizations.mpChoiceUnset),
                    value: mpUnsetOptionID,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: Text(appLocalizations.mpChoiceSet),
                    value: mpNonMultipleChoiceSetID,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Additional Inputs for "Set" Option
            if (_selectedChoice == mpNonMultipleChoiceSetID) ...[
              MPDateIntervalInputWidget(
                initialValue: _date,
                focusNode: _dateFieldFocusNode,
                autofocus: true,
                onChanged: _onDateChanged,
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
