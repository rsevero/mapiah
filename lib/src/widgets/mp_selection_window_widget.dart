import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/painters/mp_selection_window_painter.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';

class MPSelectionWindowWidget extends StatelessWidget {
  final TH2FileEditStore th2FileEditStore;
  final int thFileMapiahID;

  MPSelectionWindowWidget({
    required this.th2FileEditStore,
    required super.key,
  }) : thFileMapiahID = th2FileEditStore.thFileMapiahID;

  @override
  Widget build(Object context) {
    if (th2FileEditStore.selectionWindowCanvasCoordinates.value.isEmpty) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Observer(
        builder: (_) => CustomPaint(
          painter: MPSelectionWindowPainter(
            th2FileEditStore: th2FileEditStore,
            selectionWindowPosition:
                th2FileEditStore.selectionWindowCanvasCoordinates.value,
            fillPaint: th2FileEditStore.selectionWindowFillPaint.value,
            borderPaint:
                th2FileEditStore.selectionWindowBorderPaintComplete.value,
            dashInterval: th2FileEditStore
                .selectionWindowBorderPaintDashIntervalOnCanvas.value,
          ),
        ),
      ),
    );
  }
}
