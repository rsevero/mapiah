import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';

// from <station> . valid for extra points, specifies reference station.
class THFromCommandOption extends THCommandOption {
  static const String _thisOptionType = 'from';
  final String station;

  THFromCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.station,
  }) : super();

  THFromCommandOption.addToOptionParent({
    required super.optionParent,
    required this.station,
  }) : super.addToOptionParent(optionType: _thisOptionType);

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'station': station,
    };
  }

  factory THFromCommandOption.fromMap(Map<String, dynamic> map) {
    return THFromCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
      station: map['station'],
    );
  }

  factory THFromCommandOption.fromJson(String jsonString) {
    return THFromCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THFromCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    String? station,
  }) {
    return THFromCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      station: station ?? this.station,
    );
  }

  @override
  bool operator ==(covariant THFromCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.station == station;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        station,
      );

  @override
  String specToFile() {
    return station;
  }
}
