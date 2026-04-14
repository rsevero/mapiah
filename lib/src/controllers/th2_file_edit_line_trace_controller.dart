// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_line_trace_strategy.dart';

class TH2FileEditLineTraceController {
  final TH2FileEditController _th2FileEditController;

  final TH2FileEditLineTraceStrategy _traceStrategy;

  final ValueNotifier<bool> isTracingNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<bool> canStartTracingNotifier = ValueNotifier<bool>(
    false,
  );

  bool _isTraceLoopRunning = false;
  bool _shouldContinueTracing = false;

  TH2FileEditLineTraceSession? _traceSession;

  TH2FileEditLineTraceController(this._th2FileEditController)
    : _traceStrategy = TH2FileEditLineTraceStrategyRegistry()
          .resolveDefaultStrategy();

  bool get isTracing => isTracingNotifier.value;

  double? get stepDistanceOnCanvas => _traceSession?.stepDistanceOnCanvas;

  bool get hasAnyImage => _th2FileEditController.th2File.getImages().isNotEmpty;

  Future<void> updateCanStartTracing() async {
    if (!hasAnyImage || !_th2FileEditController.isInAddLineState) {
      _traceSession = null;
      canStartTracingNotifier.value = false;

      return;
    }

    final TH2FileEditLineTraceSession? session = await _traceStrategy
        .prepareSession(context: _createTraceContext(session: _traceSession));

    _traceSession = session;
    canStartTracingNotifier.value = session != null;
  }

  Future<void> startTracingFromCurrentLine() async {
    if (isTracingNotifier.value) {
      return;
    }

    final TH2FileEditLineTraceSession? preparedSession = await _traceStrategy
        .prepareSession(context: _createTraceContext(session: _traceSession));

    if (preparedSession == null) {
      canStartTracingNotifier.value = false;

      return;
    }

    _traceSession = preparedSession;
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
    canStartTracingNotifier.value = false;
    _traceStrategy.reset();
  }

  Future<void> _runTraceLoop() async {
    while (_shouldContinueTracing && _th2FileEditController.isInAddLineState) {
      final TH2FileEditLineTraceStepResult stepResult = await _traceStrategy
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

  TH2FileEditLineTraceContext _createTraceContext({
    required TH2FileEditLineTraceSession? session,
  }) {
    return TH2FileEditLineTraceContext(
      th2FileEditController: _th2FileEditController,
      session: session,
    );
  }
}
