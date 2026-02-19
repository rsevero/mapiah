import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_user_interaction_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPCompassPainter extends CustomPainter {
  final double azimuth;
  final double arrowLength;
  final TH2FileEditController? th2FileEditController;
  final TH2FileEditUserInteractionController? userInteractionController;
  final Offset canvasOffset;
  final bool isAzimuthPickerMode;

  MPCompassPainter({
    required this.azimuth,
    required this.arrowLength,
    required this.isAzimuthPickerMode,
    this.th2FileEditController,
    this.userInteractionController,
    this.canvasOffset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final Offset center = Offset(size.width, size.height) / 2;
    final double radius = size.width / 2;

    if (isAzimuthPickerMode) {
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

    final double arrowLengthOnScreen = isAzimuthPickerMode
        ? radius * mpCompass90DegreeLineFactor
        : arrowLength;
    final double arrowBodyHalfWidthOnScreen =
        (mpCompassArrowScreenBodyWidth * mpCompassArrowBodyWidthFactor) / 2;
    final double arrowSide =
        mpCompassArrowHeadReferenceLengthOnScreen * mpCompassArrowSideFactor;
    final double arrowSideInsetFromTip =
        mpCompassArrowHeadReferenceLengthOnScreen *
        mpCompassArrowBaseLengthFactor;
    final double arrowTipBaseInsetFromTip =
        mpCompassArrowHeadReferenceLengthOnScreen * mpCompassArrowTipBaseFactor;
    final Offset arrowTip = Offset(0, arrowLengthOnScreen);
    final Offset arrowTipBase = Offset(
      0,
      arrowTip.dy - arrowTipBaseInsetFromTip,
    );
    final Offset arrowSide1 = Offset(
      -arrowSide,
      arrowTip.dy - arrowSideInsetFromTip,
    );
    final Offset arrowSide2 = Offset(
      arrowSide,
      arrowTip.dy - arrowSideInsetFromTip,
    );
    final double azimuthRadians = azimuth * mp1DegreeInRad;
    final double cosAzimuth = math.cos(azimuthRadians);
    final double sinAzimuth = math.sin(azimuthRadians);

    Offset rotateAndTranslate(Offset point) {
      final double rotatedX = (point.dx * cosAzimuth) + (point.dy * sinAzimuth);
      final double rotatedY =
          (-point.dx * sinAzimuth) + (point.dy * cosAzimuth);

      return Offset(rotatedX + center.dx, rotatedY + center.dy);
    }

    final Offset bodyPoint1 = rotateAndTranslate(
      Offset(-arrowBodyHalfWidthOnScreen, 0),
    );
    final Offset bodyPoint2 = rotateAndTranslate(
      Offset(-arrowBodyHalfWidthOnScreen, arrowTipBase.dy),
    );
    final Offset bodyPoint3 = rotateAndTranslate(
      Offset(arrowBodyHalfWidthOnScreen, arrowTipBase.dy),
    );
    final Offset bodyPoint4 = rotateAndTranslate(
      Offset(arrowBodyHalfWidthOnScreen, 0),
    );
    final Offset headPoint1 = rotateAndTranslate(arrowTip);
    final Offset headPoint2 = rotateAndTranslate(arrowSide1);
    final Offset headPoint3 = rotateAndTranslate(arrowSide2);
    final Paint arrowPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    final Path compassPath = Path()
      ..moveTo(bodyPoint2.dx, bodyPoint2.dy)
      ..lineTo(bodyPoint1.dx, bodyPoint1.dy)
      ..lineTo(bodyPoint4.dx, bodyPoint4.dy)
      ..lineTo(bodyPoint3.dx, bodyPoint3.dy)
      ..lineTo(headPoint3.dx, headPoint3.dy)
      ..lineTo(headPoint1.dx, headPoint1.dy)
      ..lineTo(headPoint2.dx, headPoint2.dy)
      ..close();

    canvas.drawPath(compassPath, arrowPaint);

    userInteractionController?.setCompassPath(compassPath.shift(canvasOffset));
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
