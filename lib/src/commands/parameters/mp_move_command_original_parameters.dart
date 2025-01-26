library;

import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_element.dart';

part 'mp_move_command_line_original_parameters.dart';
part 'mp_move_command_point_original_parameters.dart';

enum MPMoveCommandOriginalParametersType {
  line,
  point,
}

sealed class MPMoveCommandOriginalParameters {
  final int mapiahID;

  MPMoveCommandOriginalParameters({required this.mapiahID});

  MPMoveCommandOriginalParametersType get type;

  MPMoveCommandOriginalParameters copyWith();

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap();

  static MPMoveCommandOriginalParameters fromJson(String jsonString) {
    return fromMap(jsonDecode(jsonString));
  }

  static MPMoveCommandOriginalParameters fromMap(Map<String, dynamic> map) {
    switch (MPMoveCommandOriginalParametersType.values
        .byName(map['moveCommandOriginalParametersType'])) {
      case MPMoveCommandOriginalParametersType.line:
        return MPMoveCommandLineOriginalParameters.fromMap(map);
      case MPMoveCommandOriginalParametersType.point:
        return MPMoveCommandPointOriginalParameters.fromMap(map);
    }
  }
}
