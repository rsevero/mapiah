// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';

enum MPImageTransformHandleType {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

extension MPImageTransformHandleTypeExtension on MPImageTransformHandleType {
  bool get affectsX {
    switch (this) {
      case MPImageTransformHandleType.topCenter:
      case MPImageTransformHandleType.bottomCenter:
        return false;
      default:
        return true;
    }
  }

  bool get affectsY {
    switch (this) {
      case MPImageTransformHandleType.centerLeft:
      case MPImageTransformHandleType.centerRight:
        return false;
      default:
        return true;
    }
  }
}

class MPImageTransformGeometry {
  static const double handleSizeOnScreen = 8.0;

  final Rect localBounds;
  final Map<MPImageTransformHandleType, Offset> canvasHandleCenters;
  final Map<MPImageTransformHandleType, Rect> screenHandleRects;
  final List<Offset> canvasBorderCorners;
  final List<Offset> screenBorderCorners;

  const MPImageTransformGeometry({
    required this.localBounds,
    required this.canvasHandleCenters,
    required this.screenHandleRects,
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
    final Map<MPImageTransformHandleType, Rect> screenHandleRects =
        <MPImageTransformHandleType, Rect>{};

    for (final MPImageTransformHandleType handleType
        in MPImageTransformHandleType.values) {
      final Offset canvasCenter = image.transformWorldPointFromBaseWorldPoint(
        imageOrigin + _handleLocalPoint(localBounds, handleType),
      );
      final Offset screenCenter = th2FileEditController.offsetCanvasToScreen(
        canvasCenter,
      );

      canvasHandleCenters[handleType] = canvasCenter;
      screenHandleRects[handleType] = Rect.fromCenter(
        center: screenCenter,
        width: handleSizeOnScreen,
        height: handleSizeOnScreen,
      );
    }

    return MPImageTransformGeometry(
      localBounds: localBounds,
      canvasHandleCenters: canvasHandleCenters,
      screenHandleRects: screenHandleRects,
      canvasBorderCorners: canvasBorderCorners,
      screenBorderCorners: screenBorderCorners,
    );
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
