import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

class MPTextFieldInputWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final String errorText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool autofocus;
  final String labelText;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const MPTextFieldInputWidget({
    super.key,
    required this.textEditingController,
    required this.errorText,
    required this.labelText,
    this.hintText,
    this.focusNode,
    this.keyboardType,
    this.autofocus = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double altitudeFieldWidth = max(
      MPInteractionAux.calculateTextFieldWidth(
        MPInteractionAux.insideRange(
          value: textEditingController.text.toString().length,
          min: mpDefaultMinDigitsForTextFields,
          max: mpDefaultMaxCharsForTextFields,
        ),
      ),
      MPInteractionAux.calculateWarningMessageWidth(
        errorText.length,
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: (errorText.isEmpty) ? 0 : 16,
      ),
      child: SizedBox(
        width: altitudeFieldWidth,
        child: TextField(
          controller: textEditingController,
          keyboardType: keyboardType,
          autofocus: true,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            border: OutlineInputBorder(),
            errorText: errorText,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
