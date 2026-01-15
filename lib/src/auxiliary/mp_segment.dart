import 'package:flutter/material.dart';

@immutable
abstract class MPSegment {
  const MPSegment({required this.start, required this.end});

  final Offset start;
  final Offset end;
}
