import 'package:flutter/material.dart';

abstract class MPSelectable {
  final Offset position;

  MPSelectable({
    required this.position,
  });

  Object get selected;
}
