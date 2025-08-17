import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_string_part.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_text_field_input_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPTextTypeOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPTextTypeOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPTextTypeOptionWidget> createState() => _MPTextTypeOptionWidgetState();
}

class _MPTextTypeOptionWidgetState extends State<MPTextTypeOptionWidget> {
  late TextEditingController _textController;
  late String _selectedChoice;
  final FocusNode _textTextFieldFocusNode = FocusNode();
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  late final String _initialText;
  late final String _initialSelectedChoice;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  bool _isValid = false;
  bool _isOkButtonEnabled = false;
  String? _warningMessage;

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THCommandOption currentOption = widget.optionInfo.option!;

        switch (currentOption) {
          case THMarkCommandOption _:
            _textController = TextEditingController(
              text: currentOption.mark.trim(),
            );
          case THTextCommandOption _:
            _textController = TextEditingController(
              text: currentOption.text.content.trim(),
            );
          case THTitleCommandOption _:
            _textController = TextEditingController(
              text: currentOption.title.content.trim(),
            );
          case THUnrecognizedCommandOption _:
            _textController = TextEditingController(
              text: currentOption.value?.trim() ?? '',
            );
          default:
            throw Exception(
              'Unsupported option type: ${widget.optionInfo..type} in _MPTextTypeOptionWidgetState.initState()',
            );
        }
        _selectedChoice = mpNonMultipleChoiceSetID;
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _textController = TextEditingController(text: '');
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _textController = TextEditingController(text: '');
        _selectedChoice = mpUnsetOptionID;
    }

    _initialText = _textController.text;
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
    _textController.dispose();
    _textTextFieldFocusNode.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _textTextFieldFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      final String text = _textController.text.trim();

      if (text.isNotEmpty) {
        /// The THFileMPID is used only as a placeholder for the actual
        /// parentMPID of the option(s) to be set. THFile isn't even a
        /// THHasOptionsMixin so it can't actually be the parent of an option,
        /// i.e., is has no options at all.
        switch (widget.optionInfo.type) {
          case THCommandOptionType.mark:
            newOption = THMarkCommandOption.fromStringWithParentMPID(
              parentMPID: widget.th2FileEditController.thFileMPID,
              mark: text,
            );
          case THCommandOptionType.text:
            newOption = THTextCommandOption.forCWJM(
              parentMPID: widget.th2FileEditController.thFileMPID,
              originalLineInTH2File: '',
              text: THStringPart(content: text),
            );
          case THCommandOptionType.title:
            newOption = THTitleCommandOption.forCWJM(
              parentMPID: widget.th2FileEditController.thFileMPID,
              originalLineInTH2File: '',
              title: THStringPart(content: text),
            );
          case THCommandOptionType.unrecognizedCommandOption:
            newOption = THUnrecognizedCommandOption.forCWJM(
              parentMPID: widget.th2FileEditController.thFileMPID,
              originalLineInTH2File: '',
              value: text,
            );
          default:
            throw Exception(
              'Unsupported option type: ${widget.optionInfo.type} in _MPTextTypeOptionWidgetState._okButtonPressed()',
            );
        }
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
    final String text = _textController.text.trim();

    switch (_selectedChoice) {
      case mpUnsetOptionID:
        _isValid = true;
      case mpNonMultipleChoiceSetID:
        _isValid = text.isNotEmpty;
        _warningMessage = _isValid
            ? null
            : appLocalizations.mpTextTypeOptionWarning;
    }

    _updateIsOkButtonEnabled();
  }

  void _updateIsOkButtonEnabled() {
    final bool isChanged =
        ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            (_textController.text != _initialText)));

    setState(() {
      _isOkButtonEnabled = _isValid && isChanged;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title;
    final String textLabel;

    switch (widget.optionInfo.type) {
      case THCommandOptionType.mark:
        title = appLocalizations.thCommandOptionMark;
        textLabel = appLocalizations.mpMarkTextLabel;
      case THCommandOptionType.text:
        title = appLocalizations.thCommandOptionText;
        textLabel = appLocalizations.mpTextTextLabel;
      case THCommandOptionType.title:
        title = appLocalizations.thCommandOptionTitle;
        textLabel = appLocalizations.mpTitleTextLabel;
      case THCommandOptionType.unrecognizedCommandOption:
        title = appLocalizations.thCommandOptionUnrecognized;
        textLabel = appLocalizations.mpUnrecognizedCommandOptionTextLabel;
      default:
        throw Exception(
          'Unsupported option type: ${widget.optionInfo.type} in _MPTextTypeOptionWidgetState.build()',
        );
    }

    return MPOverlayWindowWidget(
      title: title,
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
                  _updateIsValid();
                });
                if (_selectedChoice == mpNonMultipleChoiceSetID) {
                  _textTextFieldFocusNode.requestFocus();
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  MPTextFieldInputWidget(
                    labelText: textLabel,
                    controller: _textController,
                    focusNode: _textTextFieldFocusNode,
                    autofocus: true,
                    errorText: _warningMessage,
                    keyboardType: TextInputType.text,
                    onChanged: (String value) {
                      _updateIsValid();
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
