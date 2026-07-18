// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;

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

  static int _mixSeed(int mpID, int salt) {
    final int mixedMPID = mpID * 0x1f1f1f1f;
    final int mixedSalt = salt * 0x5f356495;

    return (mixedMPID ^ mixedSalt) & mpMaximumRandomSeed;
  }
}
