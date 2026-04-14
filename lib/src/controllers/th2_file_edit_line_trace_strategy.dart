// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_trace_image_preprocessor.dart';

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

  final TH2FileEditTracePreprocessorCache _preprocessorCache =
      TH2FileEditTracePreprocessorCache();

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

    await _preprocessorCache.warmUp(
      th2FileEditController: context.th2FileEditController,
    );

    final TH2FileEditLineTraceColor? sampledColor = _sampleRasterColorAtCanvas(
      lineNodes.last,
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

      final Offset? tracedPoint = _findNextPoint(
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
    _preprocessorCache.clear();
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

  Offset? _findNextPoint({
    required TH2FileEditLineTraceContext context,
    required _TraceContext traceContext,
    required double localStepDistance,
  }) {
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
          _sampleRasterColorAtCanvas(candidate);

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

  /// Returns the RGB color at [canvasPoint] from the topmost visible raster
  /// image that covers that point, or null if no loaded image covers it.
  ///
  /// This method is synchronous because all images are pre-loaded by
  /// [TH2FileEditTracePreprocessorCache.warmUp] during session preparation.
  TH2FileEditLineTraceColor? _sampleRasterColorAtCanvas(Offset canvasPoint) {
    for (final TH2FileEditTraceImagePreprocessor preprocessor
        in _preprocessorCache.orderedPreprocessors) {
      final TH2FileEditLineTraceColor? color = preprocessor.sampleAtCanvas(
        canvasPoint,
      );

      if (color != null) {
        return color;
      }
    }

    return null;
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
