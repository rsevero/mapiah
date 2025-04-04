import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

class MPDateIntervalInputWidget extends StatefulWidget {
  final String? initialValue;
  final Function(String, bool)? onChanged;

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
  String _startDateWarningMessage = '';
  String _endDateWarningMessage = '';

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
    } else if (initialValue == '-') {
      _startDateController.text = '-';
      _endDateController.text = '';
      _isInterval = false;
    } else {
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
    }

    _validateStartDate();
    _validateEndDate();
  }

  void _validateStartDate() {
    // Allow a single '-' or a valid date format
    final RegExp startDatePattern = RegExp(
      r'^-$|^(\d{4}(\.\d{2}(\.\d{2}(@\d{2}(:\d{2}(:\d{2}(\.\d{1,3})?)?)?)?)?)?)$',
    );

    _isStartDateValid = startDatePattern.hasMatch(_startDateController.text);
    setState(
      () {
        _startDateWarningMessage = _isStartDateValid
            ? ''
            : mpLocator.appLocalizations
                .mpDateIntervalInvalidStartDateFormatErrorMessage;
      },
    );
  }

  void _validateEndDate() {
    // Only allow a valid date format (no '-')
    final RegExp endDatePattern = RegExp(
      r'^(\d{4}(\.\d{2}(\.\d{2}(@\d{2}(:\d{2}(:\d{2}(\.\d{1,3})?)?)?)?)?)?)$',
    );

    _isEndDateValid = endDatePattern.hasMatch(_endDateController.text);
    setState(
      () {
        _endDateWarningMessage = _isEndDateValid
            ? ''
            : mpLocator.appLocalizations
                .mpDateIntervalInvalidEndDateFormatErrorMessage;
      },
    );
  }

  void _onFieldChanged() {
    final String result;

    if (_isInterval) {
      result =
          '${_startDateController.text} - ${_isEndDateValid ? _endDateController.text : ''}';
    } else {
      result = _startDateController.text;
    }

    final bool isValid = _isStartDateValid && (!_isInterval || _isEndDateValid);

    if (widget.onChanged != null) {
      widget.onChanged!(result, isValid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double startDateFieldWidth = max(
      MPInteractionAux.calculateTextFieldWidth(
        MPInteractionAux.insideRange(
          value: _startDateController.text.toString().length,
          min: mpDefaultMinDigitsForTextFields,
          max: mpDefaultMaxCharsForTextFields,
        ),
      ),
      MPInteractionAux.calculateWarningMessageWidth(
        _startDateWarningMessage.length,
      ),
    );
    final double endDateFieldWidth = max(
      MPInteractionAux.calculateTextFieldWidth(
        MPInteractionAux.insideRange(
          value: _endDateController.text.toString().length,
          min: mpDefaultMinDigitsForTextFields,
          max: mpDefaultMaxCharsForTextFields,
        ),
      ),
      MPInteractionAux.calculateWarningMessageWidth(
        _endDateWarningMessage.length,
      ),
    );

    return Card(
      elevation: mpOverlayWindowBlockElevation,
      color: Theme.of(context).colorScheme.secondaryFixedDim,
      child: Padding(
        padding: const EdgeInsets.all(mpOverlayWindowBlockPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(mpLocator.appLocalizations.mpDateIntervalIntervalLabel),
                Switch(
                  value: _isInterval,
                  onChanged: (value) {
                    setState(
                      () {
                        _isInterval = value;
                      },
                    );
                    _onFieldChanged();
                  },
                ),
              ],
            ),
            const SizedBox(height: mpButtonSpace),

            // Start Date Input
            Padding(
              padding: EdgeInsets.only(
                bottom: (_startDateWarningMessage.isEmpty) ? 0 : 16,
              ),
              child: SizedBox(
                width: startDateFieldWidth,
                child: TextField(
                  controller: _startDateController,
                  decoration: InputDecoration(
                    labelText: _isInterval
                        ? mpLocator
                            .appLocalizations.mpDateIntervalStartDateLabel
                        : mpLocator
                            .appLocalizations.mpDateIntervalSingleDateLabel,
                    hintText:
                        mpLocator.appLocalizations.mpDateIntervalStartDateHint,
                    border: const OutlineInputBorder(),
                    errorText: _startDateWarningMessage,
                  ),
                  onChanged: (value) {
                    _validateStartDate();
                    _onFieldChanged();
                  },
                ),
              ),
            ),

            // End Date Input (only shown if interval is selected)
            if (_isInterval) ...[
              const SizedBox(height: mpButtonSpace),
              Padding(
                padding: EdgeInsets.only(
                  bottom: (_endDateWarningMessage.isEmpty) ? 0 : 16,
                ),
                child: SizedBox(
                  width: endDateFieldWidth,
                  child: TextField(
                    controller: _endDateController,
                    decoration: InputDecoration(
                      labelText:
                          mpLocator.appLocalizations.mpDateIntervalEndDateLabel,
                      hintText:
                          mpLocator.appLocalizations.mpDateIntervalEndDateHint,
                      border: const OutlineInputBorder(),
                      errorText: _endDateWarningMessage,
                    ),
                    onChanged: (value) {
                      _validateEndDate();
                      _onFieldChanged();
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
