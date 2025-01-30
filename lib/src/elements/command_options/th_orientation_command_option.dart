part of 'th_command_option.dart';

// orientation/orient <number> . defines the orientation of the symbol. If not speci-
// fied, it’s oriented to north. 0 ≤ number < 360.
class THOrientationCommandOption extends THCommandOption {
  late THDoublePart azimuth;

  THOrientationCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.azimuth,
  }) : super.forCWJM();

  THOrientationCommandOption.fromString({
    required super.optionParent,
    required String azimuth,
    super.originalLineInTH2File = '',
  }) : super() {
    this.azimuth = THDoublePart.fromString(valueString: azimuth);
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.orientation;

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'azimuth': azimuth.toMap(),
    };
  }

  factory THOrientationCommandOption.fromMap(Map<String, dynamic> map) {
    return THOrientationCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      azimuth: THDoublePart.fromMap(map['azimuth']),
    );
  }

  factory THOrientationCommandOption.fromJson(String jsonString) {
    return THOrientationCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THOrientationCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THDoublePart? azimuth,
  }) {
    return THOrientationCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      azimuth: azimuth ?? this.azimuth,
    );
  }

  @override
  bool operator ==(covariant THOrientationCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID && other.azimuth == azimuth;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
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
