part of 'th_command_option.dart';

// extend [prev[ious] <station>] . if the point type is station and scrap
// projection is extended elevation, you can adjust the extension of the
// centreline using this option.
class THExtendCommandOption extends THCommandOption {
  final String station;

  THExtendCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.station,
  }) : super.forCWJM();

  THExtendCommandOption({
    required super.optionParent,
    required this.station,
    super.originalLineInTH2File = '',
  }) : super();

  THExtendCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required this.station,
    super.originalLineInTH2File = '',
  }) : super.forCWJM();

  @override
  THCommandOptionType get type => THCommandOptionType.extend;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'station': station});

    return map;
  }

  factory THExtendCommandOption.fromMap(Map<String, dynamic> map) {
    return THExtendCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      station: map['station'],
    );
  }

  factory THExtendCommandOption.fromJson(String jsonString) {
    return THExtendCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THExtendCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    String? station,
  }) {
    return THExtendCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      station: station ?? this.station,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THExtendCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.station == station;
  }

  @override
  int get hashCode => super.hashCode ^ station.hashCode;

  @override
  String specToFile() {
    return station.isEmpty ? '' : "previous $station";
  }
}
