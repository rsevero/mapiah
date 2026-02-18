import 'dart:math' as math;
import 'dart:ui' show Offset;
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';

class MPSizeHandleGeometry {
  final Offset centerScreen;
  final Offset leftEndScreen;

  const MPSizeHandleGeometry({
    required this.centerScreen,
    required this.leftEndScreen,
  });
}

class MPLSizeOrientationDragStartState {
  final bool lSizeEnabled;
  final bool orientationEnabled;
  final double originalLSize;
  final double originalOrientation;
  final double initialMouseRadius;
  final double initialMouseAngleInRad;

  const MPLSizeOrientationDragStartState({
    required this.lSizeEnabled,
    required this.orientationEnabled,
    required this.originalLSize,
    required this.originalOrientation,
    required this.initialMouseRadius,
    required this.initialMouseAngleInRad,
  });
}

class MPLSizeOrientationDragUpdateResult {
  final double? orientation;
  final double? lSize;

  const MPLSizeOrientationDragUpdateResult({
    required this.orientation,
    required this.lSize,
  });
}

class MPLSizeOrientationAux {
  static double canvasToScreenX(
    double xCanvas,
    TH2FileEditController th2fileEditController,
  ) => th2fileEditController.scaleCanvasToScreen(xCanvas);

  static double canvasToScreenY(
    double yCanvas,
    TH2FileEditController th2fileEditController,
  ) => -th2fileEditController.scaleCanvasToScreen(yCanvas);

  static MPLSizeOrientationDragStartState startLinePointLSizeOrientationDrag({
    required Offset pointCanvas,
    required Offset mouseScreen,
    required double? initialOrientation,
    required double? initialLSize,
    required TH2FileEditController th2FileEditController,
    required int lineSegmentMPID,
  }) {
    final Offset mouseCanvas = th2FileEditController.offsetScreenToCanvas(
      mouseScreen,
    );
    final double dx = mouseCanvas.dx - pointCanvas.dx;
    final double dy = mouseCanvas.dy - pointCanvas.dy;
    final THCommandOptionType? currentOptionTypeBeingEdited =
        th2FileEditController
            .elementEditController
            .currentOptionTypeBeingEdited;
    final bool lSizeEnabled =
        (currentOptionTypeBeingEdited == THCommandOptionType.lSize) ||
        (initialLSize != null);
    final bool orientationEnabled =
        (currentOptionTypeBeingEdited == THCommandOptionType.orientation) ||
        (initialOrientation != null);

    return MPLSizeOrientationDragStartState(
      orientationEnabled: orientationEnabled,
      lSizeEnabled: lSizeEnabled,
      originalOrientation:
          initialOrientation ??
          MPNumericAux.segmentNormalFromTHFile(
            lineSegmentMPID,
            th2FileEditController.thFile,
          ),
      originalLSize: initialLSize ?? mpSlopeLinePointDefaultLSize,
      initialMouseRadius: initialLSize == null
          ? mpSlopeLinePointDefaultLSize
          : math.sqrt(dx * dx + dy * dy),
      initialMouseAngleInRad: initialOrientation == null
          ? MPNumericAux.segmentNormalFromTHFile(
              lineSegmentMPID,
              th2FileEditController.thFile,
            )
          : math.atan2(dy, dx),
    );
  }

  static MPLSizeOrientationDragUpdateResult
  updateLinePointLSizeOrientationDrag({
    required MPLSizeOrientationDragStartState drag,
    required Offset pointCanvas,
    required Offset mouseScreen,
    required TH2FileEditController th2FileEditController,
  }) {
    final Offset mouseCanvas = th2FileEditController.offsetScreenToCanvas(
      mouseScreen,
    );
    final double dx = mouseCanvas.dx - pointCanvas.dx;
    final double dy = mouseCanvas.dy - pointCanvas.dy;

    double? newLSize;

    if (drag.lSizeEnabled || MPInteractionAux.isAltPressed()) {
      final double currentRadius = math.sqrt(dx * dx + dy * dy);

      double ns = drag.originalLSize - drag.initialMouseRadius + currentRadius;

      if (ns <= 0.0) {
        ns = 0.1;
      }

      newLSize = ns;
    }

    double? newOrientation;

    if (drag.orientationEnabled ||
        MPInteractionAux.isCtrlPressed() ||
        MPInteractionAux.isMetaPressed()) {
      final double currentAngleInRad = math.atan2(dy, dx);

      double rot =
          drag.originalOrientation -
          mp1RadInDegree * (currentAngleInRad - drag.initialMouseAngleInRad);

      rot = MPNumericAux.normalizeAngle(rot);

      newOrientation = rot;
    }

    return MPLSizeOrientationDragUpdateResult(
      orientation: newOrientation,
      lSize: newLSize,
    );
  }

  static MPSizeHandleGeometry computeSizeHandleGeometry({
    required Offset pointCanvas,
    required bool reverse,
    required double? explicitRotationDeg,
    required double defaultRotationDeg,
    required double? leftSize,
    required TH2FileEditController th2fileEditController,
  }) {
    bool rotFromDefault = false;
    double rotDeg;

    if (explicitRotationDeg != null) {
      rotDeg = explicitRotationDeg;
    } else {
      rotDeg = defaultRotationDeg;
      rotFromDefault = true;
    }

    final double rotRad = rotDeg * mp1DegreeInRad;

    final double lsPixels = (leftSize != null)
        ? th2fileEditController.scaleCanvasToScreen(leftSize)
        : 30.0;

    final double ca = math.cos(rotRad);
    final double sa = math.sin(rotRad);

    double yvx = sa * lsPixels;
    double yvy = -ca * lsPixels;

    if (reverse && rotFromDefault) {
      yvx = -yvx;
      yvy = -yvy;
    }

    final double x = canvasToScreenX(pointCanvas.dx, th2fileEditController);
    final double y = canvasToScreenY(pointCanvas.dy, th2fileEditController);

    return MPSizeHandleGeometry(
      centerScreen: Offset(x, y),
      leftEndScreen: Offset(x + yvx, y + yvy),
    );
  }
}
