import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/mp_compass_painter.dart';

class MPAzimuthPickerWidget extends StatefulWidget {
  final double initialAzimuth;
  final ValueChanged<double> onChanged;
  final double size;
  final String azimuthLabel;
  final FocusNode? focusNode;

  const MPAzimuthPickerWidget({
    super.key,
    required this.initialAzimuth,
    required this.onChanged,
    required this.azimuthLabel,
    this.focusNode,
    this.size = 200,
  }) : super();

  @override
  State<MPAzimuthPickerWidget> createState() => _MPAzimuthPickerWidgetState();
}

class _MPAzimuthPickerWidgetState extends State<MPAzimuthPickerWidget> {
  late double _azimuth;
  late TextEditingController _controller;
  final double _markerSize = 20;

  @override
  void initState() {
    super.initState();
    _azimuth = MPNumericAux.normalizeAngle(widget.initialAzimuth);
    _controller = TextEditingController(text: _azimuth.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateAzimuth(double newAzimuth, {bool updateTextField = false}) {
    newAzimuth = MPNumericAux.normalizeAngle(newAzimuth);

    setState(() {
      _azimuth = newAzimuth;
      if (updateTextField) {
        _controller.text = newAzimuth.toStringAsFixed(1);
      }
    });
    widget.onChanged(newAzimuth);
  }

  void _handleTextInput() {
    final String text = _controller.text;

    if (text.isEmpty) {
      return;
    }

    final double? value = double.tryParse(text);

    if (value != null) {
      _updateAzimuth(value);
    } else {
      // Revert to previous value if input is invalid
      _controller.text = _azimuth.toStringAsFixed(1);
    }
  }

  double _calculateAngle({required Offset center, required Offset position}) {
    final Offset delta = position - center;
    // Convert cartesian to polar coordinates (with y inverted)
    final double angle = math.atan2(delta.dx, -delta.dy) * mp1Radian;

    return angle;
  }

  @override
  Widget build(BuildContext context) {
    final double compassBoxSize = widget.size * mpCompassBoxSizeFactor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compass circle with arrow
        GestureDetector(
          onPanUpdate: (details) {
            _updateAzimuthOnTap(details.globalPosition, compassBoxSize);
          },
          onTapDown: (details) {
            _updateAzimuthOnTap(details.globalPosition, compassBoxSize);
          },
          child: SizedBox(
            width: compassBoxSize,
            height: compassBoxSize,
            child: CustomPaint(
              painter: MPCompassPainter(
                azimuth: _azimuth,
                arrowLength: _markerSize,
                drawBackgroundLines: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: mpButtonSpace * 2),
        // Text input field
        SizedBox(
          width: compassBoxSize * 0.6,
          child: TextField(
            controller: _controller,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              suffixText: '°',
              border: OutlineInputBorder(),
              labelText: widget.azimuthLabel,
            ),
            onChanged: (value) {
              // Update the arrow position as the user types
              final double? newAzimuth = double.tryParse(value);

              if (newAzimuth != null) {
                _updateAzimuth(newAzimuth);
              }
            },
            onSubmitted: (_) => _handleTextInput(),
          ),
        ),
      ],
    );
  }

  void _updateAzimuthOnTap(Offset globalPosition, double compassSize) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(globalPosition);
    final double compassRadius = compassSize / 2;
    final double angle = _calculateAngle(
      center: Offset(compassRadius, compassRadius),
      position: localPosition,
    );
    final Set<LogicalKeyboardKey> logicalKeysPressed =
        HardwareKeyboard.instance.logicalKeysPressed;
    final bool isCtrlPressed =
        logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
        logicalKeysPressed.contains(LogicalKeyboardKey.controlRight);
    final double adjustedAngle = isCtrlPressed
        ? (angle / mpAzimuthConstraintAngle).round() * mpAzimuthConstraintAngle
        : angle;

    _updateAzimuth(adjustedAngle, updateTextField: true);
  }
}
