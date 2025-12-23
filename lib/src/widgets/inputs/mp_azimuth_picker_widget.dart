import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
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

  double _calculateAngle({required Offset center, required Offset position}) {
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
            _updateAzimuthOnTap(details.globalPosition, compassSize);
          },
          onTapDown: (details) {
            _updateAzimuthOnTap(details.globalPosition, compassSize);
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

class _CompassPainter extends CustomPainter {
  final double azimuth;
  final double markerSize;

  _CompassPainter({required this.azimuth, required this.markerSize});

  @override
  void paint(Canvas canvas, Size size) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final Offset center = Offset(size.width, size.height) / 2;
    final double radius = size.width / 2;

    // Draw compass circle
    final Paint circlePaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, circlePaint);

    // Draw border
    final Paint borderPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, borderPaint);

    // Draw background lines
    _drawBackgroundLines(canvas, center, radius);

    // Draw cardinal directions
    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final List<String> directions = [
      appLocalizations.mpAzimuthNorthAbbreviation,
      appLocalizations.mpAzimuthEastAbbreviation,
      appLocalizations.mpAzimuthSouthAbbreviation,
      appLocalizations.mpAzimuthWestAbbreviation,
    ];

    const List<double> rightAngles = [0.0, 90.0, 180.0, 270.0];

    for (int i = 0; i < directions.length; i++) {
      final double angleRad = rightAngles[i] * math.pi / 180;
      final Offset textOffset = Offset(
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
    final Paint arrowBodyPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final double arrowLength = radius * 0.6;
    final Offset arrowTipBase = Offset(0, -arrowLength * 0.9);

    canvas.drawLine(Offset.zero, arrowTipBase, arrowBodyPaint);

    // Draw the arrowhead
    final Paint arrowPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final Offset arrowTip = Offset(0, -arrowLength);
    final double arrowSide = markerSize * 0.4;
    final double arrowBaseLength = -arrowLength * 0.78;
    final Offset arrowSide1 = Offset(-arrowSide, arrowBaseLength);
    final Offset arrowSide2 = Offset(arrowSide, arrowBaseLength);

    final Path path = Path();

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
    final Paint rightAnglePaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final Paint fortyFiveDegreePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    /// radius90 is smaller than radius45 to make right angle lines longer so
    /// there is space to write the cardinal direction letters.
    final double radius90 = radius * 0.68;
    final double radius45 = radius * 0.87;

    for (int i = 0; i < 4; i++) {
      final double angleRad90 = i * math.pi / 2;
      final double angleRad45 = angleRad90 + (math.pi / 4);

      // Draw right angle lines (0°, 90°, 180°, 270°)
      final Offset lineEnd90 = Offset(
        center.dx + math.cos(angleRad90) * radius90,
        center.dy + math.sin(angleRad90) * radius90,
      );

      canvas.drawLine(center, lineEnd90, rightAnglePaint);

      // Draw 45° lines (45°, 135°, 225°, 315°)
      final Offset lineEnd45 = Offset(
        center.dx + math.cos(angleRad45) * radius45,
        center.dy + math.sin(angleRad45) * radius45,
      );

      canvas.drawLine(center, lineEnd45, fortyFiveDegreePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return azimuth != (oldDelegate as _CompassPainter).azimuth ||
        markerSize != oldDelegate.markerSize;
  }
}
