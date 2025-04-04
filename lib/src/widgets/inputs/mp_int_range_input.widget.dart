import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

class MPIntRangeInputWidget extends StatefulWidget {
  final String label;
  final int min;
  final int max;
  final bool allowEmpty;
  final int? initialValue;
  final ValueChanged<int?> onChanged;

  const MPIntRangeInputWidget({
    super.key,
    required this.label,
    required this.min,
    required this.max,
    this.allowEmpty = false,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<MPIntRangeInputWidget> createState() => _MPIntRangeInputWidgetState();
}

class _MPIntRangeInputWidgetState extends State<MPIntRangeInputWidget> {
  int? _value;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null &&
        widget.initialValue! >= widget.min &&
        widget.initialValue! <= widget.max) {
      _value = widget.initialValue;
    } else {
      _value = null;
    }

    _controller = TextEditingController(
      text: _value?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    if ((_value == null) || (_value! < widget.min)) {
      _value = widget.min;
    } else if (_value! < widget.max) {
      _value = _value! + 1;
    }
    _controller.text = _value?.toString() ?? '';

    widget.onChanged.call(_value);
  }

  void _decrement() {
    if ((_value == null) || (_value! > widget.max)) {
      _value = widget.max;
    } else if (_value! > widget.min) {
      _value = _value! - 1;
    }
    _controller.text = _value?.toString() ?? '';

    widget.onChanged.call(_value);
  }

  // bool _isValid(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return widget.allowEmpty;
  //   }

  //   final int? parsedValue = int.tryParse(value);

  //   return parsedValue != null &&
  //       parsedValue >= widget.min &&
  //       parsedValue <= widget.max;
  // }

  void _validateInput(String value) {
    if (value.isEmpty) {
      _value = null;

      widget.onChanged.call(null);
      return;
    }

    _value = int.tryParse(value);

    widget.onChanged.call(_value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: _decrement,
            ),
            SizedBox(
              width: MPInteractionAux.calculateTextFieldWidth(
                MPInteractionAux.insideRange(
                  value: widget.max.toString().length,
                  min: mpDefaultMinDigitsForTextFields,
                  max: mpDefaultMaxCharsForTextFields,
                ),
              ),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: _validateInput,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _increment,
            ),
          ],
        ),
      ],
    );
  }
}
