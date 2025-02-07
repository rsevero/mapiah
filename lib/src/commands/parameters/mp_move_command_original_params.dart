library;

import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_element.dart';

part 'mp_move_command_line_original_params.dart';
part 'mp_move_command_point_original_params.dart';

enum MPMoveCommandOriginalParamsType {
  line,
  point,
}

sealed class MPMoveCommandOriginalParams {
  final int mapiahID;

  MPMoveCommandOriginalParams({required this.mapiahID});

  MPMoveCommandOriginalParamsType get type;

  MPMoveCommandOriginalParams copyWith();

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'moveCommandOriginalParametersType': type.name,
    };
  }

  static MPMoveCommandOriginalParams fromJson(String jsonString) {
    return fromMap(jsonDecode(jsonString));
  }

  static MPMoveCommandOriginalParams fromMap(Map<String, dynamic> map) {
    switch (MPMoveCommandOriginalParamsType.values
        .byName(map['moveCommandOriginalParametersType'])) {
      case MPMoveCommandOriginalParamsType.line:
        return MPMoveCommandLineOriginalParams.fromMap(map);
      case MPMoveCommandOriginalParamsType.point:
        return MPMoveCommandPointOriginalParams.fromMap(map);
    }
  }
}
