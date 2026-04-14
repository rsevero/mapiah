// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_line_trace_strategy.dart';
import 'package:mapiah/src/controllers/types/mp_line_trace_strategy_type.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';

class TH2FileEditLineTraceController {
  final TH2FileEditController _th2FileEditController;

  final TH2FileEditLineTraceStrategyRegistry _traceStrategyRegistry;

  final ValueNotifier<bool> isTracingNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<bool> canStartTracingNotifier = ValueNotifier<bool>(
    false,
  );

  bool _isTraceLoopRunning = false;
  bool _shouldContinueTracing = false;

  TH2FileEditLineTraceSession? _traceSession;
  TH2FileEditLineTraceStrategy? _activeTraceStrategy;

  TH2FileEditLineTraceController(this._th2FileEditController)
    : _traceStrategyRegistry = TH2FileEditLineTraceStrategyRegistry();

  bool get isTracing => isTracingNotifier.value;

  double? get stepDistanceOnCanvas => _traceSession?.stepDistanceOnCanvas;

  bool get hasAnyImage => _th2FileEditController.th2File.getImages().isNotEmpty;

  Future<void> updateCanStartTracing() async {
    if (!hasAnyImage || !_th2FileEditController.isInAddLineState) {
      _traceSession = null;
      _activeTraceStrategy = null;
      canStartTracingNotifier.value = false;

      return;
    }

    final _PreparedTraceStrategy? preparedTraceStrategy =
        await _prepareSelectedStrategy();

    _traceSession = preparedTraceStrategy?.session;
    _activeTraceStrategy = preparedTraceStrategy?.strategy;
    canStartTracingNotifier.value = preparedTraceStrategy != null;
  }

  Future<void> startTracingFromCurrentLine() async {
    if (isTracingNotifier.value) {
      return;
    }

    final _PreparedTraceStrategy? preparedTraceStrategy =
        await _prepareSelectedStrategy();

    if (preparedTraceStrategy == null) {
      _traceSession = null;
      _activeTraceStrategy = null;
      canStartTracingNotifier.value = false;

      return;
    }

    _traceSession = preparedTraceStrategy.session;
    _activeTraceStrategy = preparedTraceStrategy.strategy;
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
    _traceSession = null;
    _activeTraceStrategy = null;
    canStartTracingNotifier.value = false;
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

      // Yield to the event loop so UI events (including Stop) are processed.
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
}

class _PreparedTraceStrategy {
  final TH2FileEditLineTraceStrategy strategy;

  final TH2FileEditLineTraceSession session;

  _PreparedTraceStrategy({required this.strategy, required this.session});
}
