// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';

@immutable
abstract class MPSegment {
  const MPSegment({required this.start, required this.end});

  final Offset start;
  final Offset end;

  double length();
}
