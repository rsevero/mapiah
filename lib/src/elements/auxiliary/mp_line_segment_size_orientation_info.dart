import 'package:flutter/material.dart';

class MPLineSegmentSizeOrientationInfo {
  final int mpID;
  final Offset canvasPosition;
  final double? size;
  final double? orientation;

  MPLineSegmentSizeOrientationInfo({
    required this.mpID,
    required this.canvasPosition,
    required this.size,
    required this.orientation,
  });
}
