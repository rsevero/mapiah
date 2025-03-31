import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';

class MPPLATypeDropdownWidget extends StatefulWidget {
  final String elementType;
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  const MPPLATypeDropdownWidget({
    super.key,
    required this.elementType,
    this.initialValue,
    this.onChanged,
  });

  @override
  State<MPPLATypeDropdownWidget> createState() =>
      _MPPLATypeDropdownWidgetState();
}

class _MPPLATypeDropdownWidgetState extends State<MPPLATypeDropdownWidget> {
  String? _selectedPLAType;

  @override
  void initState() {
    super.initState();
    _selectedPLAType = widget.initialValue;
  }

  Map<String, String> _getPLATypes() {
    switch (widget.elementType) {
      case 'point':
        return MPTextToUser.getOrderedChoices(
          MPTextToUser.getPointTypeChoices(),
        );
      case 'line':
        return MPTextToUser.getOrderedChoices(
          MPTextToUser.getLineTypeChoices(),
        );
      case 'area':
        return MPTextToUser.getOrderedChoices(
          MPTextToUser.getAreaTypeChoices(),
        );
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> plaTypes = _getPLATypes();

    if (plaTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8.0),
        DropdownMenu<String>(
          initialSelection: _selectedPLAType,
          dropdownMenuEntries: plaTypes.entries
              .map(
                (entry) => DropdownMenuEntry<String>(
                  value: entry.key,
                  label: entry.value,
                ),
              )
              .toList(),
          onSelected: (value) {
            setState(() {
              _selectedPLAType = value;
            });
            if (widget.onChanged != null && value != null) {
              widget.onChanged!(value);
            }
          },
          label: Text(
            mpLocator.appLocalizations.mpPLATypeDropdownSelectATypeLabel,
          ),
        ),
      ],
    );
  }
}
