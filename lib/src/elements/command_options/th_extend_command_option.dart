import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';

// extend [prev[ious] <station>] . if the point type is station and scrap projection
// is extended elevation, you can adjust the extension of the centreline using this option.
class THExtendCommandOption extends THCommandOption {
  final String station;

  THExtendCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.station,
  }) : super();

  THExtendCommandOption.addToOptionParent({
    required super.optionParent,
    required this.station,
  }) : super.addToOptionParent(optionType: THCommandOptionType.extend);
  //      {
  //   if ((optionParent is! THPoint) || (optionParent.plaType != 'station')) {
  //     throw THCustomException(
  //         "Option 'extend' only valid for points of type 'station'.");
  //   }
  // }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType.name,
      'station': station,
    };
  }

  factory THExtendCommandOption.fromMap(Map<String, dynamic> map) {
    return THExtendCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: THCommandOptionType.values.byName(map['optionType']),
      station: map['station'],
    );
  }

  factory THExtendCommandOption.fromJson(String jsonString) {
    return THExtendCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THExtendCommandOption copyWith({
    int? parentMapiahID,
    THCommandOptionType? optionType,
    String? station,
  }) {
    return THExtendCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      station: station ?? this.station,
    );
  }

  @override
  bool operator ==(covariant THExtendCommandOption other) {
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
    return station.isEmpty ? '' : "previous $station";
  }
}
