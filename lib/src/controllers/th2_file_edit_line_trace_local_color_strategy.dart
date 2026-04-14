// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

part of 'th2_file_edit_line_trace_strategy.dart';

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
  MPLineTraceInteractionType get interactionType =>
      MPLineTraceInteractionType.continuous;

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
      preprocessorCache: _preprocessorCache,
      canvasPoint: lineNodes.last,
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
      lookaheadDistanceOnCanvas:
          fixedStepDistance * mpLineTraceAStarLookaheadMultiplier,
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
  Future<List<Offset>?> buildPreviewPath({
    required TH2FileEditLineTraceContext context,
    required Offset startAnchor,
    required Offset goalAnchor,
  }) async {
    return null;
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
      goalPoint:
          currentPoint + (unitDirection * session.lookaheadDistanceOnCanvas),
      stepDistance: session.stepDistanceOnCanvas,
      targetColor: session.targetColor!,
      unitDirection: unitDirection,
      lookaheadDistance: session.lookaheadDistanceOnCanvas,
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
          _sampleRasterColorAtCanvas(
            preprocessorCache: _preprocessorCache,
            canvasPoint: candidate,
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

  /// Returns the squared RGB distance between two sampled colors.
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
