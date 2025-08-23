import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';

class MPDashedPathProperties {
  final List<double> dashLengths;
  final bool invert;

  final int _dashLimit;

  final Path path = Path();

  double extractedPathLength = 0.0;
  int _dashIndex = 0;
  double _dashLength = 0.0;
  double _dashGapLength = 0.0;
  double _remainingDashLength = 0.0;
  double _remainingDashGapLength = 0.0;

  MPDashedPathProperties({required this.dashLengths, this.invert = false})
    : assert(
        dashLengths.length > 1,
        'dashLengths must have more than 1 element',
      ),
      assert(dashLengths.length.isEven, 'dashLengths length must be even'),
      _dashLimit = dashLengths.length - 1 {
    if (dashLengths[0] > 0) {
      _dashLength = dashLengths[0];
      _remainingDashLength = dashLengths[0];
    } else {
      _dashGapLength = -dashLengths[0];
      _remainingDashGapLength = -dashLengths[0];
    }
  }

  bool get addDashNext {
    return ((dashLengths[_dashIndex] > 0) ||
        _remainingDashLength != _dashLength);
  }

  void addNext(ui.PathMetric metric) {
    if (addDashNext) {
      _addDash(metric, _dashLength);
      if (_remainingDashLength == 0.0) {
        _updateDashIndex();
      }
    } else {
      _addDashGap(metric, _dashGapLength);
      if (_remainingDashGapLength == 0.0) {
        _updateDashIndex();
      }
    }
  }

  void _updateDashIndex() {
    if (_dashIndex < _dashLimit) {
      _dashIndex++;
    } else {
      _dashIndex = 0;
    }

    final double length = dashLengths[_dashIndex];

    if (length > 0) {
      _dashLength = length;
      _remainingDashLength = length;
      _dashGapLength = 0.0;
      _remainingDashGapLength = 0.0;
    } else {
      _dashGapLength = -length;
      _remainingDashGapLength = -length;
      _dashLength = 0.0;
      _remainingDashLength = 0.0;
    }
  }

  void _addDash(ui.PathMetric metric, double dashLength) {
    // Calculate lengths (actual + available)
    final double end = _calculateLength(metric, _remainingDashLength);
    final double availableEnd = _calculateLength(metric, dashLength);

    // Add path
    if (invert) {
      ui.Tangent tangent = metric.getTangentForOffset(end)!;
      path.moveTo(tangent.position.dx, tangent.position.dy);
    } else {
      final pathSegment = metric.extractPath(extractedPathLength, end);

      path.addPath(pathSegment, Offset.zero);
    }
    // Update
    final double delta = _remainingDashLength - (end - extractedPathLength);

    _remainingDashLength = _updateRemainingLength(
      delta: delta,
      end: end,
      availableEnd: availableEnd,
    );
    extractedPathLength = end;
  }

  void _addDashGap(ui.PathMetric metric, double dashGapLength) {
    // Calculate lengths (actual + available)
    final double end = _calculateLength(metric, _remainingDashGapLength);
    final double availableEnd = _calculateLength(metric, dashGapLength);

    // Move path's end point
    if (invert) {
      final pathSegment = metric.extractPath(extractedPathLength, end);

      path.addPath(pathSegment, Offset.zero);
    } else {
      ui.Tangent tangent = metric.getTangentForOffset(end)!;
      path.moveTo(tangent.position.dx, tangent.position.dy);
    }
    // Update
    final delta = _remainingDashGapLength - (end - extractedPathLength);

    _remainingDashGapLength = _updateRemainingLength(
      delta: delta,
      end: end,
      availableEnd: availableEnd,
    );
    extractedPathLength = end;
  }

  double _calculateLength(ui.PathMetric metric, double addedLength) {
    return math.min(extractedPathLength + addedLength, metric.length);
  }

  double _updateRemainingLength({
    required double delta,
    required double end,
    required double availableEnd,
  }) {
    return ((delta > 0) && (availableEnd == end)) ? delta : 0.0;
  }
}
