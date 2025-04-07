import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_pla_type_dropdown_widget.dart';

class MPPLATypeRadioButtonWidget extends StatefulWidget {
  final String? initialValue;
  final String initialPLAType;
  final Function(String, bool) onChanged;
  final Function(String, bool) onChangedPLAType;

  const MPPLATypeRadioButtonWidget({
    super.key,
    this.initialValue,
    this.initialPLAType = '',
    required this.onChanged,
    required this.onChangedPLAType,
  }) : super();

  @override
  State<MPPLATypeRadioButtonWidget> createState() =>
      _MPPLATypeRadioButtonWidgetState();
}

class _MPPLATypeRadioButtonWidgetState
    extends State<MPPLATypeRadioButtonWidget> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialValue ?? THElementType.point.name;
  }

  void _onOptionChanged(String? value) {
    setState(() {
      _selectedOption = value;
    });

    widget.onChanged(value!, true);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final List<Widget> radioButtons = [];
    final Map<THElementType, String> plaTypes = {
      THElementType.point: appLocalizations.thElementPoint,
      THElementType.line: appLocalizations.thElementLine,
      THElementType.area: appLocalizations.thElementArea,
    };

    for (final entry in plaTypes.entries) {
      final THElementType elementType = entry.key;
      final String elementTypeText = elementType.name;
      final String plaTypeText = entry.value;

      radioButtons.add(
        RadioListTile<String>(
          title: Text(plaTypeText),
          value: elementTypeText,
          groupValue: _selectedOption,
          dense: true,
          onChanged: _onOptionChanged,
        ),
      );

      if (elementTypeText == _selectedOption) {
        radioButtons.add(
          MPPLATypeDropdownWidget(
            elementType: elementTypeText,
            initialValue: widget.initialPLAType,
            onChanged: widget.onChangedPLAType,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: radioButtons,
    );
  }
}
