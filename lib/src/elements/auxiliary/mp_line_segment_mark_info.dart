import 'package:flutter/material.dart';

class MPLineSegmentMarkInfo {
  final int mpID;
  final Offset canvasPosition;
  final String mark;

  MPLineSegmentMarkInfo({
    required this.mpID,
    required this.canvasPosition,
    required this.mark,
  });
}
