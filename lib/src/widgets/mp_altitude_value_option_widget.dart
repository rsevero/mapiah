import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/mp_single_column_list_overlay_window_content_widget.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPAltitudeValueOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final THAltitudeValueCommandOption? currentOption;
  final Offset position;
  final MPWidgetPositionType positionType;
  final double maxHeight;

  const MPAltitudeValueOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.currentOption,
    required this.position,
    required this.positionType,
    required this.maxHeight,
  });

  @override
  State<MPAltitudeValueOptionWidget> createState() =>
      _MPAltitudeValueOptionWidgetState();
}

class _MPAltitudeValueOptionWidgetState
    extends State<MPAltitudeValueOptionWidget> {
  late TextEditingController _altitudeController;
  late bool _isFixed;
  late String _selectedUnit;
  late String _selectedChoice;
  final FocusNode _textFieldFocusNode = FocusNode();
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  late final Map<String, String> _unitMap;

  @override
  void initState() {
    super.initState();
    _unitMap = MPTextToUser.getOrderedChoices(
      MPTextToUser.getLengthUnitsChoices(),
    );

    if (widget.currentOption == null) {
      _altitudeController = TextEditingController(text: '0');
      _isFixed = false;
      _selectedChoice = mpUnsetOptionID;
      _selectedUnit = thDefaultLengthUnitAsString;
    } else {
      final THAltitudeValueCommandOption currentOption = widget.currentOption!;

      _altitudeController = TextEditingController(
        text: currentOption.length.toString(),
      );
      _isFixed = currentOption.isFix;
      _selectedChoice = mpNonMultipleChoiceSetID;
      _selectedUnit = currentOption.unit.unit.name;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasExecutedSingleRunOfPostFrameCallback) {
        _hasExecutedSingleRunOfPostFrameCallback = true;
        _executeOnceAfterBuild();
      }
    });
  }

  @override
  void dispose() {
    _altitudeController.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _textFieldFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    switch (_selectedChoice) {
      case mpUnsetOptionID:
        widget.th2FileEditController.userInteractionController
            .prepareUnsetOption(
          THCommandOptionType.altitude,
        );
      case mpNonMultipleChoiceSetID:
        final double? altitude = double.tryParse(_altitudeController.text);

        if (altitude != null) {
          /// The THFileMPID is used only as a placeholder for the actual
          /// parentMPID of the option(s) to be set. THFile isn't even a
          /// THHasOptionsMixin so it can't actually be the parent of an option,
          /// i.e., is has no options at all.
          final THAltitudeValueCommandOption newOption =
              THAltitudeValueCommandOption.fromStringWithParentMPID(
            parentMPID: widget.th2FileEditController.thFileMPID,
            height: _altitudeController.text,
            isFix: _isFixed,
            unit: _selectedUnit,
          );

          widget.th2FileEditController.userInteractionController
              .prepareSetOption(newOption);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
              mpLocator
                  .appLocalizations.mpAltitudeValueInvalidValueErrorMessage,
            )),
          );
          return;
        }
    }
  }

  void _cancelButtonPressed() {
    widget.th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.optionChoices,
      false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return MPOverlayWindowWidget(
      position: widget.position,
      positionType: widget.positionType,
      windowType: MPWindowType.optionChoices,
      th2FileEditController: widget.th2FileEditController,
      child: MPSingleColumnListOverlayWindowContentWidget(
        maxHeight: widget.maxHeight,
        children: [
          Text(
            appLocalizations.thCommandOptionAltitudeValue,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: mpButtonSpace),
          RadioListTile<String>(
            title: Text(appLocalizations.mpChoiceUnset),
            value: mpUnsetOptionID,
            groupValue: _selectedChoice,
            onChanged: (String? value) {
              setState(() {
                _selectedChoice = value!;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),

          const Divider(),

          RadioListTile<String>(
            title: Text(appLocalizations.mpChoiceSet),
            value: mpNonMultipleChoiceSetID,
            groupValue: _selectedChoice,
            onChanged: (String? value) {
              setState(() {
                _selectedChoice = value!;
              });
              _textFieldFocusNode.requestFocus();
            },
            contentPadding: EdgeInsets.zero,
          ),

          // Additional Inputs for "Set" Option
          if (_selectedChoice == mpNonMultipleChoiceSetID) ...[
            const SizedBox(height: mpButtonSpace),
            // Switch for "Fix" Parameter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appLocalizations.thCommandOptionAltitudeFix),
                Transform.scale(
                  scale: mpSwitchScaleFactor,
                  child: Switch(
                    value: _isFixed,
                    onChanged: (bool value) {
                      setState(() {
                        _isFixed = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: mpButtonSpace),
            // Numeric Input for Altitude
            TextField(
              controller: _altitudeController,
              keyboardType: TextInputType.number,
              autofocus: true,
              focusNode: _textFieldFocusNode,
              decoration: InputDecoration(
                labelText: appLocalizations.thCommandOptionAltitudeValue,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: mpButtonSpace),
            DropdownMenu(
              label: Text(appLocalizations.thCommandOptionLengthUnit),
              initialSelection: _selectedUnit,
              menuStyle: MenuStyle(
                  alignment: Alignment(
                -1.0,
                -_unitMap.entries.length.toDouble(),
              )),
              dropdownMenuEntries: _unitMap.entries.map((entry) {
                return DropdownMenuEntry<String>(
                  value: entry.key,
                  label: entry.value,
                );
              }).toList(),
              onSelected: (String? value) {
                setState(() {
                  _selectedUnit = value ?? thDefaultLengthUnitAsString;
                });
              },
              searchCallback: (entries, query) {
                final index =
                    entries.indexWhere((entry) => entry.label == query);

                return index >= 0 ? index : null;
              },
            ),
          ],

          const SizedBox(height: mpButtonMargin),
          Row(
            children: [
              ElevatedButton(
                onPressed: _okButtonPressed,
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
      ),
    );
  }
}
