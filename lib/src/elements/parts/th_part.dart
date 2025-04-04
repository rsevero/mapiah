import 'dart:convert';

import 'package:mapiah/src/elements/parts/th_angle_unit_part.dart';
import 'package:mapiah/src/elements/parts/th_clino_unit_part.dart';
import 'package:mapiah/src/elements/parts/th_cs_part.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
import 'package:mapiah/src/elements/parts/th_scale_multiple_choice_part.dart';
import 'package:mapiah/src/elements/parts/th_person_part.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/parts/th_string_part.dart';

enum THPartType {
  angleUnit,
  clinoUnit,
  cs,
  datetime,
  double,
  lengthUnit,
  person,
  position,
  scaleChoices,
  string;
}

abstract class THPart {
  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap();

  THPart copyWith();

  THPartType get type;

  THPart fromMap(Map<String, dynamic> map) {
    final THPartType type = THPartType.values.byName(map['partType']);

    switch (type) {
      case THPartType.angleUnit:
        return THAngleUnitPart.fromMap(map);
      case THPartType.clinoUnit:
        return THClinoUnitPart.fromMap(map);
      case THPartType.cs:
        return THCSPart.fromMap(map);
      case THPartType.datetime:
        return THDatetimePart.fromMap(map);
      case THPartType.double:
        return THDoublePart.fromMap(map);
      case THPartType.lengthUnit:
        return THLengthUnitPart.fromMap(map);
      case THPartType.scaleChoices:
        return THScaleMultipleChoicePart.fromMap(map);
      case THPartType.person:
        return THPersonPart.fromMap(map);
      case THPartType.position:
        return THPositionPart.fromMap(map);
      case THPartType.string:
        return THStringPart.fromMap(map);
    }
  }
}
