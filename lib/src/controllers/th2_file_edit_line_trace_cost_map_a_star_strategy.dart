// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

part of 'th2_file_edit_line_trace_strategy.dart';

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
    final _AStarEndpoints? endpoints = _resolveEndpoints(
      costMap: costMap,
      start: start,
      goal: goal,
    );

    if (endpoints == null) {
      return null;
    }

    if (endpoints.startIndex == endpoints.goalIndex) {
      return <Offset>[
        Offset(
          endpoints.startCell.x.toDouble(),
          endpoints.startCell.y.toDouble(),
        ),
      ];
    }

    final _AStarSearchState state = _createSearchState(
      costMap: costMap,
      endpoints: endpoints,
    );

    final int? endIndex = _runSearch(
      costMap: costMap,
      endpoints: endpoints,
      state: state,
    );

    if (endIndex == null) {
      return null;
    }

    return _reconstructPath(
      cameFrom: state.cameFrom,
      endIndex: endIndex,
      width: costMap.width,
    );
  }

  _AStarEndpoints? _resolveEndpoints({
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

    if ((startCell == null) || (goalCell == null)) {
      return null;
    }

    if ((costMap.costAt(startCell.x, startCell.y) >= costMap.blockedCost) ||
        (costMap.costAt(goalCell.x, goalCell.y) >= costMap.blockedCost)) {
      return null;
    }

    return _AStarEndpoints(
      startCell: startCell,
      goalCell: goalCell,
      startIndex: _cellToIndex(
        x: startCell.x,
        y: startCell.y,
        width: costMap.width,
      ),
      goalIndex: _cellToIndex(
        x: goalCell.x,
        y: goalCell.y,
        width: costMap.width,
      ),
    );
  }

  _AStarSearchState _createSearchState({
    required TH2FileEditLineTraceGridCostMap costMap,
    required _AStarEndpoints endpoints,
  }) {
    final int totalCells = costMap.width * costMap.height;
    final List<double> gScore = List<double>.filled(
      totalCells,
      double.infinity,
    );
    final List<int> cameFrom = List<int>.filled(totalCells, -1);
    final List<bool> closed = List<bool>.filled(totalCells, false);
    final HeapPriorityQueue<_AStarQueueEntry> openSet =
        HeapPriorityQueue<_AStarQueueEntry>(_compareQueueEntry);
    final double startHeuristic = _heuristic(
      x: endpoints.startCell.x,
      y: endpoints.startCell.y,
      goalX: endpoints.goalCell.x,
      goalY: endpoints.goalCell.y,
    );

    gScore[endpoints.startIndex] = 0.0;
    openSet.add(
      _AStarQueueEntry(
        index: endpoints.startIndex,
        gScore: 0.0,
        hScore: startHeuristic,
      ),
    );

    return _AStarSearchState(
      gScore: gScore,
      cameFrom: cameFrom,
      closed: closed,
      openSet: openSet,
      bestIndex: endpoints.startIndex,
      bestHeuristic: startHeuristic,
    );
  }

  int? _runSearch({
    required TH2FileEditLineTraceGridCostMap costMap,
    required _AStarEndpoints endpoints,
    required _AStarSearchState state,
  }) {
    int iterations = 0;

    while (state.openSet.isNotEmpty &&
        (iterations < mpLineTraceAStarMaximumIterations)) {
      final _AStarQueueEntry current = state.openSet.removeFirst();

      if (state.closed[current.index]) {
        continue;
      }

      state.closed[current.index] = true;
      iterations++;

      if (current.index == endpoints.goalIndex) {
        return current.index;
      }

      _visitNeighbors(
        costMap: costMap,
        endpoints: endpoints,
        state: state,
        currentIndex: current.index,
      );
    }

    if (state.bestIndex == endpoints.startIndex) {
      return null;
    }

    return state.bestIndex;
  }

  void _visitNeighbors({
    required TH2FileEditLineTraceGridCostMap costMap,
    required _AStarEndpoints endpoints,
    required _AStarSearchState state,
    required int currentIndex,
  }) {
    final int currentX = currentIndex % costMap.width;
    final int currentY = currentIndex ~/ costMap.width;

    for (final ({int x, int y, double moveCost}) neighbor in _neighborsForCell(
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
          state.gScore[currentIndex] + (neighbor.moveCost * neighborCost);

      if (tentativeG >= state.gScore[neighborIndex]) {
        continue;
      }

      final double heuristic = _heuristic(
        x: neighbor.x,
        y: neighbor.y,
        goalX: endpoints.goalCell.x,
        goalY: endpoints.goalCell.y,
      );

      state.cameFrom[neighborIndex] = currentIndex;
      state.gScore[neighborIndex] = tentativeG;
      state.openSet.add(
        _AStarQueueEntry(
          index: neighborIndex,
          gScore: tentativeG,
          hScore: heuristic,
        ),
      );
      _updateBestCandidate(
        state: state,
        candidateIndex: neighborIndex,
        heuristic: heuristic,
      );
    }
  }

  void _updateBestCandidate({
    required _AStarSearchState state,
    required int candidateIndex,
    required double heuristic,
  }) {
    if (heuristic < state.bestHeuristic) {
      state.bestHeuristic = heuristic;
      state.bestIndex = candidateIndex;
    }
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

    if ((cellX < 0) || (cellX >= width) || (cellY < 0) || (cellY >= height)) {
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
          (dx: -1, dy: -1, moveCost: mpLineTraceAStarDiagonalMoveCost),
          (dx: 0, dy: -1, moveCost: 1.0),
          (dx: 1, dy: -1, moveCost: mpLineTraceAStarDiagonalMoveCost),
          (dx: -1, dy: 0, moveCost: 1.0),
          (dx: 1, dy: 0, moveCost: 1.0),
          (dx: -1, dy: 1, moveCost: mpLineTraceAStarDiagonalMoveCost),
          (dx: 0, dy: 1, moveCost: 1.0),
          (dx: 1, dy: 1, moveCost: mpLineTraceAStarDiagonalMoveCost),
        ];

    for (final ({int dx, int dy, double moveCost}) delta in deltas) {
      final int nextX = x + delta.dx;
      final int nextY = y + delta.dy;

      if ((nextX < 0) || (nextX >= width) || (nextY < 0) || (nextY >= height)) {
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

class _AStarEndpoints {
  final ({int x, int y}) startCell;

  final ({int x, int y}) goalCell;

  final int startIndex;

  final int goalIndex;

  _AStarEndpoints({
    required this.startCell,
    required this.goalCell,
    required this.startIndex,
    required this.goalIndex,
  });
}

class _AStarSearchState {
  final List<double> gScore;

  final List<int> cameFrom;

  final List<bool> closed;

  final HeapPriorityQueue<_AStarQueueEntry> openSet;

  int bestIndex;

  double bestHeuristic;

  _AStarSearchState({
    required this.gScore,
    required this.cameFrom,
    required this.closed,
    required this.openSet,
    required this.bestIndex,
    required this.bestHeuristic,
  });
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
  MPLineTraceInteractionType get interactionType =>
      MPLineTraceInteractionType.waypointAnchored;

  @override
  Future<TH2FileEditLineTraceSession?> prepareSession({
    required TH2FileEditLineTraceContext context,
  }) async {
    if (!context.isInAddLineState) {
      return null;
    }

    await _preprocessorCache.warmUp(
      th2FileEditController: context.th2FileEditController,
    );

    return TH2FileEditLineTraceSession(
      stepDistanceOnCanvas: mpLineTraceAStarMinimumCellSizeOnCanvas,
      lookaheadDistanceOnCanvas: mpLineTraceAStarMinimumCellSizeOnCanvas,
      targetColor: null,
    );
  }

  @override
  Future<TH2FileEditLineTraceStepResult> traceSingleStep({
    required TH2FileEditLineTraceContext context,
  }) async {
    return const TH2FileEditLineTraceStepResult.failed();
  }

  @override
  Future<List<Offset>?> buildPreviewPath({
    required TH2FileEditLineTraceContext context,
    required Offset startAnchor,
    required Offset goalAnchor,
  }) async {
    final TH2FileEditLineTraceColor? sampledColor = _sampleRasterColorAtCanvas(
      preprocessorCache: _preprocessorCache,
      canvasPoint: startAnchor,
    );

    if (sampledColor == null) {
      return null;
    }

    final _AStarSearchWindow? searchWindow = _buildSearchWindowForAnchors(
      startAnchor: startAnchor,
      goalAnchor: goalAnchor,
      targetColor: sampledColor,
    );

    if (searchWindow == null) {
      return null;
    }

    final List<Offset>? gridPath = _pathFinder.findPath(
      costMap: searchWindow.costMap,
      start: searchWindow.startCell,
      goal: searchWindow.goalCell,
    );

    if ((gridPath == null) || gridPath.isEmpty) {
      return null;
    }

    final List<Offset> previewPath = <Offset>[
      startAnchor,
      ...gridPath
          .skip(1)
          .take(max(0, gridPath.length - 2))
          .map(searchWindow.gridCellCenterToCanvas),
      goalAnchor,
    ];

    return previewPath;
  }

  @override
  void reset() {
    _preprocessorCache.clear();
  }

  _AStarSearchWindow? _buildSearchWindowForAnchors({
    required Offset startAnchor,
    required Offset goalAnchor,
    required TH2FileEditLineTraceColor targetColor,
  }) {
    final double anchorDistance = (goalAnchor - startAnchor).distance;
    final double padding = max(
      mpLineTraceAStarMinimumCellSizeOnCanvas,
      anchorDistance * mpLineTraceAStarSearchPaddingFactor,
    );
    final Rect baseBounds = Rect.fromPoints(startAnchor, goalAnchor);
    final Rect searchBounds = baseBounds.inflate(padding);
    final double cellSizeOnCanvas = max(
      mpLineTraceAStarMinimumCellSizeOnCanvas,
      anchorDistance / mpLineTraceAStarMaximumGridDimension,
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
          origin.dx +
              ((x + mpLineTraceAStarCellCenterOffset) * cellSizeOnCanvas),
          origin.dy +
              ((y + mpLineTraceAStarCellCenterOffset) * cellSizeOnCanvas),
        );
        final int cost = _estimateCellCost(
          canvasPoint: canvasPoint,
          cellSizeOnCanvas: cellSizeOnCanvas,
          targetColor: targetColor,
        );
        costs[(y * width) + x] = cost;
      }
    }

    final ({int x, int y})? startCell = _gridPointForCanvasPoint(
      point: startAnchor,
      origin: origin,
      cellSizeOnCanvas: cellSizeOnCanvas,
      width: width,
      height: height,
    );
    final ({int x, int y})? goalCell = _gridPointForCanvasPoint(
      point: goalAnchor,
      origin: origin,
      cellSizeOnCanvas: cellSizeOnCanvas,
      width: width,
      height: height,
    );

    if ((startCell == null) || (goalCell == null)) {
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
      canvasPoint: startAnchor,
      cellSizeOnCanvas: cellSizeOnCanvas,
      targetColor: targetColor,
    );
    final int goalCost = _estimateCellCost(
      canvasPoint: goalAnchor,
      cellSizeOnCanvas: cellSizeOnCanvas,
      targetColor: targetColor,
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
    final double rawCost =
        (targetColorMatch * mpLineTraceAStarTargetColorCostFactor) -
        (edgePreference * mpLineTraceAStarEdgePreferenceCostFactor);

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

    if ((cellX < 0) || (cellX >= width) || (cellY < 0) || (cellY >= height)) {
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
    return squaredDistance / mpLineTraceAStarMaximumSquaredColorDistance;
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
      origin.dx +
          ((gridCell.dx + mpLineTraceAStarCellCenterOffset) * cellSizeOnCanvas),
      origin.dy +
          ((gridCell.dy + mpLineTraceAStarCellCenterOffset) * cellSizeOnCanvas),
    );
  }
}
