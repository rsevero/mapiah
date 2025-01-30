part of 'th_command_option.dart';

// extend [prev[ious] <station>] . if the point type is station and scrap projection
// is extended elevation, you can adjust the extension of the centreline using this option.
class THExtendCommandOption extends THCommandOption {
  final String station;

  THExtendCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.station,
  }) : super.forCWJM();

  THExtendCommandOption({
    required super.optionParent,
    required this.station,
    super.originalLineInTH2File = '',
  }) : super();
  //      {
  //   if ((optionParent is! THPoint) || (optionParent.plaType != 'station')) {
  //     throw THCustomException(
  //         "Option 'extend' only valid for points of type 'station'.");
  //   }
  // }

  @override
  THCommandOptionType get optionType => THCommandOptionType.extend;

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'station': station,
    };
  }

  factory THExtendCommandOption.fromMap(Map<String, dynamic> map) {
    return THExtendCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      station: map['station'],
    );
  }

  factory THExtendCommandOption.fromJson(String jsonString) {
    return THExtendCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THExtendCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    String? station,
  }) {
    return THExtendCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      station: station ?? this.station,
    );
  }

  @override
  bool operator ==(covariant THExtendCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID && other.station == station;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        station,
      );

  @override
  String specToFile() {
    return station.isEmpty ? '' : "previous $station";
  }
}
