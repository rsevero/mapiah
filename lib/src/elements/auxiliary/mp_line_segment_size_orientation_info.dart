import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_file.dart';

class MPLineSegmentSizeOrientationInfo {
  final int mpID;
  final Offset canvasPosition;
  late final double size;
  late final double orientation;

  MPLineSegmentSizeOrientationInfo({
    required this.mpID,
    required this.canvasPosition,
    required double? size,
    required double? orientation,
    required THFile thFile,
  }) {
    this.size = (size == null) ? mpSlopeLinePointDefaultLSize : size;

    if (orientation == null) {
      final Offset tangent = MPNumericAux.segmentTangent(mpID, thFile);
      final Offset normal = MPNumericAux.normalFromTangent(tangent);
      final double azimuth = MPNumericAux.directionOffsetToDegrees(normal);

      this.orientation = azimuth;
    } else {
      this.orientation = orientation;
    }
  }
}
