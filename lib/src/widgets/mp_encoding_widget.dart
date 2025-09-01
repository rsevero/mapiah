import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPEncodingWidget extends StatefulWidget {
  final THEncoding? currentEncoding;
  final bool showActionButtons;
  final VoidCallback? onPressedOk;
  final VoidCallback? onPressedCancel;
  final ValueChanged<String?>? onValidOptionChanged;

  const MPEncodingWidget({
    super.key,
    required this.currentEncoding,
    this.showActionButtons = false,
    this.onPressedOk,
    this.onPressedCancel,
    this.onValidOptionChanged,
  });

  @override
  State<MPEncodingWidget> createState() => MPEncodingWidgetState();
}

class MPEncodingWidgetState extends State<MPEncodingWidget> {
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;

  late String _selectedEncoding;
  late String _initialEncoding;
  bool _isOkButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedEncoding = widget.currentEncoding?.encoding ?? mpDefaultEncoding;
    _initialEncoding = _selectedEncoding;
  }

  void _onEncodingChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedEncoding = value;
      _isOkButtonEnabled = _selectedEncoding != _initialEncoding;
    });

    if (widget.onValidOptionChanged != null) {
      widget.onValidOptionChanged!(_selectedEncoding);
    }
  }

  void _internalOkPressed() {
    widget.onPressedOk?.call();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> encodings = mpLocator.mpGeneralController
        .getAvailableEncodings();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownMenu<String>(
          key: const ValueKey('MPEncodingWidget|Dropdown'),
          initialSelection: _selectedEncoding,
          label: Text(appLocalizations.mpEncodingLabel),
          dropdownMenuEntries: encodings
              .map((e) => DropdownMenuEntry<String>(value: e, label: e))
              .toList(),
          onSelected: _onEncodingChanged,
        ),
        if (widget.showActionButtons) ...[
          const SizedBox(height: mpButtonSpace),
          Row(
            children: [
              ElevatedButton(
                onPressed: _isOkButtonEnabled ? _internalOkPressed : null,
                child: Text(appLocalizations.mpButtonOK),
              ),
              const SizedBox(width: mpButtonSpace),
              ElevatedButton(
                onPressed: widget.onPressedCancel,
                child: Text(appLocalizations.mpButtonCancel),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
