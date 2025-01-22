import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';

// from <station> . valid for extra points, specifies reference station.
class THFromCommandOption extends THCommandOption {
  final String station;

  THFromCommandOption.forCWJM({
    required super.parentMapiahID,
    required this.station,
  }) : super.forCWJM();

  THFromCommandOption({
    required super.optionParent,
    required this.station,
  }) : super();

  @override
  THCommandOptionType get optionType => THCommandOptionType.from;

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'station': station,
    };
  }

  factory THFromCommandOption.fromMap(Map<String, dynamic> map) {
    return THFromCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      station: map['station'],
    );
  }

  factory THFromCommandOption.fromJson(String jsonString) {
    return THFromCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THFromCommandOption copyWith({
    int? parentMapiahID,
    String? station,
  }) {
    return THFromCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      station: station ?? this.station,
    );
  }

  @override
  bool operator ==(covariant THFromCommandOption other) {
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
    return station;
  }
}
