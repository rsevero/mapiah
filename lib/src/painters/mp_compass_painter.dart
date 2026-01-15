import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPCompassPainter extends CustomPainter {
  final double azimuth;
  final double arrowLength;
  final bool drawBackgroundLines;
  final TH2FileEditController? th2FileEditController;

  MPCompassPainter({
    required this.azimuth,
    required this.arrowLength,
    required this.drawBackgroundLines,
    this.th2FileEditController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final Offset center = Offset(size.width, size.height) / 2;
    final double radius = size.width / 2;

    if (drawBackgroundLines) {
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
        final double angleRad = rightAngles[i] * mp1DegreeInRad;
        final Offset textOffset = Offset(
          center.dx +
              math.sin(angleRad) *
                  radius *
                  mpCompassCardinalDirectionsTextOffsetFactor,
          center.dy -
              math.cos(angleRad) *
                  radius *
                  mpCompassCardinalDirectionsTextOffsetFactor,
        );

        textPainter.text = TextSpan(
          text: directions[i],
          style: TextStyle(
            color: Colors.black,
            fontSize: size.width * mpCompassCardinalDirectionsFontSizeFactor,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          textOffset - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }

    // Save the canvas state
    canvas.save();

    // Translate the canvas to the center of the compass
    canvas.translate(center.dx, center.dy);

    // When painting in normal widget coordinates (Y down), flip the local
    // coordinate system so the arrow math below always runs in a Y-up space.
    // In the map canvas, the Y-up flip is already applied by
    // TH2FileEditController.transformCanvas().
    if (th2FileEditController == null) {
      canvas.scale(1, -1);
    }

    // Rotate the canvas based on the azimuth
    // In a Y-up space, positive rotation is counter-clockwise; azimuth is
    // defined clockwise, so negate it.
    canvas.rotate(-azimuth * mp1DegreeInRad);

    final double arrowLengthOnScreen = (th2FileEditController == null)
        ? arrowLength * mpCompassArrowFixedLengthScreenFactor
        : th2FileEditController!.scaleCanvasToScreen(
            arrowLength * mpCompassArrowVariableLengthScreenFactor,
          );
    final Offset arrowTipBase = Offset(
      0,
      arrowLengthOnScreen * mpCompassArrowTipBaseFactor,
    );
    final double arrowBodyWidthOnScreen =
        mpCompassArrowScreenBodyWidth * mpCompassArrowBodyWidthFactor;
    final Paint arrowBodyPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = arrowBodyWidthOnScreen;
    canvas.drawLine(Offset.zero, arrowTipBase, arrowBodyPaint);

    // Draw the arrowhead
    final Paint arrowPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    final Offset arrowTip = Offset(0, arrowLengthOnScreen);
    final double arrowSide = arrowLengthOnScreen * mpCompassArrowSideFactor;
    final double arrowBaseLength =
        arrowLengthOnScreen * mpCompassArrowBaseLengthFactor;
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
    canvas.drawCircle(
      Offset.zero,
      arrowLength * mpCompassCentralCircleFactor,
      arrowPaint,
    );

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
    final double radius90 = radius * mpCompass90DegreeLineFactor;
    final double radius45 = radius * mpCompass45DegreeLineFactor;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Draw 8 spokes, rotating progressively by 45°:
    // 0°, 45°, 90°, 135°, 180°, 225°, 270°, 315°.
    for (int i = 0; i < 8; i++) {
      final bool isRightAngle = i.isEven;

      if (isRightAngle) {
        canvas.drawLine(Offset.zero, Offset(radius90, 0), rightAnglePaint);
      } else {
        canvas.drawLine(Offset.zero, Offset(radius45, 0), fortyFiveDegreePaint);
      }

      canvas.rotate(mp45DegreesInRad);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
