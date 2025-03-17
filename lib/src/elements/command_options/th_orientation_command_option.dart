part of 'th_command_option.dart';

// orientation/orient <number> . defines the orientation of the symbol. If not speci-
// fied, it’s oriented to north. 0 ≤ number < 360.
class THOrientationCommandOption extends THCommandOption {
  late THDoublePart azimuth;

  THOrientationCommandOption.forCWJM({
    required super.parentMPID,
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
  THCommandOptionType get type => THCommandOptionType.orientation;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'azimuth': azimuth.toMap(),
    });

    return map;
  }

  factory THOrientationCommandOption.fromMap(Map<String, dynamic> map) {
    return THOrientationCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      azimuth: THDoublePart.fromMap(map['azimuth']),
    );
  }

  factory THOrientationCommandOption.fromJson(String jsonString) {
    return THOrientationCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THOrientationCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THDoublePart? azimuth,
  }) {
    return THOrientationCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      azimuth: azimuth ?? this.azimuth,
    );
  }

  @override
  bool operator ==(covariant THOrientationCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.azimuth == azimuth;
  }

  @override
  int get hashCode => super.hashCode ^ azimuth.hashCode;

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
