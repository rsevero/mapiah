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

class MPStationsOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPStationsOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPStationsOptionWidget> createState() => _MPStationsOptionWidgetState();
}

class _MPStationsOptionWidgetState extends State<MPStationsOptionWidget> {
  late String _selectedChoice;
  late List<TextEditingController> _stationNameControllers;
  final List<FocusNode> _stationNameFocusNodes = [];
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  late final List<String> _initialStationNames;
  late final String _initialSelectedChoice;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  List<String?> _stationNameWarningMessages = [];
  bool _isValid = false;
  bool _isOkButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THStationsCommandOption currentOption =
            widget.optionInfo.option! as THStationsCommandOption;

        _stationNameControllers = currentOption.stations
            .map((name) => TextEditingController(text: name.trim()))
            .toList();
        _stationNameFocusNodes.addAll(
          List.generate(_stationNameControllers.length, (_) => FocusNode()),
        );
        _selectedChoice = mpNonMultipleChoiceSetID;
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _stationNameControllers = [];
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _stationNameControllers = [];
        _selectedChoice = mpUnsetOptionID;
    }

    _initialStationNames = _stationNameControllers.map((c) => c.text).toList();
    _initialSelectedChoice = _selectedChoice;

    _updateIsValid();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasExecutedSingleRunOfPostFrameCallback) {
        _hasExecutedSingleRunOfPostFrameCallback = true;
        _executeOnceAfterBuild();
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _stationNameControllers) {
      controller.dispose();
    }
    for (final focusNode in _stationNameFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID &&
        _stationNameFocusNodes.isNotEmpty) {
      _stationNameFocusNodes.first.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      newOption = THStationsCommandOption.forCWJM(
        parentMPID: widget.th2FileEditController.thFileMPID,
        originalLineInTH2File: '',
        stations: _stationNameControllers.map((c) => c.text.trim()).toList(),
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

  void _updateIsValid() {
    switch (_selectedChoice) {
      case mpUnsetOptionID:
        _isValid = true;
      case mpNonMultipleChoiceSetID:
        _isValid = true;
        _stationNameWarningMessages = List.generate(
          _stationNameControllers.length,
          (index) {
            final isValid = _stationNameControllers[index].text
                .trim()
                .isNotEmpty;

            return isValid ? null : appLocalizations.mpStationsNameEmpty;
          },
        );

        _isValid = _stationNameWarningMessages.every(
          (message) => message == null,
        );
      default:
        _isValid = false;
    }

    _updateIsOkButtonEnabled();
  }

  void _updateIsOkButtonEnabled() {
    final bool isChanged =
        ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            ((_stationNameControllers.length != _initialStationNames.length) ||
                !_stationNameControllers.every(
                  (controller) =>
                      _initialStationNames.contains(controller.text),
                ))));

    setState(() {
      _isOkButtonEnabled = _isValid && isChanged;
    });
  }

  void _addStationNameField() {
    final FocusNode focusNode = FocusNode();

    _stationNameControllers.add(TextEditingController());
    _stationNameFocusNodes.add(focusNode);
    _stationNameWarningMessages.add(null);

    _updateIsValid();

    focusNode.requestFocus();
  }

  void _removeStationNameField(int index) {
    _stationNameControllers.removeAt(index).dispose();
    _stationNameFocusNodes.removeAt(index).dispose();
    _stationNameWarningMessages.removeAt(index);
    _updateIsValid();
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionStationNames,
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
                if (value != null) {
                  _selectedChoice = value;
                  _updateIsValid();
                }
              },
            ),
            RadioListTile<String>(
              title: Text(appLocalizations.mpChoiceSet),
              value: mpNonMultipleChoiceSetID,
              groupValue: _selectedChoice,
              contentPadding: EdgeInsets.zero,
              onChanged: (String? value) {
                if (value != null) {
                  _selectedChoice = value;
                  _updateIsValid();
                }
              },
            ),

            // Additional Inputs for "Set" Option
            if (_selectedChoice == mpNonMultipleChoiceSetID) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(
                    _stationNameControllers.length,
                    (index) => Column(
                      children: [
                        const SizedBox(height: mpButtonSpace),
                        Row(
                          children: [
                            Expanded(
                              child: MPTextFieldInputWidget(
                                controller: _stationNameControllers[index],
                                errorText: _stationNameWarningMessages[index],
                                labelText:
                                    '${appLocalizations.mpStationsNameLabel} ${index + 1}',
                                onChanged: (value) {
                                  _updateIsValid();
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () => _removeStationNameField(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: mpButtonSpace),
                  ElevatedButton.icon(
                    onPressed: _addStationNameField,
                    icon: const Icon(Icons.add),
                    label: Text(appLocalizations.mpStationsAddField),
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
