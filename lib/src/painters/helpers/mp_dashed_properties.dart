import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';

class MPDashedPathProperties {
  double extractedPathLength;
  Path path;
  final bool invert;

  final double _dashLength;
  double _remainingDashLength;
  double _remainingDashGapLength;
  bool _previousWasDash;

  MPDashedPathProperties({
    required this.path,
    required double dashLength,
    required double dashGapLength,
    this.invert = false,
  })  : assert(dashLength > 0.0, 'dashLength must be > 0.0'),
        assert(dashGapLength > 0.0, 'dashGapLength must be > 0.0'),
        _dashLength = dashLength,
        _remainingDashLength = dashLength,
        _remainingDashGapLength = dashGapLength,
        _previousWasDash = false,
        extractedPathLength = 0.0;

  bool get addDashNext {
    if (!_previousWasDash || _remainingDashLength != _dashLength) {
      return true;
    }
    return false;
  }

  void addDash(ui.PathMetric metric, double dashLength) {
    // Calculate lengths (actual + available)
    final end = _calculateLength(metric, _remainingDashLength);
    final availableEnd = _calculateLength(metric, dashLength);
    // Add path
    if (invert) {
      ui.Tangent tangent = metric.getTangentForOffset(end)!;
      path.moveTo(tangent.position.dx, tangent.position.dy);
    } else {
      final pathSegment = metric.extractPath(extractedPathLength, end);
      path.addPath(pathSegment, Offset.zero);
    }
    // Update
    final delta = _remainingDashLength - (end - extractedPathLength);
    _remainingDashLength = _updateRemainingLength(
      delta: delta,
      end: end,
      availableEnd: availableEnd,
      initialLength: dashLength,
    );
    extractedPathLength = end;
    _previousWasDash = true;
  }

  void addDashGap(ui.PathMetric metric, double dashGapLength) {
    // Calculate lengths (actual + available)
    final end = _calculateLength(metric, _remainingDashGapLength);
    final availableEnd = _calculateLength(metric, dashGapLength);
    // Move path's end point
    if (invert) {
      final pathSegment = metric.extractPath(extractedPathLength, end);
      path.addPath(pathSegment, Offset.zero);
    } else {
      ui.Tangent tangent = metric.getTangentForOffset(end)!;
      path.moveTo(tangent.position.dx, tangent.position.dy);
    }
    // Update
    final delta = end - extractedPathLength;
    _remainingDashGapLength = _updateRemainingLength(
      delta: delta,
      end: end,
      availableEnd: availableEnd,
      initialLength: dashGapLength,
    );
    extractedPathLength = end;
    _previousWasDash = false;
  }

  double _calculateLength(ui.PathMetric metric, double addedLength) {
    return math.min(extractedPathLength + addedLength, metric.length);
  }

  double _updateRemainingLength({
    required double delta,
    required double end,
    required double availableEnd,
    required double initialLength,
  }) {
    return (delta > 0 && availableEnd == end) ? delta : initialLength;
  }
}
