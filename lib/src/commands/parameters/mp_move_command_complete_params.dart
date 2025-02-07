library;

import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/commands/parameters/mp_move_command_original_params.dart';
import 'package:mapiah/src/elements/th_element.dart';

part 'mp_move_command_line_complete_params.dart';
part 'mp_move_command_point_complete_params.dart';

enum MPMoveCommandCompleteParamsType {
  line,
  point,
}

sealed class MPMoveCommandCompleteParams {
  MPMoveCommandCompleteParamsType get type;

  MPMoveCommandCompleteParams copyWith();

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'moveCommandCompleteParametersType': type.name,
    };
  }

  static MPMoveCommandCompleteParams fromJson(String jsonString) {
    return fromMap(jsonDecode(jsonString));
  }

  static MPMoveCommandCompleteParams fromMap(Map<String, dynamic> map) {
    switch (MPMoveCommandCompleteParamsType.values
        .byName(map['moveCommandCompleteParametersType'])) {
      case MPMoveCommandCompleteParamsType.line:
        return MPMoveCommandLineCompleteParams.fromMap(map);
      case MPMoveCommandCompleteParamsType.point:
        return MPMoveCommandPointCompleteParams.fromMap(map);
    }
  }
}
