import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/painters/mp_scrap_scale_painter.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';

class MPScrapScaleWidget extends StatelessWidget {
  final TH2FileEditStore th2FileEditStore;

  MPScrapScaleWidget({required super.key, required this.th2FileEditStore});

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Paint linePaint = Paint()
      ..strokeWidth = 1
      ..color = textColor;

    return Observer(
      builder: (_) {
        final double graphicalScaleLengthUnitsLength =
            th2FileEditStore.scrapLengthUnitsOnGraphicalScale;
        final String scaleText =
            "${MPNumericAux.roundNumberForScreen(graphicalScaleLengthUnitsLength)} ${th2FileEditStore.scrapLengthUnitType.name}";

        return CustomPaint(
          painter: MPScrapScalePainter(
            lengthUnits: graphicalScaleLengthUnitsLength,
            scaleText: scaleText,
            lengthUnitsPerScreenPoint:
                th2FileEditStore.scrapLengthUnitsPerPointOnScreen,
            linePaint: linePaint,
            textColor: textColor,
          ),
          size: th2FileEditStore.screenSize,
        );
      },
    );
  }
}
