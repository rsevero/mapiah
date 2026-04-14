// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_line_trace_strategy.dart';
import 'package:mapiah/src/controllers/types/mp_line_trace_strategy_type.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mobx/mobx.dart';

class TH2FileEditLineTraceController with Store {
  final TH2FileEditController _th2FileEditController;

  final TH2FileEditLineTraceStrategyRegistry _traceStrategyRegistry;

  final Observable<bool> _isTracing = Observable<bool>(false);

  final Observable<bool> _canStartTracing = Observable<bool>(false);

  final ObservableList<Offset> _previewPath = ObservableList<Offset>();

  final Observable<Offset?> _startAnchor = Observable<Offset?>(null);

  final Observable<Offset?> _goalAnchor = Observable<Offset?>(null);

  bool _isTraceLoopRunning = false;
  bool _shouldContinueTracing = false;

  TH2FileEditLineTraceSession? _traceSession;
  TH2FileEditLineTraceStrategy? _activeTraceStrategy;

  TH2FileEditLineTraceController(this._th2FileEditController)
    : _traceStrategyRegistry = TH2FileEditLineTraceStrategyRegistry();

  bool get isTracing => _isTracing.value;

  bool get canStartTracing => _canStartTracing.value;

  double? get stepDistanceOnCanvas => _traceSession?.stepDistanceOnCanvas;

  ObservableList<Offset> get previewPath => _previewPath;

  bool get hasTracePreview => _previewPath.isNotEmpty;

  Offset? get startAnchor => _startAnchor.value;

  Offset? get goalAnchor => _goalAnchor.value;

  bool get hasAnyImage => _th2FileEditController.th2File.getImages().isNotEmpty;

  bool get isWaypointTracing =>
      (_activeTraceStrategy?.interactionType ==
          MPLineTraceInteractionType.waypointAnchored) &&
      isTracing;

  Future<void> updateCanStartTracing() async {
    if (!hasAnyImage || !_th2FileEditController.isInAddLineState) {
      _traceSession = null;
      _activeTraceStrategy = null;
      _setCanStartTracing(false);

      return;
    }

    final _PreparedTraceStrategy? preparedTraceStrategy =
        await _prepareSelectedStrategy();

    _traceSession = preparedTraceStrategy?.session;
    _activeTraceStrategy = preparedTraceStrategy?.strategy;
    _setCanStartTracing(preparedTraceStrategy != null);
  }

  Future<void> startTracing() async {
    if (isTracing) {
      return;
    }

    final _PreparedTraceStrategy? preparedTraceStrategy =
        await _prepareSelectedStrategy();

    if (preparedTraceStrategy == null) {
      _traceSession = null;
      _activeTraceStrategy = null;
      _setCanStartTracing(false);

      return;
    }

    _traceSession = preparedTraceStrategy.session;
    _activeTraceStrategy = preparedTraceStrategy.strategy;
    _setIsTracing(true);

    if (_activeTraceStrategy?.interactionType !=
        MPLineTraceInteractionType.continuous) {
      _shouldContinueTracing = false;

      return;
    }

    _shouldContinueTracing = true;

    if (_isTraceLoopRunning) {
      return;
    }

    _isTraceLoopRunning = true;

    try {
      await _runTraceLoop();
    } finally {
      _isTraceLoopRunning = false;
      _shouldContinueTracing = false;
      _setIsTracing(false);
      await updateCanStartTracing();
    }
  }

  Future<void> toggleTracing() async {
    if (isTracing) {
      stopTracing();

      return;
    }

    await startTracing();
  }

  void stopTracing() {
    _shouldContinueTracing = false;
    _setIsTracing(false);
    clearTracePreview();
    _setStartAnchor(null);
    _setGoalAnchor(null);
  }

  Future<void> setTraceAnchor(Offset canvasPoint) async {
    if (!isWaypointTracing) {
      return;
    }

    if (startAnchor == null) {
      _setStartAnchor(canvasPoint);
      _setGoalAnchor(null);
      clearTracePreview();
      _th2FileEditController.centerCanvasOn(canvasPoint);

      return;
    }

    _setGoalAnchor(canvasPoint);

    final TH2FileEditLineTraceStrategy? activeStrategy = _activeTraceStrategy;

    if (activeStrategy == null) {
      clearTracePreview();

      return;
    }

    final List<Offset>? nextPreviewPath = await activeStrategy.buildPreviewPath(
      context: _createTraceContext(session: _traceSession),
      startAnchor: startAnchor!,
      goalAnchor: canvasPoint,
    );

    if ((nextPreviewPath == null) || nextPreviewPath.isEmpty) {
      clearTracePreview();

      return;
    }

    _setPreviewPath(nextPreviewPath);
    _th2FileEditController.centerCanvasOn(canvasPoint);
  }

  Future<void> confirmTracePreview() async {
    if (!hasTracePreview) {
      return;
    }

    _th2FileEditController.areaLineCreationController
        .appendInteractiveLineNodesFromCanvas(_previewPath);
    _setStartAnchor(goalAnchor);
    _setGoalAnchor(null);
    clearTracePreview();
  }

  void cancelWaypointTarget() {
    if (!isWaypointTracing) {
      return;
    }

    _setGoalAnchor(null);
    clearTracePreview();
  }

  void reset() {
    stopTracing();
    _traceSession = null;
    _activeTraceStrategy = null;
    _setCanStartTracing(false);
    _traceStrategyRegistry.reset();
  }

  Future<void> _runTraceLoop() async {
    while (_shouldContinueTracing && _th2FileEditController.isInAddLineState) {
      final TH2FileEditLineTraceStrategy? activeStrategy = _activeTraceStrategy;

      if (activeStrategy == null) {
        stopTracing();

        return;
      }

      final TH2FileEditLineTraceStepResult stepResult = await activeStrategy
          .traceSingleStep(
            context: _createTraceContext(session: _traceSession),
          );

      if (!stepResult.didProgress) {
        stopTracing();

        return;
      }

      if (stepResult.shouldStopTracing) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  Future<_PreparedTraceStrategy?> _prepareSelectedStrategy() async {
    final MPLineTraceStrategyType strategyType =
        mpLocator.mpSettingsController.getEnumWithDefault(
              MPSettingID.TH2Edit_TraceStrategy,
            )
            as MPLineTraceStrategyType;
    final TH2FileEditLineTraceStrategy strategy = _traceStrategyRegistry
        .resolveStrategy(strategyType);
    final TH2FileEditLineTraceSession? session = await strategy.prepareSession(
      context: _createTraceContext(session: _traceSession),
    );

    if (session == null) {
      return null;
    }

    return _PreparedTraceStrategy(strategy: strategy, session: session);
  }

  TH2FileEditLineTraceContext _createTraceContext({
    required TH2FileEditLineTraceSession? session,
  }) {
    return TH2FileEditLineTraceContext(
      th2FileEditController: _th2FileEditController,
      session: session,
    );
  }

  void clearTracePreview() {
    if (_previewPath.isEmpty) {
      return;
    }

    runInAction(() {
      _previewPath.clear();
    });
  }

  void _setCanStartTracing(bool value) {
    runInAction(() {
      _canStartTracing.value = value;
    });
  }

  void _setGoalAnchor(Offset? value) {
    runInAction(() {
      _goalAnchor.value = value;
    });
  }

  void _setIsTracing(bool value) {
    runInAction(() {
      _isTracing.value = value;
    });
  }

  void _setPreviewPath(List<Offset> previewPath) {
    runInAction(() {
      _previewPath
        ..clear()
        ..addAll(previewPath);
    });
  }

  void _setStartAnchor(Offset? value) {
    runInAction(() {
      _startAnchor.value = value;
    });
  }
}

class _PreparedTraceStrategy {
  final TH2FileEditLineTraceStrategy strategy;

  final TH2FileEditLineTraceSession session;

  _PreparedTraceStrategy({required this.strategy, required this.session});
}
