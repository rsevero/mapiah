import 'package:flutter/material.dart';

abstract class THSelectable {
  final Offset position;

  THSelectable({
    required this.position,
  });

  Object get selected;
}
