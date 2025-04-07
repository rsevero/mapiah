import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

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

  double _calculateAngle(Offset center, Offset position) {
    final Offset delta = position - center;
    // Convert cartesian to polar coordinates (with y inverted)
    final double angle = math.atan2(delta.dx, -delta.dy) * 180 / math.pi;

    return angle;
  }

  @override
  Widget build(BuildContext context) {
    final double compassSize = widget.size * 0.8;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compass circle with arrow
        GestureDetector(
          onPanUpdate: (details) {
            final renderBox = context.findRenderObject() as RenderBox;
            final localPosition =
                renderBox.globalToLocal(details.globalPosition);
            final angle = _calculateAngle(
              Offset(compassSize / 2, compassSize / 2),
              localPosition,
            );
            final bool isCtrlPressed = HardwareKeyboard
                    .instance.logicalKeysPressed
                    .contains(LogicalKeyboardKey.controlLeft) ||
                HardwareKeyboard.instance.logicalKeysPressed
                    .contains(LogicalKeyboardKey.controlRight);

            double adjustedAngle = angle;

            if (isCtrlPressed) {
              // Snap to the nearest multiple of 15 degrees
              adjustedAngle = (angle / 15).round() * 15.0;
            }

            _updateAzimuth(adjustedAngle, updateTextField: true);
          },
          onTapDown: (details) {
            final renderBox = context.findRenderObject() as RenderBox;
            final localPosition =
                renderBox.globalToLocal(details.globalPosition);
            final angle = _calculateAngle(
              Offset(compassSize / 2, compassSize / 2),
              localPosition,
            );

            // Check if the Ctrl key is pressed
            final bool isCtrlPressed = HardwareKeyboard
                    .instance.logicalKeysPressed
                    .contains(LogicalKeyboardKey.controlLeft) ||
                HardwareKeyboard.instance.logicalKeysPressed
                    .contains(LogicalKeyboardKey.controlRight);

            double adjustedAngle = angle;

            if (isCtrlPressed) {
              // Snap to the nearest multiple of 15 degrees
              adjustedAngle = (angle / 15).round() * 15.0;
            }

            _updateAzimuth(adjustedAngle, updateTextField: true);
          },
          child: SizedBox(
            width: compassSize,
            height: compassSize,
            child: CustomPaint(
              painter: _CompassPainter(
                azimuth: _azimuth,
                markerSize: _markerSize,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Text input field
        SizedBox(
          width: compassSize * 0.6,
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
}

class _CompassPainter extends CustomPainter {
  final double azimuth;
  final double markerSize;

  _CompassPainter({
    required this.azimuth,
    required this.markerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw compass circle
    final circlePaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw background lines
    _drawBackgroundLines(canvas, center, radius);

    // Draw cardinal directions
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final List<String> directions = [
      appLocalizations.mpAzimuthNorthAbbreviation,
      appLocalizations.mpAzimuthEastAbbreviation,
      appLocalizations.mpAzimuthSouthAbbreviation,
      appLocalizations.mpAzimuthWestAbbreviation,
    ];
    const List<double> angles = [0.0, 90.0, 180.0, 270.0];

    for (int i = 0; i < directions.length; i++) {
      final angleRad = angles[i] * math.pi / 180;
      final textOffset = Offset(
        center.dx + math.sin(angleRad) * radius * 0.83,
        center.dy - math.cos(angleRad) * radius * 0.83,
      );

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: Colors.black,
          fontSize: markerSize * 0.7,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        textOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Save the canvas state
    canvas.save();

    // Translate the canvas to the center of the compass
    canvas.translate(center.dx, center.dy);

    // Rotate the canvas based on the azimuth
    canvas.rotate(azimuth * math.pi / 180);

    // Draw the arrow body
    final arrowBodyPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final double arrowLength = radius * 0.6;

    final arrowTipBase = Offset(0, -arrowLength * 0.9);
    canvas.drawLine(Offset.zero, arrowTipBase, arrowBodyPaint);

    // Draw the arrowhead
    final arrowPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final arrowTip = Offset(0, -arrowLength);
    final arrowSide1 = Offset(-markerSize * 0.4, -arrowLength * 0.78);
    final arrowSide2 = Offset(markerSize * 0.4, -arrowLength * 0.78);

    final path = Path();
    path.moveTo(arrowTip.dx, arrowTip.dy);
    path.lineTo(arrowSide1.dx, arrowSide1.dy);
    path.lineTo(arrowTipBase.dx, arrowTipBase.dy);
    path.lineTo(arrowSide2.dx, arrowSide2.dy);
    path.close();

    canvas.drawPath(path, arrowPaint);

    // Draw central circle
    canvas.drawCircle(Offset.zero, markerSize * 0.2, arrowPaint);

    // Restore the canvas state
    canvas.restore();
  }

  void _drawBackgroundLines(Canvas canvas, Offset center, double radius) {
    // Paint for the lines
    final rightAnglePaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fortyFiveDegreePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw right angle lines (0°, 90°, 180°, 270°)
    for (int i = 0; i < 4; i++) {
      final angleRad = i * math.pi / 2;
      final lineEnd = Offset(
        center.dx + math.cos(angleRad) * radius * 0.68,
        center.dy + math.sin(angleRad) * radius * 0.68,
      );
      canvas.drawLine(center, lineEnd, rightAnglePaint);
    }

    // Draw 45° lines (45°, 135°, 225°, 315°)
    for (int i = 0; i < 4; i++) {
      final angleRad = (i * math.pi / 2) + (math.pi / 4);
      final lineEnd = Offset(
        center.dx + math.cos(angleRad) * radius * 0.87,
        center.dy + math.sin(angleRad) * radius * 0.87,
      );
      canvas.drawLine(center, lineEnd, fortyFiveDegreePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return azimuth != (oldDelegate as _CompassPainter).azimuth ||
        markerSize != oldDelegate.markerSize;
  }
}
