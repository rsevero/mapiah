// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_segment.dart';

@immutable
class MPStraightSegment extends MPSegment {
  const MPStraightSegment({required super.start, required super.end});

  @override
  double length() {
    return (end - start).distance;
  }
}
