import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';

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
    } else if (widget.allowEmpty) {
      _value = null;
    } else {
      _value = widget.min;
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
    setState(() {
      if (_value == null && !widget.allowEmpty) {
        _value = widget.min;
      } else if (_value != null && _value! < widget.max) {
        _value = _value! + 1;
      }
      _controller.text = _value?.toString() ?? '';
      widget.onChanged.call(_value);
    });
  }

  void _decrement() {
    setState(() {
      if (_value == null && !widget.allowEmpty) {
        _value = widget.min;
      } else if (_value != null && _value! > widget.min) {
        _value = _value! - 1;
      }
      _controller.text = _value?.toString() ?? '';
      widget.onChanged.call(_value);
    });
  }

  void _validateInput(String value) {
    if (widget.allowEmpty && value.isEmpty) {
      setState(() {
        _value = null;
      });
      widget.onChanged.call(null);
      return;
    }

    final int? parsedValue = int.tryParse(value);
    if (parsedValue != null &&
        parsedValue >= widget.min &&
        parsedValue <= widget.max) {
      setState(() {
        _value = parsedValue;
      });
      widget.onChanged.call(parsedValue);
    } else {
      _controller.text = _value?.toString() ?? '';
    }
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
                widget.max.toString().length,
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
