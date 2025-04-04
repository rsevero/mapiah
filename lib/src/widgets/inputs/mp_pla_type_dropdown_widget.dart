import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

class MPPLATypeDropdownWidget extends StatefulWidget {
  final String elementType;
  final String initialValue;
  final Function(String, bool) onChanged;

  const MPPLATypeDropdownWidget({
    super.key,
    required this.elementType,
    this.initialValue = '',
    required this.onChanged,
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
