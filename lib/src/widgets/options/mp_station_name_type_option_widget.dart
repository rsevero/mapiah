// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_element_edit_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_text_field_input_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/options/mp_option_type_being_edited_tracking_mixin.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPStationNameTypeOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPStationNameTypeOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPStationNameTypeOptionWidget> createState() =>
      _MPStationNameTypeOptionWidgetState();
}

class _MPStationNameTypeOptionWidgetState
    extends State<MPStationNameTypeOptionWidget>
    with MPOptionTypeBeingEditedTrackingMixin<MPStationNameTypeOptionWidget> {
  late TextEditingController _uniquePartController;
  late TextEditingController _surveyPartController;
  late String _selectedChoice;
  final FocusNode _uniquePartTextFieldFocusNode = FocusNode();
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  late final String _initialUniquePart;
  late final String _initialSurveyPart;
  late final String _initialSelectedChoice;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  bool _isValid = false;
  bool _isOkButtonEnabled = false;
  String? _uniquePartWarningMessage;
  String? _surveyPartWarningMessage;

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THCommandOption currentOption = widget.optionInfo.option!;
        final String station = _getStationValue(currentOption);
        final ({String uniquePart, String surveyPart}) stationParts =
            _splitStationParts(station);

        _uniquePartController = TextEditingController(
          text: stationParts.uniquePart,
        );
        _surveyPartController = TextEditingController(
          text: stationParts.surveyPart,
        );
        _selectedChoice = mpNonMultipleChoiceSetID;
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _uniquePartController = TextEditingController(text: '');
        _surveyPartController = TextEditingController(text: '');
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _uniquePartController = TextEditingController(text: '');
        _surveyPartController = TextEditingController(text: '');
        _selectedChoice = mpUnsetOptionID;
    }

    _initialUniquePart = _uniquePartController.text;
    _initialSurveyPart = _surveyPartController.text;
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
    _uniquePartController.dispose();
    _surveyPartController.dispose();
    _uniquePartTextFieldFocusNode.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _uniquePartTextFieldFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      final String station = _buildStationValue();

      if (station.isNotEmpty) {
        switch (widget.optionInfo.type) {
          case THCommandOptionType.extend:
            newOption = THExtendCommandOption.fromStringWithParentMPID(
              parentMPID: mpParentMPIDPlaceholder,
              station: station,
            );
          case THCommandOptionType.from:
            newOption = THFromCommandOption.fromStringWithParentMPID(
              parentMPID: mpParentMPIDPlaceholder,
              station: station,
            );
          case THCommandOptionType.name:
            newOption = THStationNameCommandOption.fromStringWithParentMPID(
              parentMPID: mpParentMPIDPlaceholder,
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
    switch (_selectedChoice) {
      case mpUnsetOptionID:
        _isValid = true;
        _uniquePartWarningMessage = null;
        _surveyPartWarningMessage = null;
      case mpNonMultipleChoiceSetID:
        final String uniquePart = _uniquePartController.text.trim();
        final String surveyPart = _surveyPartController.text.trim();
        final bool isUniquePartValid =
            uniquePart.isNotEmpty && MPElementEditAux.isExtKeyword(uniquePart);
        final bool isSurveyPartValid =
            surveyPart.isEmpty || MPElementEditAux.isKeyword(surveyPart);

        _uniquePartWarningMessage = _getUniquePartWarningMessage(
          uniquePart: uniquePart,
          isUniquePartValid: isUniquePartValid,
        );
        _surveyPartWarningMessage = isSurveyPartValid
            ? null
            : appLocalizations.mpStationTypeSurveyInvalidWarning;
        _isValid = isUniquePartValid && isSurveyPartValid;
      default:
        _isValid = false;
        _uniquePartWarningMessage = null;
        _surveyPartWarningMessage = null;
    }

    _updateIsOkButtonEnabled();
  }

  void _updateIsOkButtonEnabled() {
    final bool isChanged =
        ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            ((_uniquePartController.text != _initialUniquePart) ||
                (_surveyPartController.text != _initialSurveyPart))));

    setState(() {
      _isOkButtonEnabled = _isValid && isChanged;
    });
  }

  String _getStationValue(THCommandOption currentOption) {
    switch (currentOption) {
      case THExtendCommandOption _:
        return currentOption.station;
      case THFromCommandOption _:
        return currentOption.station;
      case THStationNameCommandOption _:
        return currentOption.reference;
      default:
        throw Exception(
          'Unsupported option type: ${widget.optionInfo..type} in _MPStationTypeOptionWidgetState._getStationValue()',
        );
    }
  }

  ({String uniquePart, String surveyPart}) _splitStationParts(String station) {
    final int separatorIndex = station.indexOf('@');

    if (separatorIndex == -1) {
      return (uniquePart: station.trim(), surveyPart: '');
    }

    final String uniquePart = station.substring(0, separatorIndex).trim();
    final String surveyPart = station.substring(separatorIndex + 1).trim();

    return (uniquePart: uniquePart, surveyPart: surveyPart);
  }

  String _buildStationValue() {
    final String uniquePart = _uniquePartController.text.trim();
    final String surveyPart = _surveyPartController.text.trim();

    if (surveyPart.isEmpty) {
      return uniquePart;
    }

    return '$uniquePart@$surveyPart';
  }

  String? _getUniquePartWarningMessage({
    required String uniquePart,
    required bool isUniquePartValid,
  }) {
    if (uniquePart.isEmpty) {
      return appLocalizations.mpStationTypeUniqueEmptyWarning;
    }

    if (!isUniquePartValid) {
      return appLocalizations.mpStationTypeUniqueInvalidWarning;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String title;

    switch (widget.optionInfo.type) {
      case THCommandOptionType.extend:
        title = appLocalizations.thCommandOptionExtend;
      case THCommandOptionType.from:
        title = appLocalizations.thCommandOptionFrom;
      case THCommandOptionType.name:
        title = appLocalizations.thCommandOptionName;
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
            RadioGroup<String>(
              groupValue: _selectedChoice,
              onChanged: (String? value) {
                setState(() {
                  _selectedChoice = value!;
                  _updateIsValid();
                });
                if (_selectedChoice == mpNonMultipleChoiceSetID) {
                  _uniquePartTextFieldFocusNode.requestFocus();
                }
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    key: ValueKey(
                      "MPStationTypeOptionWidget|RadioListTile|$mpUnsetOptionID",
                    ),
                    title: Text(appLocalizations.mpChoiceUnset),
                    value: mpUnsetOptionID,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    key: ValueKey(
                      "MPStationTypeOptionWidget|RadioListTile|$mpNonMultipleChoiceSetID",
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: MPTextFieldInputWidget(
                      labelText: appLocalizations.mpStationTypeUniqueLabel,
                      controller: _uniquePartController,
                      focusNode: _uniquePartTextFieldFocusNode,
                      autofocus: true,
                      errorText: _uniquePartWarningMessage,
                      keyboardType: TextInputType.text,
                      onChanged: (String value) {
                        _updateIsValid();
                      },
                    ),
                  ),
                  const SizedBox(width: mpButtonSpace),
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('@'),
                  ),
                  const SizedBox(width: mpButtonSpace),
                  Expanded(
                    child: MPTextFieldInputWidget(
                      labelText: appLocalizations.mpStationTypeSurveyLabel,
                      controller: _surveyPartController,
                      errorText: _surveyPartWarningMessage,
                      keyboardType: TextInputType.text,
                      onChanged: (String value) {
                        _updateIsValid();
                      },
                    ),
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
