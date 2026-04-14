// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_trace_image_preprocessor.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_line_trace_strategy_type.dart';

part 'th2_file_edit_line_trace_local_color_strategy.dart';
part 'th2_file_edit_line_trace_cost_map_a_star_strategy.dart';

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

/// Resolves the available line-trace strategies.
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

  /// Returns the tracing strategy selected by settings.
  TH2FileEditLineTraceStrategy resolveStrategy(
    MPLineTraceStrategyType strategyType,
  ) {
    switch (strategyType) {
      case MPLineTraceStrategyType.localColorGuided:
        return _localColorStrategy;
      case MPLineTraceStrategyType.costMapAStar:
        return _costMapAStarStrategy;
    }
  }

  /// Returns the default tracing strategy.
  TH2FileEditLineTraceStrategy resolveDefaultStrategy() {
    return resolveStrategy(MPLineTraceStrategyType.localColorGuided);
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
