library;

import 'dart:convert';

import 'package:mapiah/src/elements/th_element.dart';

part 'mp_add_line_command_params.dart';
part 'mp_add_point_command_params.dart';

enum MPAddElementCommandParamsType {
  line,
  point,
}

abstract class MPCreateCommandParams {
  MPAddElementCommandParamsType get paramsType;

  MPCreateCommandParams copyWith();

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'mpCreateCommandParamsType': paramsType.name,
    };
  }

  static MPCreateCommandParams fromJson(String jsonString) {
    return fromMap(jsonDecode(jsonString));
  }

  static MPCreateCommandParams fromMap(Map<String, dynamic> map) {
    switch (MPAddElementCommandParamsType.values
        .byName(map['mpCreateCommandParamsType'])) {
      case MPAddElementCommandParamsType.line:
        return MPAddLineCommandParams.fromMap(map);
      case MPAddElementCommandParamsType.point:
        return MPAddPointCommandParams.fromMap(map);
    }
  }
}
