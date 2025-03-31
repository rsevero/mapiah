import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';

class MPDateIntervalInputWidget extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  const MPDateIntervalInputWidget({
    super.key,
    this.initialValue,
    this.onChanged,
  });

  @override
  State<MPDateIntervalInputWidget> createState() =>
      _MPDateIntervalInputWidgetState();
}

class _MPDateIntervalInputWidgetState extends State<MPDateIntervalInputWidget> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  bool _isInterval = false;
  bool _isStartDateValid = false;
  bool _isEndDateValid = false;

  @override
  void initState() {
    super.initState();
    _initializeFields(widget.initialValue);
  }

  void _initializeFields(String? initialValue) {
    if (initialValue == null || initialValue.isEmpty) {
      _startDateController.text = '';
      _endDateController.text = '';
      _isInterval = false;
      return;
    }

    if (initialValue == '-') {
      _startDateController.text = '-';
      _endDateController.text = '';
      _isInterval = false;
      return;
    }

    final parts = initialValue.split(' - ');
    if (parts.length == 2) {
      // Interval
      _startDateController.text = parts[0];
      _endDateController.text = parts[1];
      _isInterval = true;
    } else {
      // Single date
      _startDateController.text = initialValue;
      _endDateController.text = '';
      _isInterval = false;
    }

    // Validate initial values
    _isStartDateValid = _validateStartDate(_startDateController.text) == null;
    _isEndDateValid = _validateEndDate(_endDateController.text) == null;
  }

  String? _validateStartDate(String value) {
    // Allow a single '-' or a valid date format
    final startDatePattern = RegExp(
      r'^-$|^(\d{4}(\.\d{2}(\.\d{2}(@\d{2}(:\d{2}(:\d{2}(\.\d{1,3})?)?)?)?)?)?)?$',
    );

    if (value.isEmpty || startDatePattern.hasMatch(value)) {
      return null; // Valid input
    }
    return mpLocator
        .appLocalizations.mpDateIntervalInvalidStartDateFormatErrorMessage;
  }

  String? _validateEndDate(String value) {
    // Only allow a valid date format (no '-')
    final endDatePattern = RegExp(
      r'^(\d{4}(\.\d{2}(\.\d{2}(@\d{2}(:\d{2}(:\d{2}(\.\d{1,3})?)?)?)?)?)?)?$',
    );

    if (value.isEmpty || endDatePattern.hasMatch(value)) {
      return null; // Valid input
    }
    return mpLocator
        .appLocalizations.mpDateIntervalInvalidEndDateFormatErrorMessage;
  }

  void _onFieldChanged() {
    String result;
    if (_isInterval) {
      result =
          '${_startDateController.text} - ${_isEndDateValid ? _endDateController.text : ''}';
    } else {
      result = _startDateController.text;
    }

    if (widget.onChanged != null) {
      widget.onChanged!(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle between single date and interval
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(mpLocator.appLocalizations.mpDateIntervalIntervalLabel),
            Switch(
              value: _isInterval,
              onChanged: (value) {
                setState(() {
                  _isInterval = value;
                  _onFieldChanged();
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8.0),

        // Start Date Input
        TextField(
          controller: _startDateController,
          decoration: InputDecoration(
            labelText: _isInterval
                ? mpLocator.appLocalizations.mpDateIntervalStartDateLabel
                : mpLocator.appLocalizations.mpDateIntervalSingleDateLabel,
            hintText: mpLocator.appLocalizations.mpDateIntervalStartDateHint,
            border: OutlineInputBorder(),
            errorText: _isStartDateValid
                ? null
                : _validateStartDate(_startDateController.text),
          ),
          onChanged: (value) {
            setState(() {
              _isStartDateValid = _validateStartDate(value) == null;
            });
            _onFieldChanged();
          },
        ),
        const SizedBox(height: 8.0),

        // End Date Input (only shown if interval is selected)
        if (_isInterval) ...[
          TextField(
            controller: _endDateController,
            decoration: InputDecoration(
              labelText: mpLocator.appLocalizations.mpDateIntervalEndDateLabel,
              hintText: mpLocator.appLocalizations.mpDateIntervalEndDateHint,
              border: OutlineInputBorder(),
              errorText: _isEndDateValid
                  ? null
                  : _validateEndDate(_endDateController.text),
            ),
            onChanged: (value) {
              setState(() {
                _isEndDateValid = _validateEndDate(value) == null;
              });
              _onFieldChanged();
            },
          ),
          const SizedBox(height: 8.0),
        ],
      ],
    );
  }
}
