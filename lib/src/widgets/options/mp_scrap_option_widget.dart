import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class MPScrapOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPScrapOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPScrapOptionWidget> createState() => _MPScrapOptionWidgetState();
}

class _MPScrapOptionWidgetState extends State<MPScrapOptionWidget> {
  String _selectedChoice = '';
  final TextEditingController _freeTextScrapIDController =
      TextEditingController();
  final FocusNode _freeTextScrapIDFocusNode = FocusNode();
  late final String _initialSelectedChoice;
  late final String _initialScrapTHID;
  String? _freeTextScrapIDWarningMessage;
  bool _isOkButtonEnabled = false;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  bool _isValid = false;
  late final List<String> _thisFileScrapIDs;
  late final bool _hasFromFileOption;

  @override
  void initState() {
    super.initState();
    _thisFileScrapIDs = widget.th2FileEditController
        .availableScraps()
        .values
        .toList();
    _hasFromFileOption = _thisFileScrapIDs.length > 1;

    if (widget.optionInfo.state == MPOptionStateType.set) {
      final THScrapCommandOption currentOption =
          widget.optionInfo.option as THScrapCommandOption;

      _freeTextScrapIDController.text = currentOption.reference;
      _selectedChoice = _thisFileScrapIDs.contains(currentOption.reference)
          ? mpScrapFromFileTHID
          : mpScrapFreeTextTHID;
    } else {
      _selectedChoice = mpUnsetOptionID;
      _freeTextScrapIDController.text = '';
    }

    _initialScrapTHID = _freeTextScrapIDController.text;
    _initialSelectedChoice = _selectedChoice;

    _updateIsValid();
  }

  @override
  void dispose() {
    _freeTextScrapIDController.dispose();
    _freeTextScrapIDFocusNode.dispose();
    super.dispose();
  }

  void _updateIsValid() {
    _isValid = _selectedChoice.isNotEmpty;
    _freeTextScrapIDWarningMessage = _isValid
        ? null
        : appLocalizations.mpScrapWarning;

    _updateOkButtonEnabled();
  }

  void _updateOkButtonEnabled() {
    final bool isChanged =
        (_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice != mpUnsetOptionID) &&
            (_initialScrapTHID != _freeTextScrapIDController.text));

    setState(() {
      _isOkButtonEnabled = _isValid && isChanged;
    });
  }

  Widget _buildFormForOption(String option) {
    switch (option) {
      case mpScrapFreeTextTHID:
        return MPTextFieldInputWidget(
          labelText: appLocalizations.mpScrapLabel,
          controller: _freeTextScrapIDController,
          autofocus: true,
          focusNode: _freeTextScrapIDFocusNode,
          errorText: _freeTextScrapIDWarningMessage,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^[A-Za-z0-9_/][A-Za-z0-9_/-]*$'),
            ),
          ],
          onChanged: (value) => _updateIsValid(),
        );
      case mpScrapFromFileTHID:
        return DropdownMenu<String>(
          initialSelection: _freeTextScrapIDController.text,
          dropdownMenuEntries: _thisFileScrapIDs
              .map(
                (scrapID) =>
                    DropdownMenuEntry<String>(value: scrapID, label: scrapID),
              )
              .toList(),
          onSelected: (value) {
            if (value != null) {
              setState(() {
                _freeTextScrapIDController.text = value;
                _updateIsValid();
              });
            }
          },
        );
      default:
        throw Exception(
          'Invalid choice "$option" at MPProjectionOptionWidget._buildFormForOption()',
        );
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice != mpUnsetOptionID) {
      newOption = THScrapCommandOption.forCWJM(
        parentMPID: widget.th2FileEditController.thFileMPID,
        reference: _freeTextScrapIDController.text.trim(),
        originalLineInTH2File: '',
      );
    }

    widget.th2FileEditController.userInteractionController.prepareSetOption(
      option: newOption,
      optionType: widget.optionInfo.type,
    );
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

    Map<String, String> choices = {
      mpScrapFreeTextTHID: appLocalizations.mpScrapFreeText,
    };

    if (_hasFromFileOption) {
      choices[mpScrapFromFileTHID] = appLocalizations.mpScrapFromFile;
    }

    for (final entry in choices.entries) {
      final String value = entry.key;
      final String label = entry.value;

      optionWidgets.add(
        RadioListTile<String>(
          title: Text(label),
          value: value,
          contentPadding: EdgeInsets.zero,
        ),
      );
      if (_selectedChoice == value) {
        optionWidgets.add(_buildFormForOption(_selectedChoice));
      }
    }

    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionScrap,
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
              child: Text(appLocalizations.mpButtonOK),
            ),
            const SizedBox(width: mpButtonSpace),
            ElevatedButton(
              onPressed: () {
                widget.th2FileEditController.overlayWindowController
                    .setShowOverlayWindow(MPWindowType.optionChoices, false);
              },
              child: Text(appLocalizations.mpButtonCancel),
            ),
          ],
        ),
      ],
    );
  }
}
