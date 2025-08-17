import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_scale_multiple_choice_part.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_text_field_input_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPPLScaleOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPPLScaleOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPPLScaleOptionWidget> createState() => _MPPLScaleOptionWidgetState();
}

class _MPPLScaleOptionWidgetState extends State<MPPLScaleOptionWidget> {
  String _selectedChoice = '';
  String _sizeAsNamed = '';
  late final String _initialSizeAsNamed;
  late final String _initialSizeAsNumeric;
  late final String _initialSelectedChoice;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  bool _isValid = false;
  bool _isOkButtonEnabled = false;
  late final TextEditingController _numericController;
  final FocusNode _numericTextFieldFocusNode = FocusNode();
  String? _numericWarningMessage;

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THPLScaleCommandOption currentOption =
            (widget.optionInfo.option! as THPLScaleCommandOption);
        _selectedChoice = currentOption.scaleType.name;
        _sizeAsNamed = currentOption.namedSize.choice;
        _numericController = TextEditingController(
          text: currentOption.numericSize.value.toString(),
        );
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _selectedChoice = '';
        _sizeAsNamed = '';
        _numericController = TextEditingController(text: '');
      case MPOptionStateType.unset:
        _selectedChoice = mpUnsetOptionID;
        _sizeAsNamed = '';
        _numericController = TextEditingController(text: '');
    }

    _initialSizeAsNamed = _sizeAsNamed;
    _initialSizeAsNumeric = _numericController.text;
    _initialSelectedChoice = _selectedChoice;
    _updateIsValid();
  }

  void _updateIsValid() {
    switch (_selectedChoice) {
      case 'named':
        _isValid =
            (_sizeAsNamed.isNotEmpty &&
            THScaleMultipleChoicePart.isChoice(_sizeAsNamed));
      case 'numeric':
        _isValid = (double.tryParse(_numericController.text) != null);
      default:
        _isValid = false;
    }

    _updateIsOkButtonEnabled();
  }

  Widget _buildFormForOption(String option) {
    switch (option) {
      case mpUnsetOptionID:
        return const SizedBox.shrink();
      case 'named':
        final Map<String, String> namedScaleOptions =
            MPTextToUser.getNamedScaleOptions();

        return Padding(
          padding: const EdgeInsets.only(left: mpButtonSpace),
          child: RadioGroup<String>(
            groupValue: _sizeAsNamed,
            onChanged: (String? newValue) {
              setState(() {
                _sizeAsNamed = newValue!;
              });
              _updateIsValid();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: namedScaleOptions.entries.map((entry) {
                final String value = entry.key;
                final String label = entry.value;

                return RadioListTile<String>(
                  title: Text(label),
                  value: value,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ),
        );
      case 'numeric':
        return Padding(
          padding: const EdgeInsets.only(left: mpButtonSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MPTextFieldInputWidget(
                labelText: appLocalizations.mpPLScaleNumericLabel,
                controller: _numericController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                errorText: _numericWarningMessage,
                autofocus: true,
                focusNode: _numericTextFieldFocusNode,
                onChanged: (value) {
                  _updateIsValid();
                },
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice != mpUnsetOptionID) {
      /// The THFileMPID is used only as a placeholder for the actual
      /// parentMPID of the option(s) to be set. THFile isn't even a
      /// THHasOptionsMixin so it can't actually be the parent of an option,
      /// i.e., is has no options at all.
      switch (_selectedChoice) {
        case 'named':
          newOption = THPLScaleCommandOption.sizeAsNamedWithParentMPID(
            parentMPID: widget.th2FileEditController.thFileMPID,
            textScaleSize: _sizeAsNamed,
          );
        case 'numeric':
          newOption =
              THPLScaleCommandOption.sizeAsNumberFromStringWithParentMPID(
                parentMPID: widget.th2FileEditController.thFileMPID,
                numericScaleSize: _numericController.text,
              );
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

  void _updateIsOkButtonEnabled() {
    final bool isChanged =
        ((_selectedChoice != _initialSelectedChoice) ||
        (((_selectedChoice == 'named') &&
                (_sizeAsNamed != _initialSizeAsNamed)) ||
            ((_selectedChoice == 'numeric') &&
                (_numericController.text != _initialSizeAsNumeric))));

    setState(() {
      _isOkButtonEnabled = _isValid && isChanged;
    });
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

    final Map<String, String> allOptions =
        MPTextToUser.getPLScaleCommandOptionTypeOptions();

    for (final entry in allOptions.entries) {
      optionWidgets.add(
        RadioListTile<String>(
          title: Text(entry.value),
          value: entry.key,
          contentPadding: EdgeInsets.zero,
        ),
      );
      if (_selectedChoice == entry.key) {
        optionWidgets.add(_buildFormForOption(entry.key));
      }
    }

    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionCS,
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
