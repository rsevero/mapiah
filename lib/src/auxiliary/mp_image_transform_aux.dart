// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';

enum MPImageTransformHandleType {
  bottomCenter,
  bottomLeft,
  bottomRight,
  centerLeft,
  centerRight,
  topCenter,
  topLeft,
  topRight,
}

extension MPImageTransformHandleTypeExtension on MPImageTransformHandleType {
  bool get affectsX {
    return !mpImageTransformHandleTypesWithoutXScaling.contains(name);
  }

  bool get affectsY {
    return !mpImageTransformHandleTypesWithoutYScaling.contains(name);
  }
}

class MPImageTransformGeometry {
  final Rect localBounds;
  final Map<MPImageTransformHandleType, Offset> canvasHandleCenters;
  final Map<MPImageTransformHandleType, Offset> screenHandleCenters;
  final Map<MPImageTransformHandleType, Rect> screenHandleRects;
  final Map<MPImageTransformHandleType, Path> screenHandlePaths;
  final List<Offset> canvasBorderCorners;
  final List<Offset> screenBorderCorners;

  const MPImageTransformGeometry({
    required this.localBounds,
    required this.canvasHandleCenters,
    required this.screenHandleCenters,
    required this.screenHandleRects,
    required this.screenHandlePaths,
    required this.canvasBorderCorners,
    required this.screenBorderCorners,
  });

  Offset handleLocalPoint(MPImageTransformHandleType handleType) {
    switch (handleType) {
      case MPImageTransformHandleType.topLeft:
        return localBounds.topLeft;
      case MPImageTransformHandleType.topCenter:
        return localBounds.topCenter;
      case MPImageTransformHandleType.topRight:
        return localBounds.topRight;
      case MPImageTransformHandleType.centerLeft:
        return localBounds.centerLeft;
      case MPImageTransformHandleType.centerRight:
        return localBounds.centerRight;
      case MPImageTransformHandleType.bottomLeft:
        return localBounds.bottomLeft;
      case MPImageTransformHandleType.bottomCenter:
        return localBounds.bottomCenter;
      case MPImageTransformHandleType.bottomRight:
        return localBounds.bottomRight;
    }
  }

  MPImageTransformHandleType? hitTestHandle(Offset screenPosition) {
    for (final MapEntry<MPImageTransformHandleType, Rect> entry
        in screenHandleRects.entries) {
      if (entry.value.contains(screenPosition)) {
        return entry.key;
      }
    }

    return null;
  }

  bool containsCanvasPosition(Offset canvasPosition) {
    final Path borderPath = Path()
      ..moveTo(canvasBorderCorners[0].dx, canvasBorderCorners[0].dy)
      ..lineTo(canvasBorderCorners[1].dx, canvasBorderCorners[1].dy)
      ..lineTo(canvasBorderCorners[2].dx, canvasBorderCorners[2].dy)
      ..lineTo(canvasBorderCorners[3].dx, canvasBorderCorners[3].dy)
      ..close();

    return borderPath.contains(canvasPosition);
  }

  static MPImageTransformGeometry? forImage({
    required TH2FileEditController th2FileEditController,
    required MPRuntimeImageInsertConfigMixin image,
  }) {
    final Rect? localBounds = image.getLocalBounds(th2FileEditController);

    if (localBounds == null) {
      return null;
    }

    final Offset imageOrigin = Offset(image.xx.value, image.yy.value);
    final List<Offset> localCorners = <Offset>[
      localBounds.topLeft,
      localBounds.topRight,
      localBounds.bottomRight,
      localBounds.bottomLeft,
    ];
    final List<Offset> canvasBorderCorners = localCorners
        .map(
          (Offset localPoint) => image.transformWorldPointFromBaseWorldPoint(
            imageOrigin + localPoint,
          ),
        )
        .toList(growable: false);
    final List<Offset> screenBorderCorners = canvasBorderCorners
        .map(th2FileEditController.offsetCanvasToScreen)
        .toList(growable: false);
    final Map<MPImageTransformHandleType, Offset> canvasHandleCenters =
        <MPImageTransformHandleType, Offset>{};
    final Map<MPImageTransformHandleType, Offset> screenHandleCenters =
        <MPImageTransformHandleType, Offset>{};
    final Map<MPImageTransformHandleType, Rect> screenHandleRects =
        <MPImageTransformHandleType, Rect>{};
    final Map<MPImageTransformHandleType, Path> screenHandlePaths =
        <MPImageTransformHandleType, Path>{};
    final Offset screenBoundsCenter = Rect.fromPoints(
      screenBorderCorners[0],
      screenBorderCorners[2],
    ).center;

    for (final MPImageTransformHandleType handleType
        in MPImageTransformHandleType.values) {
      final Offset canvasBorderCenter = image
          .transformWorldPointFromBaseWorldPoint(
            imageOrigin + _handleLocalPoint(localBounds, handleType),
          );
      final Offset screenBorderCenter = th2FileEditController
          .offsetCanvasToScreen(canvasBorderCenter);
      final Offset outwardDirection = _resolveOutwardDirection(
        handleType: handleType,
        screenBorderCorners: screenBorderCorners,
        screenBoundsCenter: screenBoundsCenter,
      );
      final Offset screenHandleCenter =
          screenBorderCenter +
          (outwardDirection * mpImageTransformHandleOffsetOnScreen);
      final Offset canvasHandleCenter = th2FileEditController
          .offsetScreenToCanvas(screenHandleCenter);

      canvasHandleCenters[handleType] = canvasHandleCenter;
      screenHandleCenters[handleType] = screenHandleCenter;
      screenHandleRects[handleType] = Rect.fromCenter(
        center: screenHandleCenter,
        width: mpImageTransformHandleHitBoxSizeOnScreen,
        height: mpImageTransformHandleHitBoxSizeOnScreen,
      );
      screenHandlePaths[handleType] = _buildScaleHandlePath(
        center: screenHandleCenter,
        direction: outwardDirection,
      );
    }

    return MPImageTransformGeometry(
      localBounds: localBounds,
      canvasHandleCenters: canvasHandleCenters,
      screenHandleCenters: screenHandleCenters,
      screenHandleRects: screenHandleRects,
      screenHandlePaths: screenHandlePaths,
      canvasBorderCorners: canvasBorderCorners,
      screenBorderCorners: screenBorderCorners,
    );
  }

  static Path _buildScaleHandlePath({
    required Offset center,
    required Offset direction,
  }) {
    final Offset axisDirection = _normalizeOffset(direction);
    final Offset perpendicularDirection = Offset(
      -axisDirection.dy,
      axisDirection.dx,
    );
    final double halfArrowLength =
        mpImageTransformHandleArrowLengthOnScreen / 2;
    final double halfArrowHeadWidth =
        mpImageTransformHandleArrowHeadWidthOnScreen / 2;
    final double halfArrowShaftWidth =
        mpImageTransformHandleArrowShaftWidthOnScreen / 2;
    final double halfShaftLength = (halfArrowLength - halfArrowHeadWidth).clamp(
      0.0,
      halfArrowLength,
    );

    return Path()
      ..moveTo(
        center.dx - axisDirection.dx * halfArrowLength,
        center.dy - axisDirection.dy * halfArrowLength,
      )
      ..lineTo(
        center.dx -
            axisDirection.dx * halfShaftLength -
            perpendicularDirection.dx * halfArrowHeadWidth,
        center.dy -
            axisDirection.dy * halfShaftLength -
            perpendicularDirection.dy * halfArrowHeadWidth,
      )
      ..lineTo(
        center.dx -
            axisDirection.dx * halfShaftLength -
            perpendicularDirection.dx * halfArrowShaftWidth,
        center.dy -
            axisDirection.dy * halfShaftLength -
            perpendicularDirection.dy * halfArrowShaftWidth,
      )
      ..lineTo(
        center.dx +
            axisDirection.dx * halfShaftLength -
            perpendicularDirection.dx * halfArrowShaftWidth,
        center.dy +
            axisDirection.dy * halfShaftLength -
            perpendicularDirection.dy * halfArrowShaftWidth,
      )
      ..lineTo(
        center.dx +
            axisDirection.dx * halfShaftLength -
            perpendicularDirection.dx * halfArrowHeadWidth,
        center.dy +
            axisDirection.dy * halfShaftLength -
            perpendicularDirection.dy * halfArrowHeadWidth,
      )
      ..lineTo(
        center.dx + axisDirection.dx * halfArrowLength,
        center.dy + axisDirection.dy * halfArrowLength,
      )
      ..lineTo(
        center.dx +
            axisDirection.dx * halfShaftLength +
            perpendicularDirection.dx * halfArrowHeadWidth,
        center.dy +
            axisDirection.dy * halfShaftLength +
            perpendicularDirection.dy * halfArrowHeadWidth,
      )
      ..lineTo(
        center.dx +
            axisDirection.dx * halfShaftLength +
            perpendicularDirection.dx * halfArrowShaftWidth,
        center.dy +
            axisDirection.dy * halfShaftLength +
            perpendicularDirection.dy * halfArrowShaftWidth,
      )
      ..lineTo(
        center.dx -
            axisDirection.dx * halfShaftLength +
            perpendicularDirection.dx * halfArrowShaftWidth,
        center.dy -
            axisDirection.dy * halfShaftLength +
            perpendicularDirection.dy * halfArrowShaftWidth,
      )
      ..lineTo(
        center.dx -
            axisDirection.dx * halfShaftLength +
            perpendicularDirection.dx * halfArrowHeadWidth,
        center.dy -
            axisDirection.dy * halfShaftLength +
            perpendicularDirection.dy * halfArrowHeadWidth,
      )
      ..close();
  }

  static Offset _resolveOutwardDirection({
    required MPImageTransformHandleType handleType,
    required List<Offset> screenBorderCorners,
    required Offset screenBoundsCenter,
  }) {
    switch (handleType) {
      case MPImageTransformHandleType.topLeft:
        return _normalizeOffset(screenBorderCorners[0] - screenBoundsCenter);
      case MPImageTransformHandleType.topCenter:
        return _normalizeOffset(
          ((screenBorderCorners[0] + screenBorderCorners[1]) / 2) -
              screenBoundsCenter,
        );
      case MPImageTransformHandleType.topRight:
        return _normalizeOffset(screenBorderCorners[1] - screenBoundsCenter);
      case MPImageTransformHandleType.centerLeft:
        return _normalizeOffset(
          ((screenBorderCorners[0] + screenBorderCorners[3]) / 2) -
              screenBoundsCenter,
        );
      case MPImageTransformHandleType.centerRight:
        return _normalizeOffset(
          ((screenBorderCorners[1] + screenBorderCorners[2]) / 2) -
              screenBoundsCenter,
        );
      case MPImageTransformHandleType.bottomLeft:
        return _normalizeOffset(screenBorderCorners[3] - screenBoundsCenter);
      case MPImageTransformHandleType.bottomCenter:
        return _normalizeOffset(
          ((screenBorderCorners[3] + screenBorderCorners[2]) / 2) -
              screenBoundsCenter,
        );
      case MPImageTransformHandleType.bottomRight:
        return _normalizeOffset(screenBorderCorners[2] - screenBoundsCenter);
    }
  }

  static Offset _normalizeOffset(Offset offset) {
    final double distance = offset.distance;

    if (distance < mpDoubleComparisonEpsilon) {
      return Offset(0.0, -1.0);
    }

    return offset / distance;
  }

  static Offset _handleLocalPoint(
    Rect localBounds,
    MPImageTransformHandleType handleType,
  ) {
    switch (handleType) {
      case MPImageTransformHandleType.topLeft:
        return localBounds.topLeft;
      case MPImageTransformHandleType.topCenter:
        return localBounds.topCenter;
      case MPImageTransformHandleType.topRight:
        return localBounds.topRight;
      case MPImageTransformHandleType.centerLeft:
        return localBounds.centerLeft;
      case MPImageTransformHandleType.centerRight:
        return localBounds.centerRight;
      case MPImageTransformHandleType.bottomLeft:
        return localBounds.bottomLeft;
      case MPImageTransformHandleType.bottomCenter:
        return localBounds.bottomCenter;
      case MPImageTransformHandleType.bottomRight:
        return localBounds.bottomRight;
    }
  }
}
