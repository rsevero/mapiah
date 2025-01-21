import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

// height <value> . height of pit or wall:pit; available in METAPOST as a numeric
// variable ATTR__height.
class THLineHeightCommandOption extends THCommandOption {
  static const String _thisOptionType = 'lineheight';
  late final THDoublePart height;

  THLineHeightCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.height,
  }) : super();

  THLineHeightCommandOption.fromString({
    required super.optionParent,
    required String height,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    this.height = THDoublePart.fromString(valueString: height);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'height': height.toMap(),
    };
  }

  factory THLineHeightCommandOption.fromMap(Map<String, dynamic> map) {
    return THLineHeightCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
      height: THDoublePart.fromMap(map['height']),
    );
  }

  factory THLineHeightCommandOption.fromJson(String jsonString) {
    return THLineHeightCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THLineHeightCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    THDoublePart? height,
  }) {
    return THLineHeightCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      height: height ?? this.height,
    );
  }

  @override
  bool operator ==(covariant THLineHeightCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        height,
      );

  @override
  String specToFile() {
    return height.toString();
  }
}
