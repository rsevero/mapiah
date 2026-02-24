import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

class MPPainterAux {
  static Path buildCompassPath({
    required Offset center,
    required double azimuth,
    required double arrowLength,
  }) {
    final double arrowBodyHalfWidth =
        (mpCompassArrowScreenBodyWidth * mpCompassArrowBodyWidthFactor) / 2;
    final double arrowSide =
        mpCompassArrowHeadReferenceLengthOnScreen * mpCompassArrowSideFactor;
    final double arrowSideInsetFromTip =
        mpCompassArrowHeadReferenceLengthOnScreen *
        mpCompassArrowBaseLengthFactor;
    final double arrowTipBaseInsetFromTip =
        mpCompassArrowHeadReferenceLengthOnScreen * mpCompassArrowTipBaseFactor;
    final Offset arrowTip = Offset(0, arrowLength);
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
      Offset(-arrowBodyHalfWidth, 0),
    );
    final Offset bodyPoint2 = rotateAndTranslate(
      Offset(-arrowBodyHalfWidth, arrowTipBase.dy),
    );
    final Offset bodyPoint3 = rotateAndTranslate(
      Offset(arrowBodyHalfWidth, arrowTipBase.dy),
    );
    final Offset bodyPoint4 = rotateAndTranslate(Offset(arrowBodyHalfWidth, 0));
    final Offset headPoint1 = rotateAndTranslate(arrowTip);
    final Offset headPoint2 = rotateAndTranslate(arrowSide1);
    final Offset headPoint3 = rotateAndTranslate(arrowSide2);

    return Path()
      ..moveTo(bodyPoint2.dx, bodyPoint2.dy)
      ..lineTo(bodyPoint1.dx, bodyPoint1.dy)
      ..lineTo(bodyPoint4.dx, bodyPoint4.dy)
      ..lineTo(bodyPoint3.dx, bodyPoint3.dy)
      ..lineTo(headPoint3.dx, headPoint3.dy)
      ..lineTo(headPoint1.dx, headPoint1.dy)
      ..lineTo(headPoint2.dx, headPoint2.dy)
      ..close();
  }
}
