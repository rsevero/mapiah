library;

import 'dart:convert';

import 'package:mapiah/src/elements/th_element.dart';

part 'mp_create_line_command_params.dart';
part 'mp_create_point_command_params.dart';

enum MPCreateCommandParamsType {
  line,
  point,
}

abstract class MPCreateCommandParams {
  MPCreateCommandParamsType get paramsType;

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
    switch (MPCreateCommandParamsType.values
        .byName(map['mpCreateCommandParamsType'])) {
      // case MPCreateCommandParamsType.line:
      //   return MPCreateLineCommandParams.fromMap(map);
      // case MPCreateCommandParamsType.point:
      //   return MPCreatePointCommandParams.fromMap(map);
      default:
        throw UnimplementedError();
    }
  }
}
