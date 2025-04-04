import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_date_interval_input_widget.dart';
import 'package:mapiah/src/widgets/inputs/mp_text_field_input_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPCopyrightOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPCopyrightOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPCopyrightOptionWidget> createState() =>
      _MPCopyrightOptionWidgetState();
}

class _MPCopyrightOptionWidgetState extends State<MPCopyrightOptionWidget> {
  late String _date;
  late String _selectedChoice;
  late TextEditingController _messageController;
  final FocusNode _messageFieldFocusNode = FocusNode();
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  late final String _initialDate;
  late final String _initialMessage;
  late final String _initialSelectedChoice;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  String _messageWarningMessage = '';
  bool _isDateValid = false;
  bool _isMessageValid = false;
  bool _isOkButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THCopyrightCommandOption currentOption =
            widget.optionInfo.option! as THCopyrightCommandOption;

        _date = currentOption.datetime.toString();
        _messageController = TextEditingController(
            text: currentOption.copyright.content.toString());
        _selectedChoice = mpNonMultipleChoiceSetID;
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _date = '';
        _messageController = TextEditingController(text: '');
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _date = '';
        _messageController = TextEditingController(text: '');
        _selectedChoice = mpUnsetOptionID;
    }

    _initialDate = _date;
    _initialMessage = _messageController.text;
    _initialSelectedChoice = _selectedChoice;
    _onMessageChanged();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasExecutedSingleRunOfPostFrameCallback) {
        _hasExecutedSingleRunOfPostFrameCallback = true;
        _executeOnceAfterBuild();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFieldFocusNode.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _messageFieldFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      /// The THFileMPID is used only as a placeholder for the actual
      /// parentMPID of the option(s) to be set. THFile isn't even a
      /// THHasOptionsMixin so it can't actually be the parent of an option,
      /// i.e., is has no options at all.
      newOption = THCopyrightCommandOption.fromStringWithParentMPID(
        parentMPID: widget.th2FileEditController.thFileMPID,
        datetime: _date,
        copyrightMessage: _messageController.text.trim(),
      );
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
    setState(
      () {
        _date = value;
        _isDateValid = isValid;
        _updateIsOkButtonEnabled();
      },
    );
  }

  void _onMessageChanged() {
    _isMessageValid = _messageController.text.trim().isNotEmpty;

    setState(
      () {
        _messageWarningMessage = _isMessageValid
            ? ''
            : appLocalizations.mpCopyrightInvalidMessageErrorMessage;
        _updateIsOkButtonEnabled();
      },
    );
  }

  void _updateIsOkButtonEnabled() {
    final bool isChanged = ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            ((_date != _initialDate) ||
                (_messageController.text != _initialMessage))));

    _isOkButtonEnabled = _isDateValid && _isMessageValid && isChanged;
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionCopyright,
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
              },
            ),

            // Additional Inputs for "Set" Option
            if (_selectedChoice == mpNonMultipleChoiceSetID) ...[
              MPTextFieldInputWidget(
                textEditingController: _messageController,
                errorText: _messageWarningMessage,
                labelText: appLocalizations.mpCopyrightMessageLabel,
                autofocus: true,
                focusNode: _messageFieldFocusNode,
                onChanged: (value) {
                  _onMessageChanged();
                },
              ),
              const SizedBox(height: mpButtonSpace),
              MPDateIntervalInputWidget(
                initialValue: _date,
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
