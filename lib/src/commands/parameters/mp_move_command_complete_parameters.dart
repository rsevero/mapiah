library;

import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/commands/parameters/mp_move_command_original_parameters.dart';
import 'package:mapiah/src/elements/th_element.dart';

part 'mp_move_command_line_complete_parameters.dart';
part 'mp_move_command_point_complete_parameters.dart';

enum MPMoveCommandCompleteParametersType {
  line,
  point,
}

sealed class MPMoveCommandCompleteParameters {
  MPMoveCommandCompleteParametersType get type;

  MPMoveCommandCompleteParameters copyWith();

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap();

  static MPMoveCommandCompleteParameters fromJson(String jsonString) {
    return fromMap(jsonDecode(jsonString));
  }

  static MPMoveCommandCompleteParameters fromMap(Map<String, dynamic> map) {
    switch (MPMoveCommandCompleteParametersType.values
        .byName(map['moveCommandCompleteParametersType'])) {
      case MPMoveCommandCompleteParametersType.line:
        return MPMoveCommandLineCompleteParameters.fromMap(map);
      case MPMoveCommandCompleteParametersType.point:
        return MPMoveCommandPointCompleteParameters.fromMap(map);
    }
  }
}
