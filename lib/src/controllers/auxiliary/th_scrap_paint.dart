import 'package:flutter/painting.dart';

class THScrapPaint {
  final Paint border;
  final Paint fill;
  final Paint backgroundFill;

  THScrapPaint({
    required this.border,
    required this.fill,
    required this.backgroundFill,
  });

  THScrapPaint copyWith({Paint? border, Paint? fill, Paint? backgroundFill}) {
    return THScrapPaint(
      border: border ?? this.border,
      fill: fill ?? this.fill,
      backgroundFill: backgroundFill ?? this.backgroundFill,
    );
  }
}
