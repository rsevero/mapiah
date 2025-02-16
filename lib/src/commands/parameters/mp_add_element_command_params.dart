library;

import 'dart:convert';

import 'package:mapiah/src/elements/th_element.dart';

part 'mp_add_line_command_params.dart';
part 'mp_add_point_command_params.dart';

enum MPAddElementCommandParamsType {
  line,
  point,
}

abstract class MPAddElementCommandParams {
  MPAddElementCommandParamsType get paramsType;

  MPAddElementCommandParams copyWith();

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'mpAddElementCommandParamsType': paramsType.name,
    };
  }

  static MPAddElementCommandParams fromJson(String jsonString) {
    return fromMap(jsonDecode(jsonString));
  }

  static MPAddElementCommandParams fromMap(Map<String, dynamic> map) {
    switch (MPAddElementCommandParamsType.values
        .byName(map['mpAddElementCommandParamsType'])) {
      case MPAddElementCommandParamsType.line:
        return MPAddLineCommandParams.fromMap(map);
      case MPAddElementCommandParamsType.point:
        return MPAddPointCommandParams.fromMap(map);
    }
  }
}
