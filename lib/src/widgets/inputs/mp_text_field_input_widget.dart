import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

class MPTextFieldInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final String labelText;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const MPTextFieldInputWidget({
    super.key,
    required this.labelText,
    required this.controller,
    this.errorText,
    this.hintText,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.autofocus = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double altitudeFieldWidth = max(
      MPInteractionAux.calculateTextFieldWidth(
        MPInteractionAux.insideRange(
          value: controller.text.toString().length,
          min: mpDefaultMinDigitsForTextFields,
          max: mpDefaultMaxCharsForTextFields,
        ),
      ),
      MPInteractionAux.calculateWarningMessageWidth(
        errorText == null ? 0 : errorText!.length,
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: ((errorText == null) || errorText!.isEmpty) ? 0 : 16,
      ),
      child: SizedBox(
        width: altitudeFieldWidth,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
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
