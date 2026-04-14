// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_trace_image_preprocessor.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

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

  final double lookaheadDistanceOnCanvas;

  final TH2FileEditLineTraceColor targetColor;

  const TH2FileEditLineTraceSession({
    required this.stepDistanceOnCanvas,
    required this.lookaheadDistanceOnCanvas,
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
  final TH2FileEditLineTraceLocalColorStrategy _localColorStrategy =
      TH2FileEditLineTraceLocalColorStrategy();

  final TH2FileEditLineTraceCostMapAStarStrategy _costMapAStarStrategy =
      TH2FileEditLineTraceCostMapAStarStrategy();

  /// Returns the tracing strategies in priority order.
  List<TH2FileEditLineTraceStrategy> resolveStrategies() {
    return <TH2FileEditLineTraceStrategy>[
      _localColorStrategy,
      _costMapAStarStrategy,
    ];
  }

  /// Returns the default tracing strategy.
  TH2FileEditLineTraceStrategy resolveDefaultStrategy() {
    return _localColorStrategy;
  }

  /// Clears every strategy-local cache.
  void reset() {
    for (final TH2FileEditLineTraceStrategy strategy in resolveStrategies()) {
      strategy.reset();
    }
  }
}

/// Samples a raster color from the topmost loaded image covering a point.
TH2FileEditLineTraceColor? _sampleRasterColorAtCanvas({
  required TH2FileEditTracePreprocessorCache preprocessorCache,
  required Offset canvasPoint,
}) {
  for (final TH2FileEditTraceImagePreprocessor preprocessor
      in preprocessorCache.orderedPreprocessors) {
    final TH2FileEditLineTraceColor? color = preprocessor.sampleAtCanvas(
      canvasPoint,
    );

    if (color != null) {
      return color;
    }
  }

  return null;
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
      targetColor: session.targetColor,
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

/// Represents a grid-based cost map used by the A* strategy.
class TH2FileEditLineTraceGridCostMap {
  final int width;

  final int height;

  final List<int> costs;

  final int blockedCost;

  const TH2FileEditLineTraceGridCostMap({
    required this.width,
    required this.height,
    required this.costs,
    required this.blockedCost,
  }) : assert(costs.length == width * height);

  int costAt(int x, int y) {
    return costs[(y * width) + x];
  }
}

/// Finds a least-cost path through a grid cost map using A*.
class TH2FileEditLineTraceAStarPathFinder {
  /// Returns the path from [start] to [goal], or a partial path if the goal
  /// cannot be reached within the iteration budget.
  List<Offset>? findPath({
    required TH2FileEditLineTraceGridCostMap costMap,
    required Offset start,
    required Offset goal,
  }) {
    final ({int x, int y})? startCell = _pointToCell(
      point: start,
      width: costMap.width,
      height: costMap.height,
    );
    final ({int x, int y})? goalCell = _pointToCell(
      point: goal,
      width: costMap.width,
      height: costMap.height,
    );

    if (startCell == null || goalCell == null) {
      return null;
    }

    final int startIndex = _cellToIndex(
      x: startCell.x,
      y: startCell.y,
      width: costMap.width,
    );
    final int goalIndex = _cellToIndex(
      x: goalCell.x,
      y: goalCell.y,
      width: costMap.width,
    );

    if (costMap.costAt(startCell.x, startCell.y) >= costMap.blockedCost ||
        costMap.costAt(goalCell.x, goalCell.y) >= costMap.blockedCost) {
      return null;
    }

    if (startIndex == goalIndex) {
      return <Offset>[Offset(startCell.x.toDouble(), startCell.y.toDouble())];
    }

    final int totalCells = costMap.width * costMap.height;
    final List<double> gScore = List<double>.filled(
      totalCells,
      double.infinity,
    );
    final List<int> cameFrom = List<int>.filled(totalCells, -1);
    final List<bool> closed = List<bool>.filled(totalCells, false);
    final HeapPriorityQueue<_AStarQueueEntry> openSet =
        HeapPriorityQueue<_AStarQueueEntry>(_compareQueueEntry);

    gScore[startIndex] = 0.0;
    openSet.add(
      _AStarQueueEntry(
        index: startIndex,
        gScore: 0.0,
        hScore: _heuristic(
          x: startCell.x,
          y: startCell.y,
          goalX: goalCell.x,
          goalY: goalCell.y,
        ),
      ),
    );

    int bestIndex = startIndex;
    double bestHeuristic = _heuristic(
      x: startCell.x,
      y: startCell.y,
      goalX: goalCell.x,
      goalY: goalCell.y,
    );
    int iterations = 0;

    while (openSet.isNotEmpty &&
        iterations < mpLineTraceAStarMaximumIterations) {
      final _AStarQueueEntry current = openSet.removeFirst();

      if (closed[current.index]) {
        continue;
      }

      closed[current.index] = true;
      iterations++;

      if (current.index == goalIndex) {
        return _reconstructPath(
          cameFrom: cameFrom,
          endIndex: current.index,
          width: costMap.width,
        );
      }

      final int currentX = current.index % costMap.width;
      final int currentY = current.index ~/ costMap.width;

      for (final ({int x, int y, double moveCost}) neighbor
          in _neighborsForCell(
            x: currentX,
            y: currentY,
            width: costMap.width,
            height: costMap.height,
          )) {
        final int neighborCost = costMap.costAt(neighbor.x, neighbor.y);

        if (neighborCost >= costMap.blockedCost) {
          continue;
        }

        final int neighborIndex = _cellToIndex(
          x: neighbor.x,
          y: neighbor.y,
          width: costMap.width,
        );
        final double tentativeG =
            gScore[current.index] + (neighbor.moveCost * neighborCost);

        if (tentativeG >= gScore[neighborIndex]) {
          continue;
        }

        cameFrom[neighborIndex] = current.index;
        gScore[neighborIndex] = tentativeG;

        final double heuristic = _heuristic(
          x: neighbor.x,
          y: neighbor.y,
          goalX: goalCell.x,
          goalY: goalCell.y,
        );

        openSet.add(
          _AStarQueueEntry(
            index: neighborIndex,
            gScore: tentativeG,
            hScore: heuristic,
          ),
        );

        if (heuristic < bestHeuristic) {
          bestHeuristic = heuristic;
          bestIndex = neighborIndex;
        }
      }
    }

    if (bestIndex == startIndex) {
      return null;
    }

    return _reconstructPath(
      cameFrom: cameFrom,
      endIndex: bestIndex,
      width: costMap.width,
    );
  }

  int _cellToIndex({required int x, required int y, required int width}) {
    return (y * width) + x;
  }

  double _heuristic({
    required int x,
    required int y,
    required int goalX,
    required int goalY,
  }) {
    final int dx = goalX - x;
    final int dy = goalY - y;

    return sqrt((dx * dx) + (dy * dy));
  }

  ({int x, int y})? _pointToCell({
    required Offset point,
    required int width,
    required int height,
  }) {
    final int cellX = point.dx.round();
    final int cellY = point.dy.round();

    if (cellX < 0 || cellX >= width || cellY < 0 || cellY >= height) {
      return null;
    }

    return (x: cellX, y: cellY);
  }

  List<Offset> _reconstructPath({
    required List<int> cameFrom,
    required int endIndex,
    required int width,
  }) {
    final List<Offset> reversedPath = <Offset>[];
    int currentIndex = endIndex;

    while (currentIndex >= 0) {
      final int x = currentIndex % width;
      final int y = currentIndex ~/ width;

      reversedPath.add(Offset(x.toDouble(), y.toDouble()));

      currentIndex = cameFrom[currentIndex];
    }

    return reversedPath.reversed.toList(growable: false);
  }

  Iterable<({int x, int y, double moveCost})> _neighborsForCell({
    required int x,
    required int y,
    required int width,
    required int height,
  }) sync* {
    const List<({int dx, int dy, double moveCost})> deltas =
        <({int dx, int dy, double moveCost})>[
          (dx: -1, dy: -1, moveCost: 1.4142135623730951),
          (dx: 0, dy: -1, moveCost: 1.0),
          (dx: 1, dy: -1, moveCost: 1.4142135623730951),
          (dx: -1, dy: 0, moveCost: 1.0),
          (dx: 1, dy: 0, moveCost: 1.0),
          (dx: -1, dy: 1, moveCost: 1.4142135623730951),
          (dx: 0, dy: 1, moveCost: 1.0),
          (dx: 1, dy: 1, moveCost: 1.4142135623730951),
        ];

    for (final ({int dx, int dy, double moveCost}) delta in deltas) {
      final int nextX = x + delta.dx;
      final int nextY = y + delta.dy;

      if (nextX < 0 || nextX >= width || nextY < 0 || nextY >= height) {
        continue;
      }

      yield (x: nextX, y: nextY, moveCost: delta.moveCost);
    }
  }

  int _compareQueueEntry(_AStarQueueEntry a, _AStarQueueEntry b) {
    final int fScoreComparison = a.fScore.compareTo(b.fScore);

    if (fScoreComparison != 0) {
      return fScoreComparison;
    }

    return a.hScore.compareTo(b.hScore);
  }
}

class _AStarQueueEntry implements Comparable<_AStarQueueEntry> {
  final int index;

  final double gScore;

  final double hScore;

  double get fScore => gScore + hScore;

  _AStarQueueEntry({
    required this.index,
    required this.gScore,
    required this.hScore,
  });

  @override
  int compareTo(_AStarQueueEntry other) {
    final int fScoreComparison = fScore.compareTo(other.fScore);

    if (fScoreComparison != 0) {
      return fScoreComparison;
    }

    return hScore.compareTo(other.hScore);
  }
}

/// Implements cost-map pathfinding with an A* grid search.
class TH2FileEditLineTraceCostMapAStarStrategy
    implements TH2FileEditLineTraceStrategy {
  final TH2FileEditTracePreprocessorCache _preprocessorCache =
      TH2FileEditTracePreprocessorCache();

  final TH2FileEditLineTraceAStarPathFinder _pathFinder =
      TH2FileEditLineTraceAStarPathFinder();

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

    final List<double> lookaheadAttempts = <double>[
      traceContext.lookaheadDistance,
      traceContext.lookaheadDistance / 2.0,
      traceContext.lookaheadDistance * 1.5,
    ];

    for (final double lookaheadDistance in lookaheadAttempts) {
      if (lookaheadDistance < mpLineTraceAStarMinimumCellSizeOnCanvas) {
        continue;
      }

      final _AStarSearchWindow? searchWindow = _buildSearchWindow(
        traceContext: traceContext,
        lookaheadDistance: lookaheadDistance,
      );

      if (searchWindow == null) {
        continue;
      }

      final List<Offset>? gridPath = _pathFinder.findPath(
        costMap: searchWindow.costMap,
        start: searchWindow.startCell,
        goal: searchWindow.goalCell,
      );

      if (gridPath == null || gridPath.length < 2) {
        continue;
      }

      final Offset nextCanvasPoint = searchWindow.gridCellCenterToCanvas(
        gridPath[1],
      );
      final double tracedDistanceFromCurrent =
          (nextCanvasPoint - traceContext.currentPoint).distance;

      if (tracedDistanceFromCurrent < 0.5) {
        continue;
      }

      final bool shouldAutoClose =
          (nextCanvasPoint - traceContext.startPoint).distance <=
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

      _appendCanvasNode(context: context, canvasPoint: nextCanvasPoint);
      _scrollCanvasToFollow(context: context, canvasPoint: nextCanvasPoint);

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
      goalPoint:
          currentPoint + (unitDirection * session.lookaheadDistanceOnCanvas),
      stepDistance: session.stepDistanceOnCanvas,
      targetColor: session.targetColor,
      unitDirection: unitDirection,
      lookaheadDistance: session.lookaheadDistanceOnCanvas,
    );
  }

  _AStarSearchWindow? _buildSearchWindow({
    required _TraceContext traceContext,
    required double lookaheadDistance,
  }) {
    final Offset lookaheadPoint =
        traceContext.currentPoint +
        (traceContext.unitDirection * lookaheadDistance);
    final double padding = max(
      traceContext.stepDistance,
      lookaheadDistance * mpLineTraceAStarSearchPaddingFactor,
    );
    final Rect baseBounds = Rect.fromPoints(
      traceContext.currentPoint,
      lookaheadPoint,
    );
    final Rect searchBounds = baseBounds.inflate(padding);
    final double cellSizeOnCanvas = max(
      mpLineTraceAStarMinimumCellSizeOnCanvas,
      traceContext.stepDistance / 2.0,
    );
    final int width = min(
      mpLineTraceAStarMaximumGridDimension,
      max(2, (searchBounds.width / cellSizeOnCanvas).ceil() + 1),
    );
    final int height = min(
      mpLineTraceAStarMaximumGridDimension,
      max(2, (searchBounds.height / cellSizeOnCanvas).ceil() + 1),
    );
    final Offset origin = searchBounds.topLeft;
    final List<int> costs = List<int>.filled(
      width * height,
      mpLineTraceAStarBlockedCost,
    );

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final Offset canvasPoint = Offset(
          origin.dx + ((x + 0.5) * cellSizeOnCanvas),
          origin.dy + ((y + 0.5) * cellSizeOnCanvas),
        );
        final int cost = _estimateCellCost(
          canvasPoint: canvasPoint,
          cellSizeOnCanvas: cellSizeOnCanvas,
          targetColor: traceContext.targetColor,
        );
        costs[(y * width) + x] = cost;
      }
    }

    final ({int x, int y})? startCell = _gridPointForCanvasPoint(
      point: traceContext.currentPoint,
      origin: origin,
      cellSizeOnCanvas: cellSizeOnCanvas,
      width: width,
      height: height,
    );
    final ({int x, int y})? goalCell = _gridPointForCanvasPoint(
      point: lookaheadPoint,
      origin: origin,
      cellSizeOnCanvas: cellSizeOnCanvas,
      width: width,
      height: height,
    );

    if (startCell == null || goalCell == null) {
      return null;
    }

    final TH2FileEditLineTraceGridCostMap costMap =
        TH2FileEditLineTraceGridCostMap(
          width: width,
          height: height,
          costs: costs,
          blockedCost: mpLineTraceAStarBlockedCost,
        );

    final int startIndex = (startCell.y * width) + startCell.x;
    final int goalIndex = (goalCell.y * width) + goalCell.x;
    final int startCost = _estimateCellCost(
      canvasPoint: traceContext.currentPoint,
      cellSizeOnCanvas: cellSizeOnCanvas,
      targetColor: traceContext.targetColor,
    );
    final int goalCost = _estimateCellCost(
      canvasPoint: lookaheadPoint,
      cellSizeOnCanvas: cellSizeOnCanvas,
      targetColor: traceContext.targetColor,
    );

    costs[startIndex] = min(costs[startIndex], startCost);
    costs[goalIndex] = min(costs[goalIndex], goalCost);

    return _AStarSearchWindow(
      origin: origin,
      cellSizeOnCanvas: cellSizeOnCanvas,
      costMap: costMap,
      startCell: Offset(startCell.x.toDouble(), startCell.y.toDouble()),
      goalCell: Offset(goalCell.x.toDouble(), goalCell.y.toDouble()),
    );
  }

  int _estimateCellCost({
    required Offset canvasPoint,
    required double cellSizeOnCanvas,
    required TH2FileEditLineTraceColor targetColor,
  }) {
    final TH2FileEditLineTraceColor? centerColor = _sampleRasterColorAtCanvas(
      preprocessorCache: _preprocessorCache,
      canvasPoint: canvasPoint,
    );

    if (centerColor == null) {
      return mpLineTraceAStarBlockedCost;
    }

    final List<Offset> neighbors = <Offset>[
      Offset(canvasPoint.dx + cellSizeOnCanvas, canvasPoint.dy),
      Offset(canvasPoint.dx - cellSizeOnCanvas, canvasPoint.dy),
      Offset(canvasPoint.dx, canvasPoint.dy + cellSizeOnCanvas),
      Offset(canvasPoint.dx, canvasPoint.dy - cellSizeOnCanvas),
    ];
    int sampledNeighborCount = 0;
    double accumulatedNeighborDifference = 0.0;

    for (final Offset neighborPoint in neighbors) {
      final TH2FileEditLineTraceColor? neighborColor =
          _sampleRasterColorAtCanvas(
            preprocessorCache: _preprocessorCache,
            canvasPoint: neighborPoint,
          );

      if (neighborColor == null) {
        continue;
      }

      sampledNeighborCount++;
      accumulatedNeighborDifference += _normalizedColorDistance(
        centerColor,
        neighborColor,
      );
    }

    final double averageNeighborDifference = sampledNeighborCount == 0
        ? 0.0
        : accumulatedNeighborDifference / sampledNeighborCount.toDouble();
    final double targetColorMatch = _normalizedColorDistance(
      centerColor,
      targetColor,
    );
    final double edgePreference = 1.0 - averageNeighborDifference;
    final double rawCost = (targetColorMatch * 220.0) - (edgePreference * 40.0);

    return rawCost.round().clamp(1, mpLineTraceAStarBlockedCost - 1);
  }

  ({int x, int y})? _gridPointForCanvasPoint({
    required Offset point,
    required Offset origin,
    required double cellSizeOnCanvas,
    required int width,
    required int height,
  }) {
    final int cellX = ((point.dx - origin.dx) / cellSizeOnCanvas).round();
    final int cellY = ((point.dy - origin.dy) / cellSizeOnCanvas).round();

    if (cellX < 0 || cellX >= width || cellY < 0 || cellY >= height) {
      return null;
    }

    return (x: cellX, y: cellY);
  }

  double _normalizedColorDistance(
    TH2FileEditLineTraceColor a,
    TH2FileEditLineTraceColor b,
  ) {
    final int dr = a.red - b.red;
    final int dg = a.green - b.green;
    final int db = a.blue - b.blue;
    final double squaredDistance = ((dr * dr) + (dg * dg) + (db * db))
        .toDouble();
    const double maxSquaredDistance = 195075.0;

    return squaredDistance / maxSquaredDistance;
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

/// Holds the search window used by the A* strategy.
class _AStarSearchWindow {
  final Offset origin;

  final double cellSizeOnCanvas;

  final TH2FileEditLineTraceGridCostMap costMap;

  final Offset startCell;

  final Offset goalCell;

  _AStarSearchWindow({
    required this.origin,
    required this.cellSizeOnCanvas,
    required this.costMap,
    required this.startCell,
    required this.goalCell,
  });

  Offset gridCellCenterToCanvas(Offset gridCell) {
    return Offset(
      origin.dx + ((gridCell.dx + 0.5) * cellSizeOnCanvas),
      origin.dy + ((gridCell.dy + 0.5) * cellSizeOnCanvas),
    );
  }
}

class _TraceContext {
  final Offset currentPoint;

  final Offset startPoint;

  final Offset goalPoint;

  final double stepDistance;

  final TH2FileEditLineTraceColor targetColor;

  final Offset unitDirection;

  final double lookaheadDistance;

  _TraceContext({
    required this.currentPoint,
    required this.startPoint,
    required this.goalPoint,
    required this.stepDistance,
    required this.targetColor,
    required this.unitDirection,
    required this.lookaheadDistance,
  });
}
