// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';

/// Coordinates the tracing strategy boundary used by the line-trace controller.
class TH2FileEditLineTraceContext {
  final TH2FileEditController th2FileEditController;

  final TH2FileEditLineTraceSession? session;

  TH2FileEditLineTraceContext({
    required this.th2FileEditController,
    required this.session,
  });

  /// Returns the current interactive line nodes in canvas coordinates.
  List<Offset> get lineNodes => th2FileEditController.areaLineCreationController
      .getCurrentInteractiveLineNodeCanvasCoordinates();

  /// Returns whether tracing is still active.
  bool get isTracing => th2FileEditController.lineTraceController.isTracing;

  /// Returns whether the add-line state is currently active.
  bool get isInAddLineState => th2FileEditController.isInAddLineState;
}

/// Describes the prepared state for a trace session.
class TH2FileEditLineTraceSession {
  final double stepDistanceOnCanvas;

  final TH2FileEditLineTraceColor targetColor;

  const TH2FileEditLineTraceSession({
    required this.stepDistanceOnCanvas,
    required this.targetColor,
  });
}

/// Represents a sampled RGB color from a raster image.
class TH2FileEditLineTraceColor {
  final int red;

  final int green;

  final int blue;

  const TH2FileEditLineTraceColor({
    required this.red,
    required this.green,
    required this.blue,
  });
}

/// Reports whether a trace step advanced the line or requested a stop.
class TH2FileEditLineTraceStepResult {
  final bool didProgress;

  final bool shouldStopTracing;

  const TH2FileEditLineTraceStepResult({
    required this.didProgress,
    required this.shouldStopTracing,
  });

  /// Returns the result used when tracing cannot advance.
  const TH2FileEditLineTraceStepResult.failed()
    : didProgress = false,
      shouldStopTracing = false;
}

/// Defines the contract for a line-tracing algorithm.
abstract class TH2FileEditLineTraceStrategy {
  /// Prepares a trace session for the current interactive line.
  Future<TH2FileEditLineTraceSession?> prepareSession({
    required TH2FileEditLineTraceContext context,
  });

  /// Computes the next tracing step for the prepared session.
  Future<TH2FileEditLineTraceStepResult> traceSingleStep({
    required TH2FileEditLineTraceContext context,
  });

  /// Clears strategy-local caches.
  void reset();
}

/// Resolves the default line-trace strategy.
class TH2FileEditLineTraceStrategyRegistry {
  /// Returns the default tracing strategy.
  TH2FileEditLineTraceStrategy resolveDefaultStrategy() {
    return TH2FileEditLineTraceLocalColorStrategy();
  }
}

/// Implements the current color-guided tracing behavior.
class TH2FileEditLineTraceLocalColorStrategy
    implements TH2FileEditLineTraceStrategy {
  static const int _strictColorDistanceThreshold = 1600;
  static const int _fallbackColorDistanceThreshold = 6400;
  static const int _maxArcSampleCount = 48;
  static const double _minTraceProgressOnCanvas = 0.75;

  final Map<ui.Image, Uint8List> _rawRgbaCacheByImage = <ui.Image, Uint8List>{};

  @override
  Future<TH2FileEditLineTraceSession?> prepareSession({
    required TH2FileEditLineTraceContext context,
  }) async {
    if (!context.isInAddLineState) {
      return null;
    }

    final List<Offset> lineNodes = context.lineNodes;

    if (lineNodes.length < 2) {
      return null;
    }

    final TH2FileEditLineTraceColor? sampledColor =
        await _sampleRasterColorAtCanvas(
          context: context,
          canvasPoint: lineNodes.last,
          requireVisibleImageOnly: true,
        );

    if (sampledColor == null) {
      return null;
    }

    final double fixedStepDistance = max(
      1.0,
      (lineNodes.last - lineNodes[lineNodes.length - 2]).distance,
    );

    return TH2FileEditLineTraceSession(
      stepDistanceOnCanvas: fixedStepDistance,
      targetColor: sampledColor,
    );
  }

  @override
  Future<TH2FileEditLineTraceStepResult> traceSingleStep({
    required TH2FileEditLineTraceContext context,
  }) async {
    final _TraceContext? traceContext = _createTraceContext(context);

    if (traceContext == null) {
      return const TH2FileEditLineTraceStepResult.failed();
    }

    final List<double> localStepAttempts = <double>[
      traceContext.stepDistance,
      traceContext.stepDistance / 2.0,
      traceContext.stepDistance * 2.0,
    ];

    for (final double localStepDistance in localStepAttempts) {
      if (localStepDistance < 1.0) {
        continue;
      }

      final Offset? tracedPoint = await _findNextPoint(
        context: context,
        traceContext: traceContext,
        localStepDistance: localStepDistance,
      );

      if (tracedPoint == null) {
        continue;
      }

      final double tracedDistanceFromCurrent =
          (tracedPoint - traceContext.currentPoint).distance;

      if (tracedDistanceFromCurrent < _minTraceProgressOnCanvas) {
        continue;
      }

      final bool shouldAutoClose =
          (tracedPoint - traceContext.startPoint).distance <=
          traceContext.stepDistance;

      if (shouldAutoClose) {
        _appendCanvasNode(
          context: context,
          canvasPoint: traceContext.startPoint,
        );
        context.th2FileEditController.lineTraceController.stopTracing();

        return const TH2FileEditLineTraceStepResult(
          didProgress: true,
          shouldStopTracing: true,
        );
      }

      _appendCanvasNode(context: context, canvasPoint: tracedPoint);
      _scrollCanvasToFollow(context: context, canvasPoint: tracedPoint);

      return const TH2FileEditLineTraceStepResult(
        didProgress: true,
        shouldStopTracing: false,
      );
    }

    return const TH2FileEditLineTraceStepResult.failed();
  }

  @override
  void reset() {
    _rawRgbaCacheByImage.clear();
  }

  _TraceContext? _createTraceContext(TH2FileEditLineTraceContext context) {
    final TH2FileEditLineTraceSession? session = context.session;

    if (session == null) {
      return null;
    }

    final List<Offset> lineNodes = context.lineNodes;

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
      stepDistance: session.stepDistanceOnCanvas,
      targetColor: session.targetColor,
      unitDirection: unitDirection,
    );
  }

  Future<Offset?> _findNextPoint({
    required TH2FileEditLineTraceContext context,
    required _TraceContext traceContext,
    required double localStepDistance,
  }) async {
    final Offset arcCenter =
        traceContext.currentPoint +
        (traceContext.unitDirection * localStepDistance);
    final int sampleCount = min(
      _maxArcSampleCount,
      max(24, (localStepDistance * 12.0).round()),
    );
    final List<Offset> matchingArcPoints = <Offset>[];
    final List<List<Offset>> matchingArcs = <List<Offset>>[];
    Offset? bestCandidate;
    int bestCandidateDistance = 2147483647;

    for (int i = 0; i < sampleCount; i++) {
      if (!context.isTracing) {
        return null;
      }

      final double angle = (2.0 * pi * i) / sampleCount;
      final Offset radial = Offset(cos(angle), sin(angle));
      final Offset candidate = arcCenter + (radial * localStepDistance);
      final double aheadDot =
          ((candidate - traceContext.currentPoint).dx *
              traceContext.unitDirection.dx) +
          ((candidate - traceContext.currentPoint).dy *
              traceContext.unitDirection.dy);

      if (aheadDot < 0) {
        if (matchingArcPoints.isNotEmpty) {
          matchingArcs.add(List<Offset>.from(matchingArcPoints));
          matchingArcPoints.clear();
        }

        continue;
      }

      final TH2FileEditLineTraceColor? candidateColor =
          await _sampleRasterColorAtCanvas(
            context: context,
            canvasPoint: candidate,
            requireVisibleImageOnly: true,
          );

      if (candidateColor != null) {
        final int distance = _squaredRGBDistance(
          candidateColor,
          traceContext.targetColor,
        );

        if (distance < bestCandidateDistance) {
          bestCandidateDistance = distance;
          bestCandidate = candidate;
        }

        if (distance <= _strictColorDistanceThreshold) {
          matchingArcPoints.add(candidate);
        } else if (matchingArcPoints.isNotEmpty) {
          matchingArcs.add(List<Offset>.from(matchingArcPoints));
          matchingArcPoints.clear();
        }
      } else if (matchingArcPoints.isNotEmpty) {
        matchingArcs.add(List<Offset>.from(matchingArcPoints));
        matchingArcPoints.clear();
      }
    }

    if (matchingArcPoints.isNotEmpty) {
      matchingArcs.add(List<Offset>.from(matchingArcPoints));
    }

    if (matchingArcs.isEmpty) {
      if (bestCandidate != null &&
          bestCandidateDistance <= _fallbackColorDistanceThreshold) {
        return bestCandidate;
      }

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

  Future<TH2FileEditLineTraceColor?> _sampleRasterColorAtCanvas({
    required TH2FileEditLineTraceContext context,
    required Offset canvasPoint,
    required bool requireVisibleImageOnly,
  }) async {
    final List<MPRuntimeImageInsertConfigMixin> images = context
        .th2FileEditController
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
        context: context,
        rasterImage: rasterImage,
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

      Uint8List? rgba = _rawRgbaCacheByImage[decodedImage];

      if (rgba == null) {
        final ByteData? byteData = await decodedImage.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );

        if (byteData == null) {
          continue;
        }

        rgba = byteData.buffer.asUint8List();
        _rawRgbaCacheByImage[decodedImage] = rgba;
      }

      final int index =
          ((pixelPosition.y * decodedImage.width) + pixelPosition.x) * 4;

      if (index < 0 || (index + 2) >= rgba.length) {
        continue;
      }

      return TH2FileEditLineTraceColor(
        red: rgba[index],
        green: rgba[index + 1],
        blue: rgba[index + 2],
      );
    }

    return null;
  }

  Future<ui.Image?> _ensureDecodedRasterImageLoaded({
    required TH2FileEditLineTraceContext context,
    required MPRuntimeRasterImageInsertConfigMixin rasterImage,
  }) async {
    final ui.Image? cachedImage = rasterImage.decodedRasterImage;

    if (cachedImage != null) {
      return cachedImage;
    }

    final Future<ui.Image>? loading = rasterImage.getRasterImageFrameInfo(
      context.th2FileEditController,
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
    final double imageWidth = decodedImage.width.toDouble();
    final double imageHeight = decodedImage.height.toDouble();

    final Offset topLeft = rasterImage.transformWorldPointFromBaseWorldPoint(
      Offset(rasterImage.xx.value, rasterImage.yy.value - imageHeight),
    );
    final Offset topRight = rasterImage.transformWorldPointFromBaseWorldPoint(
      Offset(
        rasterImage.xx.value + imageWidth,
        rasterImage.yy.value - imageHeight,
      ),
    );
    final Offset bottomLeft = rasterImage.transformWorldPointFromBaseWorldPoint(
      Offset(rasterImage.xx.value, rasterImage.yy.value),
    );

    final Offset xAxis = topRight - topLeft;
    final Offset yAxis = bottomLeft - topLeft;
    final double xAxisLengthSquared =
        (xAxis.dx * xAxis.dx) + (xAxis.dy * xAxis.dy);
    final double yAxisLengthSquared =
        (yAxis.dx * yAxis.dx) + (yAxis.dy * yAxis.dy);

    if (xAxisLengthSquared <= 0.000001 || yAxisLengthSquared <= 0.000001) {
      return null;
    }

    final Offset relativePoint = canvasPoint - topLeft;
    final double imageX =
        ((relativePoint.dx * xAxis.dx) + (relativePoint.dy * xAxis.dy)) /
        xAxisLengthSquared *
        imageWidth;
    final double imageY =
        ((relativePoint.dx * yAxis.dx) + (relativePoint.dy * yAxis.dy)) /
        yAxisLengthSquared *
        imageHeight;

    if (imageX < 0 ||
        imageY < 0 ||
        imageX >= imageWidth ||
        imageY >= imageHeight) {
      return null;
    }

    final int pixelX = imageX.floor();
    final int pixelY = (imageHeight - 1.0 - imageY).floor();

    return (x: pixelX, y: pixelY);
  }

  int _squaredRGBDistance(
    TH2FileEditLineTraceColor a,
    TH2FileEditLineTraceColor b,
  ) {
    final int dr = a.red - b.red;
    final int dg = a.green - b.green;
    final int db = a.blue - b.blue;

    return (dr * dr) + (dg * dg) + (db * db);
  }

  void _appendCanvasNode({
    required TH2FileEditLineTraceContext context,
    required Offset canvasPoint,
  }) {
    final Offset screenPoint = context.th2FileEditController
        .offsetCanvasToScreen(canvasPoint);

    context.th2FileEditController.areaLineCreationController
        .addNewLineLineSegment(screenPoint);
  }

  void _scrollCanvasToFollow({
    required TH2FileEditLineTraceContext context,
    required Offset canvasPoint,
  }) {
    context.th2FileEditController.centerCanvasOn(canvasPoint);
  }
}

class _TraceContext {
  final Offset currentPoint;

  final Offset startPoint;

  final double stepDistance;

  final TH2FileEditLineTraceColor targetColor;

  final Offset unitDirection;

  _TraceContext({
    required this.currentPoint,
    required this.startPoint,
    required this.stepDistance,
    required this.targetColor,
    required this.unitDirection,
  });
}
