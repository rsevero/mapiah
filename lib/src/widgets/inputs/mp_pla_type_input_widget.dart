import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPPLATypeRadioButtonWidget extends StatefulWidget {
  final String? initialValue;
  final Function(String, bool) onChanged;

  const MPPLATypeRadioButtonWidget({
    super.key,
    this.initialValue,
    required this.onChanged,
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

  Widget _buildRadioListTile(String title, String value) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: _selectedOption,
      dense: true,
      onChanged: _onOptionChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioListTile(
          appLocalizations.thElementPoint,
          THElementType.point.name,
        ),
        _buildRadioListTile(
          appLocalizations.thElementLine,
          THElementType.line.name,
        ),
        _buildRadioListTile(
          appLocalizations.thElementArea,
          THElementType.area.name,
        ),
      ],
    );
  }
}
