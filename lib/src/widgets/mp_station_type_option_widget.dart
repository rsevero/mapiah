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

class MPStationTypeOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPStationTypeOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPStationTypeOptionWidget> createState() =>
      _MPStationTypeOptionWidgetState();
}

class _MPStationTypeOptionWidgetState extends State<MPStationTypeOptionWidget> {
  late TextEditingController _stationController;
  late String _selectedChoice;
  final FocusNode _stationTextFieldFocusNode = FocusNode();
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  late final String _initialStation;
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
          case THExtendCommandOption _:
            _stationController = TextEditingController(
              text: currentOption.station,
            );
          case THFromCommandOption _:
            _stationController = TextEditingController(
              text: currentOption.station,
            );
          case THNameCommandOption _:
            _stationController = TextEditingController(
              text: currentOption.reference,
            );
          default:
            throw Exception(
              'Unsupported option type: ${widget.optionInfo..type} in _MPStationTypeOptionWidgetState.initState()',
            );
        }
        _selectedChoice = mpNonMultipleChoiceSetID;
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _stationController = TextEditingController(text: '');
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _stationController = TextEditingController(text: '');
        _selectedChoice = mpUnsetOptionID;
    }

    _initialStation = _stationController.text;
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
    _stationController.dispose();
    _stationTextFieldFocusNode.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _stationTextFieldFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      final String station = _stationController.text.trim();

      if (station.isNotEmpty) {
        /// The THFileMPID is used only as a placeholder for the actual
        /// parentMPID of the option(s) to be set. THFile isn't even a
        /// THHasOptionsMixin so it can't actually be the parent of an option,
        /// i.e., is has no options at all.
        switch (widget.optionInfo.type) {
          case THCommandOptionType.extend:
            newOption = THExtendCommandOption.fromStringWithParentMPID(
              parentMPID: widget.th2FileEditController.thFileMPID,
              station: station,
            );
          case THCommandOptionType.from:
            newOption = THFromCommandOption.fromStringWithParentMPID(
              parentMPID: widget.th2FileEditController.thFileMPID,
              station: station,
            );
          case THCommandOptionType.name:
            newOption = THNameCommandOption.fromStringWithParentMPID(
              parentMPID: widget.th2FileEditController.thFileMPID,
              reference: station,
            );
          default:
            throw Exception(
              'Unsupported option type: ${widget.optionInfo.type} in _MPStationTypeOptionWidgetState._okButtonPressed()',
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
    final String station = _stationController.text.trim();

    if (station.isNotEmpty) {
      _isValid = true;
      _warningMessage = null;
    } else {
      _isValid = false;
      _warningMessage = appLocalizations.mpStationTypeOptionWarning;
    }

    _updateIsOkButtonEnabled();
  }

  void _updateIsOkButtonEnabled() {
    final bool isChanged = ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            (_stationController.text != _initialStation)));

    setState(
      () {
        _isOkButtonEnabled = _isValid && isChanged;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title;
    final String stationLabel;

    switch (widget.optionInfo.type) {
      case THCommandOptionType.extend:
        title = appLocalizations.thCommandOptionExtend;
        stationLabel = appLocalizations.mpExtendStationLabel;
      case THCommandOptionType.from:
        title = appLocalizations.thCommandOptionFrom;
        stationLabel = appLocalizations.mpExtendStationLabel;
      case THCommandOptionType.name:
        title = appLocalizations.thCommandOptionName;
        stationLabel = appLocalizations.mpNameStationLabel;
      default:
        throw Exception(
          'Unsupported option type: ${widget.optionInfo.type} in _MPStationTypeOptionWidgetState.build()',
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
                _stationTextFieldFocusNode.requestFocus();
              },
            ),

            // Additional Inputs for "Set" Option
            if (_selectedChoice == mpNonMultipleChoiceSetID) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  MPTextFieldInputWidget(
                    labelText: stationLabel,
                    textEditingController: _stationController,
                    focusNode: _stationTextFieldFocusNode,
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
