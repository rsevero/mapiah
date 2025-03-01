part of 'th_command_option.dart';

// stations <list of station names> . stations you want to plot to the scrap, but
// which are not used for scrap transformation. You don’t have to specify (draw) them
// with the point station command.
class THStationsCommandOption extends THCommandOption {
  final List<String> stations;

  THStationsCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.stations,
  }) : super.forCWJM();

  THStationsCommandOption({
    required super.optionParent,
    required this.stations,
    super.originalLineInTH2File = '',
  }) : super();

  @override
  THCommandOptionType get type => THCommandOptionType.stations;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'stations': stations,
    });

    return map;
  }

  factory THStationsCommandOption.fromMap(Map<String, dynamic> map) {
    return THStationsCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      stations: List<String>.from(map['stations']),
    );
  }

  factory THStationsCommandOption.fromJson(String jsonString) {
    return THStationsCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THStationsCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    List<String>? stations,
  }) {
    return THStationsCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      stations: stations ?? this.stations,
    );
  }

  @override
  bool operator ==(covariant THStationsCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.stations == stations;
  }

  @override
  int get hashCode => super.hashCode ^ stations.hashCode;

  @override
  String specToFile() {
    String asString = '';

    for (final String station in stations) {
      asString += ",$station";
    }

    if (asString.isNotEmpty) {
      asString = asString.substring(1);
    }

    return asString;
  }
}
