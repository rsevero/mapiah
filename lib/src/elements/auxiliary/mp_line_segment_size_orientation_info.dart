import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_file.dart';

class MPLineSegmentSizeOrientationInfo {
  final int mpID;
  final Offset canvasPosition;
  late final double lSize;
  late final double orientation;

  MPLineSegmentSizeOrientationInfo({
    required this.mpID,
    required this.canvasPosition,
    required double? lSize,
    required double? orientation,
    required THFile thFile,
  }) {
    this.lSize = lSize ?? mpSlopeLinePointDefaultLSize;
    this.orientation =
        orientation ?? MPNumericAux.segmentNormalFromTHFile(mpID, thFile);
  }
}
