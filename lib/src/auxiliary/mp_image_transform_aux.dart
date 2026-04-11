// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
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

enum MPImageRotationHandleType { bottomLeft, bottomRight, topLeft, topRight }

extension MPImageTransformHandleTypeExtension on MPImageTransformHandleType {
  bool get affectsX {
    return !mpImageTransformHandleTypesWithoutXScaling.contains(name);
  }

  bool get affectsY {
    return !mpImageTransformHandleTypesWithoutYScaling.contains(name);
  }
}

/// Builds reusable handle paths based on Inkscape control-handle geometry.
class MPInkscapeHandlePaths {
  static const double _doubleArrowTipInset = 0.5;
  static const double _curvedArrowBaseInset = 1.5;
  static const double _curvedArrowSizeOffset = 3.0;

  /// Returns Inkscape's resize handle path in local coordinates.
  static Path doubleArrow(double size) {
    final double delta = (size - 1.0) / 4.0;
    final double tipX = _doubleArrowTipInset;
    final double tipY = size / 2.0;
    final double outerX = tipX + delta;
    final double outerY = tipY - delta;
    final double innerX = outerX;
    final double innerY = outerY + delta / 2.0;
    final double x0 = tipX;
    final double y0 = tipY;
    final double x1 = outerX;
    final double y1 = outerY;
    final double x2 = innerX;
    final double y2 = innerY;
    final double x3 = size - innerX;
    final double y3 = innerY;
    final double x4 = size - outerX;
    final double y4 = outerY;
    final double x5 = size - tipX;
    final double y5 = tipY;
    final double x6 = size - outerX;
    final double y6 = size - outerY;
    final double x7 = size - innerX;
    final double y7 = size - innerY;
    final double x8 = innerX;
    final double y8 = size - innerY;
    final double x9 = outerX;
    final double y9 = size - outerY;

    return Path()
      ..moveTo(x0, y0)
      ..lineTo(x1, y1)
      ..lineTo(x2, y2)
      ..lineTo(x3, y3)
      ..lineTo(x4, y4)
      ..lineTo(x5, y5)
      ..lineTo(x6, y6)
      ..lineTo(x7, y7)
      ..lineTo(x8, y8)
      ..lineTo(x9, y9)
      ..close();
  }

  /// Returns Inkscape's curved rotation handle path in local coordinates.
  static Path curvedArrow(double size) {
    final double delta = (size - _curvedArrowSizeOffset) / 4.0;
    final double tipX = _curvedArrowBaseInset;
    final double tipY = delta + _curvedArrowBaseInset;
    final double outerX = tipX + delta;
    final double outerY = tipY - delta;
    final double innerX = outerX;
    final double innerY = outerY + delta / 2.0;
    final double x0 = tipX;
    final double y0 = tipY;
    final double x1 = outerX;
    final double y1 = outerY;
    final double x2 = innerX;
    final double y2 = innerY;
    final double x3 = size - innerY;
    final double y3 = y2;
    final double x4 = size - outerY;
    final double y4 = size - outerX;
    final double x5 = size - tipY;
    final double y5 = size - tipX;
    final double x6 = x5 - delta;
    final double y6 = y4;
    final double x7 = x5 - delta / 2.0;
    final double y7 = y4;
    final double x8 = x1;
    final double x9 = x1;
    final double y9 = y0 + delta;
    final double radiusOuter = x3 - x2;
    final double radiusInner = x7 - x8;
    final Rect outerRect = Rect.fromCircle(
      center: Offset(x1, y4),
      radius: radiusOuter,
    );
    final Rect innerRect = Rect.fromCircle(
      center: Offset(x1, y4),
      radius: radiusInner,
    );
    final Path path = Path()
      ..moveTo(x0, y0)
      ..lineTo(x1, y1)
      ..lineTo(x2, y2)
      ..arcTo(outerRect, 3.0 * math.pi / 2.0, math.pi / 2.0, false)
      ..lineTo(x4, y4)
      ..lineTo(x5, y5)
      ..lineTo(x6, y6)
      ..lineTo(x7, y7)
      ..arcTo(innerRect, 0.0, -math.pi / 2.0, false)
      ..lineTo(x9, y9)
      ..close();

    assert(radiusOuter > 0.0);
    assert(radiusInner > 0.0);
    assert(y3 == y2);

    return path;
  }

  /// Returns a centered resize handle ready for later transforms.
  static Path centeredDoubleArrow(double size) {
    return doubleArrow(size).shift(Offset(-size / 2.0, -size / 2.0));
  }

  /// Returns a centered curved rotation handle ready for later transforms.
  static Path centeredCurvedArrow(double size) {
    return curvedArrow(size).shift(Offset(-size / 2.0, -size / 2.0));
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
  static final Path _baseScaleHandlePath = _buildBaseScaleHandlePath();

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
    for (final MPImageTransformHandleType handleType
        in MPImageTransformHandleType.values) {
      final Path? handlePath = screenHandlePaths[handleType];
      final Rect? handleRect = screenHandleRects[handleType];

      if ((handlePath != null) &&
          handlePath
              .getBounds()
              .inflate(mpImageTransformHandleHitBoxSizeOnScreen / 2.0)
              .contains(screenPosition)) {
        return handleType;
      }

      if ((handleRect != null) && handleRect.contains(screenPosition)) {
        return handleType;
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

  /// Computes handle geometry for an axis-aligned selection bounding box in
  /// canvas coordinates.  Unlike [forImage], no image rotation is involved, so
  /// [xAxisDirection] and [yAxisDirection] are always canonical screen-space
  /// axes.
  static MPImageTransformGeometry forCanvasBoundingBox({
    required TH2FileEditController th2FileEditController,
    required Rect canvasBoundingBox,
  }) {
    final List<Offset> canvasBorderCorners = <Offset>[
      canvasBoundingBox.topLeft,
      canvasBoundingBox.topRight,
      canvasBoundingBox.bottomRight,
      canvasBoundingBox.bottomLeft,
    ];
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
    final Offset topLeftToTopRight =
        screenBorderCorners[1] - screenBorderCorners[0];
    final Offset topLeftToBottomLeft =
        screenBorderCorners[3] - screenBorderCorners[0];
    final Offset xAxisDirection = _normalizeOffset(topLeftToTopRight);
    final Offset yAxisDirection = _normalizeOffset(topLeftToBottomLeft);

    final Map<MPImageTransformHandleType, Offset> canvasBorderPositions =
        <MPImageTransformHandleType, Offset>{
          MPImageTransformHandleType.topLeft: canvasBoundingBox.topLeft,
          MPImageTransformHandleType.topCenter: canvasBoundingBox.topCenter,
          MPImageTransformHandleType.topRight: canvasBoundingBox.topRight,
          MPImageTransformHandleType.centerLeft: canvasBoundingBox.centerLeft,
          MPImageTransformHandleType.centerRight: canvasBoundingBox.centerRight,
          MPImageTransformHandleType.bottomLeft: canvasBoundingBox.bottomLeft,
          MPImageTransformHandleType.bottomCenter:
              canvasBoundingBox.bottomCenter,
          MPImageTransformHandleType.bottomRight: canvasBoundingBox.bottomRight,
        };

    for (final MPImageTransformHandleType handleType
        in MPImageTransformHandleType.values) {
      final Offset canvasBorderCenter = canvasBorderPositions[handleType]!;
      final Offset screenBorderCenter = th2FileEditController
          .offsetCanvasToScreen(canvasBorderCenter);
      final Offset outwardDirection = _resolveOutwardDirection(
        handleType: handleType,
        xAxisDirection: xAxisDirection,
        yAxisDirection: yAxisDirection,
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
      localBounds: canvasBoundingBox,
      canvasHandleCenters: canvasHandleCenters,
      screenHandleCenters: screenHandleCenters,
      screenHandleRects: screenHandleRects,
      screenHandlePaths: screenHandlePaths,
      canvasBorderCorners: canvasBorderCorners,
      screenBorderCorners: screenBorderCorners,
    );
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
    final Offset topLeftToTopRight =
        screenBorderCorners[1] - screenBorderCorners[0];
    final Offset topLeftToBottomLeft =
        screenBorderCorners[3] - screenBorderCorners[0];
    final Offset xAxisDirection = _normalizeOffset(topLeftToTopRight);
    final Offset yAxisDirection = _normalizeOffset(topLeftToBottomLeft);

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
        xAxisDirection: xAxisDirection,
        yAxisDirection: yAxisDirection,
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
    final Offset normalizedDirection = _normalizeOffset(direction);
    final double angleInRad = math.atan2(
      normalizedDirection.dy,
      normalizedDirection.dx,
    );
    final double cosValue = math.cos(angleInRad);
    final double sinValue = math.sin(angleInRad);
    final Float64List matrix = Float64List.fromList(<double>[
      cosValue,
      sinValue,
      0.0,
      0.0,
      -sinValue,
      cosValue,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      center.dx,
      center.dy,
      0.0,
      1.0,
    ]);

    return _baseScaleHandlePath.transform(matrix);
  }

  static Path _buildBaseScaleHandlePath() {
    final Path centeredPath = MPInkscapeHandlePaths.centeredDoubleArrow(
      mpImageTransformHandleBaseSizeOnScreen,
    );
    final Rect bounds = centeredPath.getBounds();
    final double xScale = mpImageTransformHandleLengthOnScreen / bounds.width;
    final double yScale =
        mpImageTransformHandleThicknessOnScreen / bounds.height;
    final Float64List matrix = Float64List.fromList(<double>[
      xScale,
      0.0,
      0.0,
      0.0,
      0.0,
      yScale,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
    ]);

    assert(bounds.width > 0.0);
    assert(bounds.height > 0.0);

    return centeredPath.transform(matrix);
  }

  static Offset _resolveOutwardDirection({
    required MPImageTransformHandleType handleType,
    required Offset xAxisDirection,
    required Offset yAxisDirection,
  }) {
    switch (handleType) {
      case MPImageTransformHandleType.topLeft:
        return _normalizeOffset(-xAxisDirection - yAxisDirection);
      case MPImageTransformHandleType.topCenter:
        return _normalizeOffset(-yAxisDirection);
      case MPImageTransformHandleType.topRight:
        return _normalizeOffset(xAxisDirection - yAxisDirection);
      case MPImageTransformHandleType.centerLeft:
        return _normalizeOffset(-xAxisDirection);
      case MPImageTransformHandleType.centerRight:
        return _normalizeOffset(xAxisDirection);
      case MPImageTransformHandleType.bottomLeft:
        return _normalizeOffset(-xAxisDirection + yAxisDirection);
      case MPImageTransformHandleType.bottomCenter:
        return _normalizeOffset(yAxisDirection);
      case MPImageTransformHandleType.bottomRight:
        return _normalizeOffset(xAxisDirection + yAxisDirection);
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

class MPImageRotationGeometry {
  final Rect localBounds;
  final Map<MPImageRotationHandleType, Offset> canvasHandleCorners;
  final Map<MPImageRotationHandleType, Offset> screenHandleCenters;
  final Map<MPImageRotationHandleType, Rect> screenHandleRects;
  final Map<MPImageRotationHandleType, Path> screenHandlePaths;
  final Offset canvasPivotCenter;
  final Offset screenPivotCenter;
  final Rect screenPivotRect;
  final Path screenPivotPath;
  static final Path _baseRotationHandlePath = _buildBaseRotationHandlePath();
  static final Path _basePivotPath = _buildBasePivotPath();

  const MPImageRotationGeometry({
    required this.localBounds,
    required this.canvasHandleCorners,
    required this.screenHandleCenters,
    required this.screenHandleRects,
    required this.screenHandlePaths,
    required this.canvasPivotCenter,
    required this.screenPivotCenter,
    required this.screenPivotRect,
    required this.screenPivotPath,
  });

  Offset handleLocalPoint(MPImageRotationHandleType handleType) {
    switch (handleType) {
      case MPImageRotationHandleType.topLeft:
        return localBounds.topLeft;
      case MPImageRotationHandleType.topRight:
        return localBounds.topRight;
      case MPImageRotationHandleType.bottomLeft:
        return localBounds.bottomLeft;
      case MPImageRotationHandleType.bottomRight:
        return localBounds.bottomRight;
    }
  }

  MPImageRotationHandleType? hitTestHandle(Offset screenPosition) {
    for (final MPImageRotationHandleType handleType
        in MPImageRotationHandleType.values) {
      final Path? handlePath = screenHandlePaths[handleType];
      final Rect? handleRect = screenHandleRects[handleType];

      if ((handlePath != null) &&
          handlePath
              .getBounds()
              .inflate(mpImageTransformHandleHitBoxSizeOnScreen / 2.0)
              .contains(screenPosition)) {
        return handleType;
      }

      if ((handleRect != null) && handleRect.contains(screenPosition)) {
        return handleType;
      }
    }

    return null;
  }

  bool hitTestPivot(Offset screenPosition) {
    return screenPivotRect.contains(screenPosition);
  }

  /// Computes rotation handle geometry for an axis-aligned selection bounding
  /// box in canvas coordinates.  There is no draggable pivot for element
  /// rotation, so the pivot is placed at the bounding-box center and marked
  /// non-interactive by the painter.
  static MPImageRotationGeometry forCanvasBoundingBox({
    required TH2FileEditController th2FileEditController,
    required Rect canvasBoundingBox,
  }) {
    final MPImageTransformGeometry transformGeometry =
        MPImageTransformGeometry.forCanvasBoundingBox(
          th2FileEditController: th2FileEditController,
          canvasBoundingBox: canvasBoundingBox,
        );

    final List<Offset> screenBorderCorners =
        transformGeometry.screenBorderCorners;
    final Offset topLeftToTopRight =
        screenBorderCorners[1] - screenBorderCorners[0];
    final Offset topLeftToBottomLeft =
        screenBorderCorners[3] - screenBorderCorners[0];
    final Offset xAxisDirection = _normalizeOffset(topLeftToTopRight);
    final Offset yAxisDirection = _normalizeOffset(topLeftToBottomLeft);
    final Map<MPImageRotationHandleType, Offset> canvasHandleCorners =
        <MPImageRotationHandleType, Offset>{};
    final Map<MPImageRotationHandleType, Offset> screenHandleCenters =
        <MPImageRotationHandleType, Offset>{};
    final Map<MPImageRotationHandleType, Rect> screenHandleRects =
        <MPImageRotationHandleType, Rect>{};
    final Map<MPImageRotationHandleType, Path> screenHandlePaths =
        <MPImageRotationHandleType, Path>{};

    final Map<MPImageRotationHandleType, Offset> canvasCornerPositions =
        <MPImageRotationHandleType, Offset>{
          MPImageRotationHandleType.topLeft: canvasBoundingBox.topLeft,
          MPImageRotationHandleType.topRight: canvasBoundingBox.topRight,
          MPImageRotationHandleType.bottomLeft: canvasBoundingBox.bottomLeft,
          MPImageRotationHandleType.bottomRight: canvasBoundingBox.bottomRight,
        };

    for (final MPImageRotationHandleType handleType
        in MPImageRotationHandleType.values) {
      final Offset canvasCorner = canvasCornerPositions[handleType]!;
      final Offset screenCorner = th2FileEditController.offsetCanvasToScreen(
        canvasCorner,
      );
      final Offset outwardDirection = _resolveRotationOutwardDirection(
        handleType: handleType,
        xAxisDirection: xAxisDirection,
        yAxisDirection: yAxisDirection,
      );
      final Offset screenHandleCenter =
          screenCorner +
          (outwardDirection * mpImageTransformHandleOffsetOnScreen);

      canvasHandleCorners[handleType] = canvasCorner;
      screenHandleCenters[handleType] = screenHandleCenter;
      screenHandleRects[handleType] = Rect.fromCenter(
        center: screenHandleCenter,
        width: mpImageTransformHandleHitBoxSizeOnScreen,
        height: mpImageTransformHandleHitBoxSizeOnScreen,
      );
      screenHandlePaths[handleType] = _buildRotationHandlePath(
        center: screenHandleCenter,
        direction: outwardDirection,
      );
    }

    final Offset canvasPivotCenter = canvasBoundingBox.center;
    final Offset screenPivotCenter = th2FileEditController.offsetCanvasToScreen(
      canvasPivotCenter,
    );
    final Path screenPivotPath = _buildPivotPath(screenPivotCenter);

    return MPImageRotationGeometry(
      localBounds: canvasBoundingBox,
      canvasHandleCorners: canvasHandleCorners,
      screenHandleCenters: screenHandleCenters,
      screenHandleRects: screenHandleRects,
      screenHandlePaths: screenHandlePaths,
      canvasPivotCenter: canvasPivotCenter,
      screenPivotCenter: screenPivotCenter,
      screenPivotRect: Rect.fromCenter(
        center: screenPivotCenter,
        width: mpImageTransformHandleHitBoxSizeOnScreen,
        height: mpImageTransformHandleHitBoxSizeOnScreen,
      ),
      screenPivotPath: screenPivotPath,
    );
  }

  static MPImageRotationGeometry? forImage({
    required TH2FileEditController th2FileEditController,
    required MPRuntimeImageInsertConfigMixin image,
  }) {
    if (image is! MPImageInsertConfig) {
      return null;
    }

    final MPImageTransformGeometry? transformGeometry =
        MPImageTransformGeometry.forImage(
          th2FileEditController: th2FileEditController,
          image: image,
        );

    if (transformGeometry == null) {
      return null;
    }

    final Rect localBounds = transformGeometry.localBounds;
    final List<Offset> screenBorderCorners =
        transformGeometry.screenBorderCorners;
    final Offset topLeftToTopRight =
        screenBorderCorners[1] - screenBorderCorners[0];
    final Offset topLeftToBottomLeft =
        screenBorderCorners[3] - screenBorderCorners[0];
    final Offset xAxisDirection = _normalizeOffset(topLeftToTopRight);
    final Offset yAxisDirection = _normalizeOffset(topLeftToBottomLeft);
    final Map<MPImageRotationHandleType, Offset> canvasHandleCorners =
        <MPImageRotationHandleType, Offset>{};
    final Map<MPImageRotationHandleType, Offset> screenHandleCenters =
        <MPImageRotationHandleType, Offset>{};
    final Map<MPImageRotationHandleType, Rect> screenHandleRects =
        <MPImageRotationHandleType, Rect>{};
    final Map<MPImageRotationHandleType, Path> screenHandlePaths =
        <MPImageRotationHandleType, Path>{};

    for (final MPImageRotationHandleType handleType
        in MPImageRotationHandleType.values) {
      final Offset localHandlePoint = _rotationHandleLocalPoint(
        localBounds,
        handleType,
      );
      final Offset canvasCorner = image.transformLocalPoint(localHandlePoint);
      final Offset screenCorner = th2FileEditController.offsetCanvasToScreen(
        canvasCorner,
      );
      final Offset outwardDirection = _resolveRotationOutwardDirection(
        handleType: handleType,
        xAxisDirection: xAxisDirection,
        yAxisDirection: yAxisDirection,
      );
      final Offset screenHandleCenter =
          screenCorner +
          (outwardDirection * mpImageTransformHandleOffsetOnScreen);

      canvasHandleCorners[handleType] = canvasCorner;
      screenHandleCenters[handleType] = screenHandleCenter;
      screenHandleRects[handleType] = Rect.fromCenter(
        center: screenHandleCenter,
        width: mpImageTransformHandleHitBoxSizeOnScreen,
        height: mpImageTransformHandleHitBoxSizeOnScreen,
      );
      screenHandlePaths[handleType] = _buildRotationHandlePath(
        center: screenHandleCenter,
        direction: outwardDirection,
      );
    }

    final Offset canvasPivotCenter = image.transformLocalPoint(
      image.localRotationCenter,
    );
    final Offset screenPivotCenter = th2FileEditController.offsetCanvasToScreen(
      canvasPivotCenter,
    );
    final Path screenPivotPath = _buildPivotPath(screenPivotCenter);

    return MPImageRotationGeometry(
      localBounds: localBounds,
      canvasHandleCorners: canvasHandleCorners,
      screenHandleCenters: screenHandleCenters,
      screenHandleRects: screenHandleRects,
      screenHandlePaths: screenHandlePaths,
      canvasPivotCenter: canvasPivotCenter,
      screenPivotCenter: screenPivotCenter,
      screenPivotRect: Rect.fromCenter(
        center: screenPivotCenter,
        width: mpImageTransformHandleHitBoxSizeOnScreen,
        height: mpImageTransformHandleHitBoxSizeOnScreen,
      ),
      screenPivotPath: screenPivotPath,
    );
  }

  static Path _buildRotationHandlePath({
    required Offset center,
    required Offset direction,
  }) {
    final Offset normalizedDirection = _normalizeOffset(direction);
    final double angleInRad = rotationHandleAngleForTesting(
      normalizedDirection,
    );
    final double cosValue = math.cos(angleInRad);
    final double sinValue = math.sin(angleInRad);
    final Float64List matrix = Float64List.fromList(<double>[
      cosValue,
      sinValue,
      0.0,
      0.0,
      -sinValue,
      cosValue,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      center.dx,
      center.dy,
      0.0,
      1.0,
    ]);

    return _baseRotationHandlePath.transform(matrix);
  }

  static Path _buildPivotPath(Offset center) {
    final Float64List matrix = Float64List.fromList(<double>[
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      center.dx,
      center.dy,
      0.0,
      1.0,
    ]);

    return _basePivotPath.transform(matrix);
  }

  static Path _buildBaseRotationHandlePath() {
    final Path centeredPath = MPInkscapeHandlePaths.centeredCurvedArrow(
      mpImageTransformHandleBaseSizeOnScreen,
    );

    return _buildUniformlyScaledPath(
      centeredPath: centeredPath,
      targetSize: mpImageTransformHandleLengthOnScreen,
    );
  }

  static Path _buildBasePivotPath() {
    const double size = mpImageTransformHandleBaseSizeOnScreen;
    final double delta4 = (size - 5.0) / 4.0;
    final double delta8 = delta4 / 2.0;
    final double center = size / 2.0;
    final Path path = Path()
      ..moveTo(center - delta8, center - 2 * delta4 - delta8)
      ..relativeLineTo(delta4, 0)
      ..relativeLineTo(0, delta4)
      ..relativeLineTo(delta4, delta4)
      ..relativeLineTo(delta4, 0)
      ..relativeLineTo(0, delta4)
      ..relativeLineTo(-delta4, 0)
      ..relativeLineTo(-delta4, delta4)
      ..relativeLineTo(0, delta4)
      ..relativeLineTo(-delta4, 0)
      ..relativeLineTo(0, -delta4)
      ..relativeLineTo(-delta4, -delta4)
      ..relativeLineTo(-delta4, 0)
      ..relativeLineTo(0, -delta4)
      ..relativeLineTo(delta4, 0)
      ..relativeLineTo(delta4, -delta4)
      ..close()
      ..addOval(
        Rect.fromCircle(center: Offset(center, center), radius: delta4),
      );

    return path.shift(Offset(-center, -center));
  }

  static Offset _rotationHandleLocalPoint(
    Rect localBounds,
    MPImageRotationHandleType handleType,
  ) {
    switch (handleType) {
      case MPImageRotationHandleType.topLeft:
        return localBounds.topLeft;
      case MPImageRotationHandleType.topRight:
        return localBounds.topRight;
      case MPImageRotationHandleType.bottomLeft:
        return localBounds.bottomLeft;
      case MPImageRotationHandleType.bottomRight:
        return localBounds.bottomRight;
    }
  }

  static Offset _resolveRotationOutwardDirection({
    required MPImageRotationHandleType handleType,
    required Offset xAxisDirection,
    required Offset yAxisDirection,
  }) {
    switch (handleType) {
      case MPImageRotationHandleType.topLeft:
        return _normalizeOffset(-xAxisDirection - yAxisDirection);
      case MPImageRotationHandleType.topRight:
        return _normalizeOffset(xAxisDirection - yAxisDirection);
      case MPImageRotationHandleType.bottomLeft:
        return _normalizeOffset(-xAxisDirection + yAxisDirection);
      case MPImageRotationHandleType.bottomRight:
        return _normalizeOffset(xAxisDirection + yAxisDirection);
    }
  }

  static Offset _normalizeOffset(Offset offset) {
    final double distance = offset.distance;

    if (distance < mpDoubleComparisonEpsilon) {
      return const Offset(0.0, -1.0);
    }

    return offset / distance;
  }

  @visibleForTesting
  static double rotationHandleAngleForTesting(Offset direction) {
    final Offset normalizedDirection = _normalizeOffset(direction);
    final double directionAngleInRad = math.atan2(
      normalizedDirection.dy,
      normalizedDirection.dx,
    );

    return directionAngleInRad + mp45DegreesInRad;
  }

  @visibleForTesting
  static Path baseRotationHandlePathForTesting() {
    return _baseRotationHandlePath;
  }

  static Path _buildUniformlyScaledPath({
    required Path centeredPath,
    required double targetSize,
  }) {
    final Rect bounds = centeredPath.getBounds();
    final double maxDimension = math.max(bounds.width, bounds.height);
    final double uniformScale = targetSize / maxDimension;
    final Float64List matrix = Float64List.fromList(<double>[
      uniformScale,
      0.0,
      0.0,
      0.0,
      0.0,
      uniformScale,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
    ]);

    assert(bounds.width > 0.0);
    assert(bounds.height > 0.0);
    assert(maxDimension > 0.0);

    return centeredPath.transform(matrix);
  }
}

/// Resolves pure geometry for image rotation previews and pivot moves.
class MPImageRotationPreviewMath {
  static double? rotationDeltaDeg({
    required Offset pivotCanvas,
    required Offset dragStartCanvasPosition,
    required Offset currentCanvasPosition,
  }) {
    final Offset startVector = dragStartCanvasPosition - pivotCanvas;
    final Offset currentVector = currentCanvasPosition - pivotCanvas;

    if ((startVector.distance < mpDoubleComparisonEpsilon) ||
        (currentVector.distance < mpDoubleComparisonEpsilon)) {
      return null;
    }

    final double startAngleInRad = math.atan2(startVector.dy, startVector.dx);
    final double currentAngleInRad = math.atan2(
      currentVector.dy,
      currentVector.dx,
    );

    return (currentAngleInRad - startAngleInRad) / mp1DegreeInRads;
  }

  static double snapRotationDeg({
    required double rotationDeg,
    required double snapAngleDeg,
  }) {
    if (snapAngleDeg.abs() < mpDoubleComparisonEpsilon) {
      return rotationDeg;
    }

    return (rotationDeg / snapAngleDeg).round() * snapAngleDeg;
  }

  static Offset translationForAnchorAfterRotation({
    required MPImageInsertConfig startImage,
    required Offset anchorLocal,
    required Offset anchorCanvas,
    required double rotationDeg,
  }) {
    final Offset scaledAnchor = Offset(
      anchorLocal.dx * startImage.xScale.value,
      anchorLocal.dy * startImage.yScale.value,
    );
    final Offset scaledPivot = startImage.scaledRotationCenter;
    final Offset rotatedDelta = rotateOffset(
      scaledAnchor - scaledPivot,
      rotationDeg * mp1DegreeInRads,
    );

    return anchorCanvas - scaledPivot - rotatedDelta;
  }

  static Offset targetLocalPivotFromCanvas({
    required MPImageInsertConfig startImage,
    required Offset targetPivotCanvas,
  }) {
    final Offset startTranslation = Offset(
      startImage.xx.value,
      startImage.yy.value,
    );
    final double angleInRad = startImage.rotationDeg.value * mp1DegreeInRads;
    final Offset scaledPivot = startImage.scaledRotationCenter;
    final Offset rotatedScaledPivot = rotateOffset(scaledPivot, angleInRad);
    final Offset rotatedScaledTargetPivot = rotateOffset(
      targetPivotCanvas - startTranslation - scaledPivot + rotatedScaledPivot,
      -angleInRad,
    );
    final double resolvedXScale = avoidZeroScale(startImage.xScale.value);
    final double resolvedYScale = avoidZeroScale(startImage.yScale.value);

    return Offset(
      rotatedScaledTargetPivot.dx / resolvedXScale,
      rotatedScaledTargetPivot.dy / resolvedYScale,
    );
  }

  static Offset translationForPreservedImageAfterPivotMove({
    required MPImageInsertConfig startImage,
    required Offset targetLocalPivot,
  }) {
    final Offset currentScaledPivot = startImage.scaledRotationCenter;
    final Offset targetScaledPivot = Offset(
      targetLocalPivot.dx * startImage.xScale.value,
      targetLocalPivot.dy * startImage.yScale.value,
    );
    final double angleInRad = startImage.rotationDeg.value * mp1DegreeInRads;
    final Offset rotatedCurrentScaledPivot = rotateOffset(
      currentScaledPivot,
      angleInRad,
    );
    final Offset rotatedTargetScaledPivot = rotateOffset(
      targetScaledPivot,
      angleInRad,
    );

    return Offset(startImage.xx.value, startImage.yy.value) +
        currentScaledPivot -
        rotatedCurrentScaledPivot -
        targetScaledPivot +
        rotatedTargetScaledPivot;
  }

  static Offset oppositeCornerLocalPoint(
    Rect localBounds,
    MPImageRotationHandleType handleType,
  ) {
    switch (handleType) {
      case MPImageRotationHandleType.topLeft:
        return localBounds.bottomRight;
      case MPImageRotationHandleType.topRight:
        return localBounds.bottomLeft;
      case MPImageRotationHandleType.bottomLeft:
        return localBounds.topRight;
      case MPImageRotationHandleType.bottomRight:
        return localBounds.topLeft;
    }
  }

  static Offset rotateOffset(Offset offset, double angleInRad) {
    final double cosValue = math.cos(angleInRad);
    final double sinValue = math.sin(angleInRad);

    return Offset(
      offset.dx * cosValue - offset.dy * sinValue,
      offset.dx * sinValue + offset.dy * cosValue,
    );
  }

  static double avoidZeroScale(double scale) {
    if (scale.abs() >= mpDoubleMinNormalized) {
      return scale;
    }

    return (scale.isNegative ? -1.0 : 1.0) * mpDoubleMinNormalized;
  }
}
