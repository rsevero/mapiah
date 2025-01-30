part of 'th_command_option.dart';

// from <station> . valid for extra points, specifies reference station.
class THFromCommandOption extends THCommandOption {
  final String station;

  THFromCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.station,
  }) : super.forCWJM();

  THFromCommandOption({
    required super.optionParent,
    required this.station,
    super.originalLineInTH2File = '',
  }) : super();

  @override
  THCommandOptionType get optionType => THCommandOptionType.from;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'station': station,
    });

    return map;
  }

  factory THFromCommandOption.fromMap(Map<String, dynamic> map) {
    return THFromCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      station: map['station'],
    );
  }

  factory THFromCommandOption.fromJson(String jsonString) {
    return THFromCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THFromCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    String? station,
  }) {
    return THFromCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      station: station ?? this.station,
    );
  }

  @override
  bool operator ==(covariant THFromCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.station == station;
  }

  @override
  int get hashCode => super.hashCode ^ station.hashCode;

  @override
  String specToFile() {
    return station;
  }
}
