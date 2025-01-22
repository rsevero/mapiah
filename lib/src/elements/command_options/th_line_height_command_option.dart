import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

// height <value> . height of pit or wall:pit; available in METAPOST as a numeric
// variable ATTR__height.
class THLineHeightCommandOption extends THCommandOption {
  late final THDoublePart height;

  THLineHeightCommandOption.forCWJM({
    required super.parentMapiahID,
    required this.height,
  }) : super.forCWJM();

  THLineHeightCommandOption.fromString({
    required super.optionParent,
    required String height,
  }) : super() {
    this.height = THDoublePart.fromString(valueString: height);
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.lineHeight;

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'height': height.toMap(),
      'optionType': optionType.name,
    };
  }

  factory THLineHeightCommandOption.fromMap(Map<String, dynamic> map) {
    return THLineHeightCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      height: THDoublePart.fromMap(map['height']),
    );
  }

  factory THLineHeightCommandOption.fromJson(String jsonString) {
    return THLineHeightCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THLineHeightCommandOption copyWith({
    int? parentMapiahID,
    THDoublePart? height,
  }) {
    return THLineHeightCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      height: height ?? this.height,
    );
  }

  @override
  bool operator ==(covariant THLineHeightCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID && other.height == height;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        height,
      );

  @override
  String specToFile() {
    return height.toString();
  }
}
