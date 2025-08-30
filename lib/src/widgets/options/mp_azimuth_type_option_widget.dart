import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_azimuth_picker_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPAzimuthTypeOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPAzimuthTypeOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPAzimuthTypeOptionWidget> createState() =>
      _MPAzimuthTypeOptionWidgetState();
}

class _MPAzimuthTypeOptionWidgetState extends State<MPAzimuthTypeOptionWidget> {
  late TextEditingController _azimuthController;
  late String _selectedChoice;
  final FocusNode _azimuthTextFieldFocusNode = FocusNode();
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  double? _currentAzimuth = 0;
  late final String _initialAzimuth;
  late final String _initialSelectedChoice;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  bool _isOkButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THCommandOption currentOption = widget.optionInfo.option!;

        switch (currentOption) {
          case THOrientationCommandOption _:
            _azimuthController = TextEditingController(
              text: currentOption.azimuth.value.toString(),
            );
            _selectedChoice = mpNonMultipleChoiceSetID;
          default:
            throw Exception(
              'Unsupported option type: ${widget.optionInfo.type} in _MPAzimuthTypeOptionWidgetState.initState()',
            );
        }
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _azimuthController = TextEditingController(text: '0');
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _azimuthController = TextEditingController(text: '0');
        _selectedChoice = mpUnsetOptionID;
    }
    _initialAzimuth = _azimuthController.text;
    _currentAzimuth = double.tryParse(_initialAzimuth);
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
    _azimuthController.dispose();
    _azimuthTextFieldFocusNode.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _azimuthTextFieldFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      if (_currentAzimuth != null) {
        /// The THFileMPID is used only as a placeholder for the actual
        /// parentMPID of the option(s) to be set. THFile isn't even a
        /// THHasOptionsMixin so it can't actually be the parent of an option,
        /// i.e., is has no options at all.
        switch (widget.optionInfo.type) {
          case THCommandOptionType.orientation:
            newOption = THOrientationCommandOption.forCWJM(
              parentMPID: widget.th2FileEditController.thFileMPID,
              originalLineInTH2File: '',
              azimuth: THDoublePart(
                value: _currentAzimuth!,
                decimalPositions: mpDefaultDecimalPositionsAzimuth,
              ),
            );
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(appLocalizations.mpAzimuthInvalidErrorMessage),
              ),
            );
            return;
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

  void _updateOkButtonEnabled() {
    final String azimuthText = _azimuthController.text.trim();
    final bool isValidAzimuth = (_currentAzimuth != null);
    final bool isChanged =
        ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            (azimuthText != _initialAzimuth)));

    setState(() {
      _isOkButtonEnabled = isValidAzimuth && isChanged;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title;
    final String azimuthLabel;

    switch (widget.optionInfo.type) {
      case THCommandOptionType.orientation:
        title = appLocalizations.thCommandOptionOrientation;
        azimuthLabel = appLocalizations.mpAzimuthAzimuthLabel;
      default:
        throw Exception(
          'Unsupported option type: ${widget.optionInfo.type} in _MPAzimuthTypeOptionWidgetState.build()',
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
            RadioGroup(
              groupValue: _selectedChoice,
              onChanged: (String? value) {
                if (value != null) {
                  _selectedChoice = value;
                }
                _updateOkButtonEnabled();
                if (_selectedChoice == mpNonMultipleChoiceSetID) {
                  _azimuthTextFieldFocusNode.requestFocus();
                }
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    key: ValueKey(
                      "MPAzimuthTypeOptionWidget|RadioListTile|$mpUnsetOptionID",
                    ),
                    title: Text(appLocalizations.mpChoiceUnset),
                    value: mpUnsetOptionID,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    key: ValueKey(
                      "MPAzimuthTypeOptionWidget|RadioListTile|$mpNonMultipleChoiceSetID",
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
                  MPAzimuthPickerWidget(
                    initialAzimuth: double.tryParse(_initialAzimuth) ?? 0.0,
                    azimuthLabel: azimuthLabel,
                    focusNode: _azimuthTextFieldFocusNode,
                    onChanged: (lengthLabel) {
                      _currentAzimuth = lengthLabel;
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
