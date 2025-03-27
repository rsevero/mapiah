import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/mp_single_column_list_overlay_window_content_widget.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPAltitudeValueOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final THAltitudeCommandOption? currentOption;
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
  bool _isFixed = false;
  late String _selectedUnit;
  late String _selectedChoice;

  @override
  void initState() {
    super.initState();
    if (widget.currentOption == null) {
      _altitudeController = TextEditingController(
        text: '0',
      );
      _selectedChoice = mpUnsetOptionID;
      _selectedUnit = thDefaultLengthUnitAsString;
      _selectedChoice = mpNonMultipleChoiceSetID;
    } else {
      final THAltitudeCommandOption currentOption = widget.currentOption!;

      _altitudeController = TextEditingController(
        text: currentOption.length.toString(),
      );
      _isFixed = currentOption.isFix;
      _selectedUnit = currentOption.unit.unit.name;
      _selectedChoice = mpNonMultipleChoiceSetID;
    }
  }

  @override
  void dispose() {
    _altitudeController.dispose();
    super.dispose();
  }

  void _applyOption() {
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
          final THAltitudeCommandOption newOption =
              THAltitudeCommandOption.fromStringWithParentMPID(
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
                content: Text('Please enter a valid numeric altitude value.')),
          );
          return;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> unitMap = MPTextToUser.getOptionChoicesWithUnset(
      MPTextToUser.getLengthUnitsChoices(),
    );

    return MPOverlayWindowWidget(
      position: widget.position,
      positionType: widget.positionType,
      overlayWindowType: MPOverlayWindowType.optionChoices,
      th2FileEditController: widget.th2FileEditController,
      child: MPSingleColumnListOverlayWindowContentWidget(
        maxHeight: widget.maxHeight,
        children: [
          Text(
            'Altitude Option',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),

          RadioListTile<String>(
            title: Text('Unset'),
            value: mpUnsetOptionID,
            groupValue: _selectedChoice,
            onChanged: (String? value) {
              setState(() {
                _selectedChoice = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: Text('Set'),
            value: mpNonMultipleChoiceSetID,
            groupValue: _selectedChoice,
            onChanged: (String? value) {
              setState(() {
                _selectedChoice = value!;
              });
            },
          ),

          // Additional Inputs for "Set" Option
          if (_selectedChoice == mpNonMultipleChoiceSetID) ...[
            const SizedBox(height: 8),

            // Numeric Input for Altitude
            TextField(
              controller: _altitudeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Altitude',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            // Checkbox for "Fix" Parameter
            CheckboxListTile(
              title: Text('Fix Altitude'),
              value: _isFixed,
              onChanged: (bool? value) {
                setState(() {
                  _isFixed = value ?? false;
                });
              },
            ),
            const SizedBox(height: 8),

            // Dropdown for Length Unit
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              items: unitMap.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedUnit = value ?? 'meters';
                });
              },
              decoration: InputDecoration(
                labelText: 'Unit',
                border: OutlineInputBorder(),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Apply Button
          ElevatedButton(
            onPressed: _applyOption,
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }
}
