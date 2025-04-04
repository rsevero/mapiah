import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

class MPPersonNameInputWidget extends StatefulWidget {
  final String? initialValue;
  final Function(String, bool)? onChanged;

  const MPPersonNameInputWidget({
    super.key,
    this.initialValue,
    this.onChanged,
  }) : super();

  @override
  State<MPPersonNameInputWidget> createState() =>
      _MPPersonNameInputWidgetState();
}

class _MPPersonNameInputWidgetState extends State<MPPersonNameInputWidget> {
  late TextEditingController _nameController;
  final FocusNode _nameFocusNode = FocusNode();
  String _warningMessage = '';
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialValue ?? '');
    _validateName();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _validateName() {
    final RegExp namePattern = RegExp(
      r'^([^\s/]+(\s+[^\s/]+)+|[^\s/]+(/[^\s/]+)+)$',
    );

    _isValid = namePattern.hasMatch(_nameController.text);
    setState(
      () {
        _warningMessage = _isValid
            ? ''
            : mpLocator.appLocalizations.mpPersonNameInvalidFormatErrorMessage;
      },
    );
  }

  void _onNameChanged() {
    _validateName();
    if (widget.onChanged != null) {
      widget.onChanged!(_nameController.text, _isValid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double nameFieldWidth = max(
      MPInteractionAux.calculateTextFieldWidth(
        MPInteractionAux.insideRange(
          value: _nameController.text.toString().length,
          min: mpDefaultMinDigitsForTextFields,
          max: mpDefaultMaxCharsForTextFields,
        ),
      ),
      MPInteractionAux.calculateWarningMessageWidth(
        _warningMessage.length,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: mpButtonSpace),
        SizedBox(
          width: nameFieldWidth,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: (_warningMessage.isEmpty) ? 0 : 16,
            ),
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: InputDecoration(
                labelText: mpLocator.appLocalizations.mpPersonNameLabel,
                hintText: mpLocator.appLocalizations.mpPersonNameHint,
                border: OutlineInputBorder(),
                errorText: _warningMessage,
              ),
              onChanged: (value) {
                _onNameChanged();
              },
            ),
          ),
        ),
      ],
    );
  }
}
