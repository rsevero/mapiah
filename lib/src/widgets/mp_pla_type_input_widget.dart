import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPPLATypeRadioButtonWidget extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  const MPPLATypeRadioButtonWidget({
    super.key,
    this.initialValue,
    this.onChanged,
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
    if (widget.onChanged != null && value != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<String>(
          title: Text(appLocalizations.thElementPoint),
          value: THElementType.point.name,
          groupValue: _selectedOption,
          onChanged: _onOptionChanged,
        ),
        RadioListTile<String>(
          title: Text(appLocalizations.thElementLine),
          value: THElementType.line.name,
          groupValue: _selectedOption,
          onChanged: _onOptionChanged,
        ),
        RadioListTile<String>(
          title: Text(appLocalizations.thElementArea),
          value: THElementType.area.name,
          groupValue: _selectedOption,
          onChanged: _onOptionChanged,
        ),
      ],
    );
  }
}
