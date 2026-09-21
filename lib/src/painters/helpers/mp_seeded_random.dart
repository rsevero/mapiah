// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';

/// Stable pseudo-random values for procedural symbols belonging to an element.
class MPSeededRandom {
  final math.Random _random;

  MPSeededRandom({required int mpID, int salt = 0})
    : _random = math.Random(_mixSeed(mpID, salt));

  double nextDouble() => _random.nextDouble();

  /// Returns a normally distributed value without an unbounded rejection loop.
  double nextGaussian() {
    final double first = _random.nextDouble().clamp(
      mpRandomMinimumNonZeroValue,
      1.0,
    );
    final double second = _random.nextDouble();
    final double magnitude = math.sqrt(-2.0 * math.log(first));

    return magnitude * math.cos(mp360DegreesInRad * second);
  }

  /// Approximates MetaPost's `randomized d`: displaces by a distance
  /// uniformly distributed in `[0, magnitude]`, in a uniformly random
  /// direction.
  Offset randomizedOffset(double magnitude) {
    final double distance = nextDouble() * magnitude;
    final double angle = nextDouble() * mp360DegreesInRad;

    return Offset(distance * math.cos(angle), distance * math.sin(angle));
  }

  static int _mixSeed(int mpID, int salt) {
    final int mixedMPID = mpID * 0x1f1f1f1f;
    final int mixedSalt = salt * 0x5f356495;

    return (mixedMPID ^ mixedSalt) & mpMaximumRandomSeed;
  }
}
