// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_line_trace_strategy.dart';
import 'package:mapiah/src/controllers/types/mp_line_trace_strategy_type.dart';

void main() {
  group('TH2FileEditLineTraceStrategyRegistry', () {
    test('returns strategies in enum order', () {
      final TH2FileEditLineTraceStrategyRegistry registry =
          TH2FileEditLineTraceStrategyRegistry();
      final List<TH2FileEditLineTraceStrategy> strategies = registry
          .resolveStrategies();

      expect(strategies, hasLength(2));
      expect(strategies.first, isA<TH2FileEditLineTraceLocalColorStrategy>());
      expect(strategies.last, isA<TH2FileEditLineTraceCostMapAStarStrategy>());
    });

    test('resolves the selected strategy type', () {
      final TH2FileEditLineTraceStrategyRegistry registry =
          TH2FileEditLineTraceStrategyRegistry();

      expect(
        registry.resolveStrategy(MPLineTraceStrategyType.localColorGuided),
        isA<TH2FileEditLineTraceLocalColorStrategy>(),
      );
      expect(
        registry.resolveStrategy(MPLineTraceStrategyType.costMapAStar),
        isA<TH2FileEditLineTraceCostMapAStarStrategy>(),
      );
    });
  });

  group('TH2FileEditLineTraceAStarPathFinder', () {
    test('finds a path through the lowest-cost corridor', () {
      final List<int> costs = <int>[
        1,
        255,
        255,
        255,
        1,
        1,
        255,
        255,
        255,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        255,
        255,
        255,
        1,
        1,
        255,
        255,
        255,
        1,
      ];
      final TH2FileEditLineTraceGridCostMap costMap =
          TH2FileEditLineTraceGridCostMap(
            width: 5,
            height: 5,
            costs: costs,
            blockedCost: mpLineTraceAStarBlockedCost,
          );
      final TH2FileEditLineTraceAStarPathFinder pathFinder =
          TH2FileEditLineTraceAStarPathFinder();
      final List<Offset>? path = pathFinder.findPath(
        costMap: costMap,
        start: const Offset(0, 2),
        goal: const Offset(4, 2),
      );

      expect(path, isNotNull);
      expect(path, isNotEmpty);
      expect(path!.first, const Offset(0, 2));
      expect(path.last, const Offset(4, 2));
      expect(path, contains(const Offset(2, 2)));

      for (final Offset point in path) {
        final int x = point.dx.round();
        final int y = point.dy.round();

        expect(costMap.costAt(x, y), isNot(mpLineTraceAStarBlockedCost));
      }
    });
  });
}
