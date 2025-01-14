import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';

class THLineWidget extends CustomPaint {
  final THLine line;
  final Paint linePaint;
  final THFileDisplayStore thFileDisplayStore;
  final Size screenSize;

  THLineWidget({
    required this.line,
    required this.linePaint,
    required this.thFileDisplayStore,
    required this.screenSize,
  }) : super(
          painter: THLinePainter(
            line: line,
            linePaint: linePaint,
            thFileDisplayStore: thFileDisplayStore,
          ),
          size: screenSize,
        );
}
