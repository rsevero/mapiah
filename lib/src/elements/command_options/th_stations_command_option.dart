part of 'th_command_option.dart';

// stations <list of station names> . stations you want to plot to the scrap, but
// which are not used for scrap transformation. You don’t have to specify (draw) them
// with the point station command.
class THStationsCommandOption extends THCommandOption {
  final List<String> stations;

  THStationsCommandOption.forCWJM({
    required super.parentMapiahID,
    required this.stations,
  }) : super.forCWJM();

  THStationsCommandOption({
    required super.optionParent,
    required this.stations,
  }) : super();

  @override
  THCommandOptionType get optionType => THCommandOptionType.stations;

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'stations': stations,
    };
  }

  factory THStationsCommandOption.fromMap(Map<String, dynamic> map) {
    return THStationsCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      stations: List<String>.from(map['stations']),
    );
  }

  factory THStationsCommandOption.fromJson(String jsonString) {
    return THStationsCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THStationsCommandOption copyWith({
    int? parentMapiahID,
    List<String>? stations,
  }) {
    return THStationsCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      stations: stations ?? this.stations,
    );
  }

  @override
  bool operator ==(covariant THStationsCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID && other.stations == stations;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        stations,
      );

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
