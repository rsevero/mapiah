// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';

class TH2FileEditLineTraceController {
  final TH2FileEditController _th2FileEditController;

  final ValueNotifier<bool> isTracingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> canStartTracingNotifier = ValueNotifier<bool>(
    false,
  );

  bool _isTraceLoopRunning = false;
  bool _shouldContinueTracing = false;

  double? _stepDistanceOnCanvas;
  _RGBColor? _targetColor;

  TH2FileEditLineTraceController(this._th2FileEditController);

  bool get isTracing => isTracingNotifier.value;

  double? get stepDistanceOnCanvas => _stepDistanceOnCanvas;

  bool get hasAnyImage => _th2FileEditController.th2File.getImages().isNotEmpty;

  Future<void> updateCanStartTracing() async {
    if (!hasAnyImage || !_th2FileEditController.isInAddLineState) {
      canStartTracingNotifier.value = false;

      return;
    }

    final List<Offset> lineNodes = _th2FileEditController
        .areaLineCreationController
        .getCurrentInteractiveLineNodeCanvasCoordinates();

    if (lineNodes.length < 2) {
      canStartTracingNotifier.value = false;

      return;
    }

    final _RGBColor? color = await _sampleRasterColorAtCanvas(
      lineNodes.last,
      requireVisibleImageOnly: true,
    );

    canStartTracingNotifier.value = color != null;
  }

  Future<void> startTracingFromCurrentLine() async {
    if (isTracingNotifier.value) {
      return;
    }

    final List<Offset> lineNodes = _th2FileEditController
        .areaLineCreationController
        .getCurrentInteractiveLineNodeCanvasCoordinates();

    if (lineNodes.length < 2) {
      return;
    }

    final _RGBColor? sampledColor = await _sampleRasterColorAtCanvas(
      lineNodes.last,
      requireVisibleImageOnly: true,
    );

    if (sampledColor == null) {
      canStartTracingNotifier.value = false;

      return;
    }

    final double fixedStepDistance = max(
      1.0,
      (lineNodes.last - lineNodes[lineNodes.length - 2]).distance,
    );

    _stepDistanceOnCanvas = fixedStepDistance;
    _targetColor = sampledColor;
    _shouldContinueTracing = true;
    isTracingNotifier.value = true;

    if (_isTraceLoopRunning) {
      return;
    }

    _isTraceLoopRunning = true;

    try {
      await _runTraceLoop();
    } finally {
      _isTraceLoopRunning = false;
      _shouldContinueTracing = false;
      isTracingNotifier.value = false;
      await updateCanStartTracing();
    }
  }

  Future<void> toggleTracing() async {
    if (isTracingNotifier.value) {
      stopTracing();

      return;
    }

    await startTracingFromCurrentLine();
  }

  void stopTracing() {
    _shouldContinueTracing = false;
    isTracingNotifier.value = false;
  }

  void reset() {
    stopTracing();
    _targetColor = null;
    _stepDistanceOnCanvas = null;
    canStartTracingNotifier.value = false;
  }

  Future<void> _runTraceLoop() async {
    while (_shouldContinueTracing && _th2FileEditController.isInAddLineState) {
      final bool stepSucceeded = await _traceSingleStep();

      if (!stepSucceeded) {
        stopTracing();

        return;
      }

      await Future<void>.delayed(Duration.zero);
    }
  }

  Future<bool> _traceSingleStep() async {
    final _TraceContext? context = _createTraceContext();

    if (context == null) {
      return false;
    }

    final List<double> localStepAttempts = <double>[
      context.stepDistance,
      context.stepDistance / 2.0,
      context.stepDistance * 2.0,
    ];

    for (final double localStepDistance in localStepAttempts) {
      if (localStepDistance < 1.0) {
        continue;
      }

      final Offset? tracedPoint = await _findNextPoint(
        context: context,
        localStepDistance: localStepDistance,
      );

      if (tracedPoint == null) {
        continue;
      }

      final bool shouldAutoClose =
          (tracedPoint - context.startPoint).distance <= context.stepDistance;

      if (shouldAutoClose) {
        _appendCanvasNode(context.startPoint);
        stopTracing();

        return true;
      }

      _appendCanvasNode(tracedPoint);
      _scrollCanvasToFollow(tracedPoint);

      return true;
    }

    return false;
  }

  _TraceContext? _createTraceContext() {
    final _RGBColor? targetColor = _targetColor;
    final double? stepDistance = _stepDistanceOnCanvas;

    if ((targetColor == null) || (stepDistance == null)) {
      return null;
    }

    final List<Offset> lineNodes = _th2FileEditController
        .areaLineCreationController
        .getCurrentInteractiveLineNodeCanvasCoordinates();

    if (lineNodes.length < 2) {
      return null;
    }

    final Offset startPoint = lineNodes.first;
    final Offset previousPoint = lineNodes[lineNodes.length - 2];
    final Offset currentPoint = lineNodes.last;
    final Offset direction = currentPoint - previousPoint;

    if (direction.distance <= 0.000001) {
      return null;
    }

    final Offset unitDirection = direction / direction.distance;

    return _TraceContext(
      currentPoint: currentPoint,
      startPoint: startPoint,
      stepDistance: stepDistance,
      targetColor: targetColor,
      unitDirection: unitDirection,
    );
  }

  Future<Offset?> _findNextPoint({
    required _TraceContext context,
    required double localStepDistance,
  }) async {
    final Offset arcCenter =
        context.currentPoint + (context.unitDirection * localStepDistance);
    final int sampleCount = max(24, (localStepDistance * 12.0).round());
    final List<Offset> matchingArcPoints = <Offset>[];
    final List<List<Offset>> matchingArcs = <List<Offset>>[];

    for (int i = 0; i < sampleCount; i++) {
      final double angle = (2.0 * pi * i) / sampleCount;
      final Offset radial = Offset(cos(angle), sin(angle));
      final Offset candidate = arcCenter + (radial * localStepDistance);
      final double aheadDot =
          ((candidate - context.currentPoint).dx * context.unitDirection.dx) +
          ((candidate - context.currentPoint).dy * context.unitDirection.dy);

      if (aheadDot < 0) {
        if (matchingArcPoints.isNotEmpty) {
          matchingArcs.add(List<Offset>.from(matchingArcPoints));
          matchingArcPoints.clear();
        }

        continue;
      }

      final _RGBColor? candidateColor = await _sampleRasterColorAtCanvas(
        candidate,
        requireVisibleImageOnly: true,
      );

      if ((candidateColor != null) &&
          (_squaredRGBDistance(candidateColor, context.targetColor) <= 1600)) {
        matchingArcPoints.add(candidate);
      } else if (matchingArcPoints.isNotEmpty) {
        matchingArcs.add(List<Offset>.from(matchingArcPoints));
        matchingArcPoints.clear();
      }
    }

    if (matchingArcPoints.isNotEmpty) {
      matchingArcs.add(List<Offset>.from(matchingArcPoints));
    }

    if (matchingArcs.isEmpty) {
      return null;
    }

    List<Offset> longestArc = matchingArcs.first;

    for (final List<Offset> arc in matchingArcs.skip(1)) {
      if (arc.length > longestArc.length) {
        longestArc = arc;
      }
    }

    Offset centroid = Offset.zero;

    for (final Offset point in longestArc) {
      centroid += point;
    }

    return centroid / longestArc.length.toDouble();
  }

  Future<_RGBColor?> _sampleRasterColorAtCanvas(
    Offset canvasPoint, {
    required bool requireVisibleImageOnly,
  }) async {
    final List<MPRuntimeImageInsertConfigMixin> images = _th2FileEditController
        .th2File
        .getImages()
        .toList();

    for (final MPRuntimeImageInsertConfigMixin image in images.reversed) {
      if (requireVisibleImageOnly && !image.isVisible) {
        continue;
      }

      final MPRuntimeRasterImageInsertConfigMixin? rasterImage =
          image.asRasterImage;

      if (rasterImage == null) {
        continue;
      }

      final ui.Image? decodedImage = await _ensureDecodedRasterImageLoaded(
        rasterImage,
      );

      if (decodedImage == null) {
        continue;
      }

      final ({int x, int y})? pixelPosition = _canvasToRasterPixel(
        rasterImage: rasterImage,
        decodedImage: decodedImage,
        canvasPoint: canvasPoint,
      );

      if (pixelPosition == null) {
        continue;
      }

      final ByteData? byteData = await decodedImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (byteData == null) {
        continue;
      }

      final int index =
          ((pixelPosition.y * decodedImage.width) + pixelPosition.x) * 4;

      if (index < 0 || (index + 2) >= byteData.lengthInBytes) {
        continue;
      }

      final Uint8List rgba = byteData.buffer.asUint8List();

      return _RGBColor(r: rgba[index], g: rgba[index + 1], b: rgba[index + 2]);
    }

    return null;
  }

  Future<ui.Image?> _ensureDecodedRasterImageLoaded(
    MPRuntimeRasterImageInsertConfigMixin rasterImage,
  ) async {
    final ui.Image? cachedImage = rasterImage.decodedRasterImage;

    if (cachedImage != null) {
      return cachedImage;
    }

    final Future<ui.Image>? loading = rasterImage.getRasterImageFrameInfo(
      _th2FileEditController,
    );

    if (loading == null) {
      return null;
    }

    return loading;
  }

  ({int x, int y})? _canvasToRasterPixel({
    required MPRuntimeRasterImageInsertConfigMixin rasterImage,
    required ui.Image decodedImage,
    required Offset canvasPoint,
  }) {
    if (rasterImage is! MPImageInsertConfig) {
      return null;
    }

    final MPImageInsertConfig rasterImageConfig =
        rasterImage as MPImageInsertConfig;

    if (rasterImageConfig.xScale.value.abs() < 0.000001 ||
        rasterImageConfig.yScale.value.abs() < 0.000001) {
      return null;
    }

    final Offset translation = Offset(
      rasterImageConfig.xx.value,
      rasterImageConfig.yy.value,
    );
    final Offset pivot = translation + rasterImageConfig.scaledRotationCenter;
    final double angleInRad =
        rasterImageConfig.rotationDeg.value * (pi / 180.0);
    final double cosValue = cos(angleInRad);
    final double sinValue = sin(angleInRad);
    final Offset delta = canvasPoint - pivot;
    final Offset inverseRotated = Offset(
      pivot.dx + delta.dx * cosValue + delta.dy * sinValue,
      pivot.dy - delta.dx * sinValue + delta.dy * cosValue,
    );
    final Offset scaledPoint = inverseRotated - translation;
    final Offset localPoint = Offset(
      scaledPoint.dx / rasterImageConfig.xScale.value,
      scaledPoint.dy / rasterImageConfig.yScale.value,
    );
    final double imageX = localPoint.dx;
    final double imageY = localPoint.dy + decodedImage.height.toDouble();

    if (imageX < 0 ||
        imageY < 0 ||
        imageX >= decodedImage.width ||
        imageY >= decodedImage.height) {
      return null;
    }

    return (x: imageX.floor(), y: imageY.floor());
  }

  int _squaredRGBDistance(_RGBColor a, _RGBColor b) {
    final int dr = a.r - b.r;
    final int dg = a.g - b.g;
    final int db = a.b - b.b;

    return (dr * dr) + (dg * dg) + (db * db);
  }

  void _appendCanvasNode(Offset canvasPoint) {
    final Offset screenPoint = _th2FileEditController.offsetCanvasToScreen(
      canvasPoint,
    );

    _th2FileEditController.areaLineCreationController.addNewLineLineSegment(
      screenPoint,
    );
  }

  void _scrollCanvasToFollow(Offset canvasPoint) {
    _th2FileEditController.centerCanvasOn(canvasPoint);
  }
}

class _TraceContext {
  final Offset currentPoint;
  final Offset startPoint;
  final double stepDistance;
  final _RGBColor targetColor;
  final Offset unitDirection;

  _TraceContext({
    required this.currentPoint,
    required this.startPoint,
    required this.stepDistance,
    required this.targetColor,
    required this.unitDirection,
  });
}

class _RGBColor {
  final int r;
  final int g;
  final int b;

  _RGBColor({required this.r, required this.g, required this.b});
}
