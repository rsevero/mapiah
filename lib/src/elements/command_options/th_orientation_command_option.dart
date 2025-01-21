import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

// orientation/orient <number> . defines the orientation of the symbol. If not speci-
// fied, it’s oriented to north. 0 ≤ number < 360.
class THOrientationCommandOption extends THCommandOption {
  static const String _thisOptionType = 'orientation';
  late THDoublePart azimuth;

  THOrientationCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.azimuth,
  }) : super();

  THOrientationCommandOption.fromString({
    required super.optionParent,
    required String azimuth,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    this.azimuth = THDoublePart.fromString(valueString: azimuth);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'azimuth': azimuth.toMap(),
    };
  }

  factory THOrientationCommandOption.fromMap(Map<String, dynamic> map) {
    return THOrientationCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
      azimuth: THDoublePart.fromMap(map['azimuth']),
    );
  }

  factory THOrientationCommandOption.fromJson(String jsonString) {
    return THOrientationCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THOrientationCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    THDoublePart? azimuth,
  }) {
    return THOrientationCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      azimuth: azimuth ?? this.azimuth,
    );
  }

  @override
  bool operator ==(covariant THOrientationCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.azimuth == azimuth;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        azimuth,
      );

  // set azimuth(THDoublePart aAzimuth) {
  //   if ((aAzimuth.value < 0) || (aAzimuth.value > 360)) {
  //     throw THCustomException(
  //         "Invalid azimuth value '$aAzimuth': should be 0 <= value <= 360");
  //   }

  //   _azimuth = aAzimuth;
  // }

  // set azimuthFromString(String aAzimuth) {
  //   final THDoublePart aDouble = THDoublePart.fromString(aAzimuth);

  //   azimuth = aDouble;
  // }

  @override
  String specToFile() {
    return azimuth.toString();
  }
}
