import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
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

class MPDoubleValueOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPDoubleValueOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPDoubleValueOptionWidget> createState() =>
      _MPDoubleValueOptionWidgetState();
}

class _MPDoubleValueOptionWidgetState extends State<MPDoubleValueOptionWidget> {
  late TextEditingController _doubleController;
  late String _selectedChoice;
  final FocusNode _doubleTextFieldFocusNode = FocusNode();
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  late final String _initialDouble;
  late final String _initialSelectedChoice;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  String? _doubleWarningMessage;
  bool _isOkButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THCommandOption currentOption = widget.optionInfo.option!;

        switch (currentOption) {
          case THLineHeightCommandOption _:
            _doubleController = TextEditingController(
              text: currentOption.height.toString(),
            );
          case THLSizeCommandOption _:
            _doubleController = TextEditingController(
              text: currentOption.number.toString(),
            );
          default:
            throw Exception(
              'Unsupported option type: ${widget.optionInfo.type} in _MPDoubleValueOptionWidgetState.initState()',
            );
        }
        _selectedChoice = mpNonMultipleChoiceSetID;
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _doubleController = TextEditingController(text: '0');
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _doubleController = TextEditingController(text: '0');
        _selectedChoice = mpUnsetOptionID;
    }

    _initialDouble = _doubleController.text;
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
    _doubleController.dispose();
    _doubleTextFieldFocusNode.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _doubleTextFieldFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      final double? doubleValue = double.tryParse(_doubleController.text);

      if (doubleValue != null) {
        switch (widget.optionInfo.type) {
          case THCommandOptionType.lineHeight:
            newOption = THLineHeightCommandOption.fromStringWithParentMPID(
              parentMPID: mpParentMPIDPlaceholder,
              height: _doubleController.text,
            );
          case THCommandOptionType.lSize:
            newOption = THLSizeCommandOption.fromStringWithParentMPID(
              parentMPID: mpParentMPIDPlaceholder,
              number: _doubleController.text,
            );
          default:
            throw Exception(
              'Unsupported option type: ${widget.optionInfo.type} in _MPDoubleValueOptionWidgetState._okButtonPressed()',
            );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appLocalizations.mpLineHeightInvalidValueErrorMessage,
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
    final String doubleText = _doubleController.text.trim();
    final bool isValid = (double.tryParse(doubleText) != null);
    final bool isChanged =
        ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            (doubleText != _initialDouble)));

    setState(() {
      _doubleWarningMessage = isValid
          ? null
          : appLocalizations.mpDoubleValueInvalidValueErrorMessage;
      _isOkButtonEnabled = isValid && isChanged;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title;
    final String label;

    switch (widget.optionInfo.type) {
      case THCommandOptionType.lineHeight:
        title = appLocalizations.thCommandOptionLineHeight;
        label = appLocalizations.mpLineHeightHeightLabel;
      case THCommandOptionType.lSize:
        title = appLocalizations.thCommandOptionLSize;
        label = appLocalizations.mpLSizeLabel;
      default:
        throw Exception(
          'Unsupported option type: ${widget.optionInfo.type} in _MPDoubleValueOptionWidgetState.build()',
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
                  _updateOkButtonEnabled();
                });
                if (_selectedChoice == mpNonMultipleChoiceSetID) {
                  _doubleTextFieldFocusNode.requestFocus();
                }
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    key: ValueKey(
                      "MPDoubleValueOptionWidget|RadioListTile|$mpUnsetOptionID",
                    ),
                    title: Text(appLocalizations.mpChoiceUnset),
                    value: mpUnsetOptionID,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    key: ValueKey(
                      "MPDoubleValueOptionWidget|RadioListTile|$mpNonMultipleChoiceSetID",
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
                    controller: _doubleController,
                    errorText: _doubleWarningMessage,
                    labelText: label,
                    autofocus: true,
                    focusNode: _doubleTextFieldFocusNode,
                    onChanged: (value) {
                      _updateOkButtonEnabled();
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
