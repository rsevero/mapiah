// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:flutter/widgets.dart';

typedef MPSymbolGoldenDraw = void Function(Canvas canvas, Offset center);

class MPSymbolGoldenEntry {
  final MPSymbolGoldenDraw draw;

  const MPSymbolGoldenEntry({required this.draw});
}

/// Renders registered symbol examples in fixed-size side-by-side cells.
class MPSymbolGoldenHarness extends StatelessWidget {
  final List<MPSymbolGoldenEntry> entries;
  final double cellSize;

  const MPSymbolGoldenHarness({
    super.key,
    required this.entries,
    this.cellSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(cellSize * entries.length, cellSize),
        painter: _MPSymbolGoldenHarnessPainter(
          entries: entries,
          cellSize: cellSize,
        ),
      ),
    );
  }
}

class _MPSymbolGoldenHarnessPainter extends CustomPainter {
  final List<MPSymbolGoldenEntry> entries;
  final double cellSize;

  const _MPSymbolGoldenHarnessPainter({
    required this.entries,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()..color = const Color(0xFFFFFFFF);
    final Paint separatorPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    for (int index = 0; index < entries.length; index++) {
      final double left = cellSize * index;
      final Offset center = Offset(left + (cellSize / 2), cellSize / 2);

      if (index > 0) {
        canvas.drawLine(
          Offset(left, 0),
          Offset(left, cellSize),
          separatorPaint,
        );
      }

      entries[index].draw(canvas, center);
    }
  }

  @override
  bool shouldRepaint(covariant _MPSymbolGoldenHarnessPainter oldDelegate) {
    return entries != oldDelegate.entries || cellSize != oldDelegate.cellSize;
  }
}
