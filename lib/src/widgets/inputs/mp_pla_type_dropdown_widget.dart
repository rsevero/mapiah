import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';

class MPPLATypeDropdownWidget extends StatefulWidget {
  final String elementType;
  final String initialValue;
  final Function(String, bool) onChanged;
  final TH2FileEditController th2FileEditController;

  const MPPLATypeDropdownWidget({
    super.key,
    required this.elementType,
    this.initialValue = '',
    required this.onChanged,
    required this.th2FileEditController,
  });

  @override
  State<MPPLATypeDropdownWidget> createState() =>
      _MPPLATypeDropdownWidgetState();
}

class _MPPLATypeDropdownWidgetState extends State<MPPLATypeDropdownWidget> {
  String _selectedPLAType = '';

  @override
  void initState() {
    super.initState();

    _selectedPLAType = widget.initialValue;
  }

  Map<String, String> _getPLATypes() {
    final TH2FileEditElementEditController elementEditController =
        widget.th2FileEditController.elementEditController;

    switch (widget.elementType) {
      case 'point':
        return MPTextToUser.getOrderedChoicesMap(
          MPTextToUser.getPointTypeChoices(
            elementEditController: elementEditController,
          ),
        );
      case 'line':
        return MPTextToUser.getOrderedChoicesMap(
          MPTextToUser.getLineTypeChoices(
            elementEditController: elementEditController,
          ),
        );
      case 'area':
        return MPTextToUser.getOrderedChoicesMap(
          MPTextToUser.getAreaTypeChoices(
            elementEditController: elementEditController,
          ),
        );
      default:
        return {};
    }
  }

  void _onOptionChanged(String? value) {
    value ??= '';

    setState(() {
      _selectedPLAType = value!;
    });

    widget.onChanged(value, value.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> plaTypes = _getPLATypes();

    if (plaTypes.isEmpty) {
      return const SizedBox.shrink();
    }
    if (!plaTypes.containsKey(_selectedPLAType)) {
      _selectedPLAType = '';
      widget.onChanged(_selectedPLAType, _selectedPLAType.isNotEmpty);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: mpButtonSpace),
        DropdownMenu<String>(
          key: ValueKey(widget.elementType),
          initialSelection: _selectedPLAType,
          dropdownMenuEntries: plaTypes.entries
              .map(
                (entry) => DropdownMenuEntry<String>(
                  value: entry.key,
                  label: entry.value,
                ),
              )
              .toList(),
          onSelected: _onOptionChanged,
          label: Text(
            mpLocator.appLocalizations.mpPLATypeDropdownSelectATypeLabel,
          ),
        ),
      ],
    );
  }
}
