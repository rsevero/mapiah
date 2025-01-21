import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';

// station-names <prefix> <suffix> . adds given prefix/suffix to all survey stations
// in the current scrap. Saves some typing.
class THStationNamesCommandOption extends THCommandOption {
  static const String _thisOptionType = 'stationnames';
  late final String prefix;
  late final String suffix;

  THStationNamesCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.prefix,
    required this.suffix,
  }) : super();

  THStationNamesCommandOption.addToptionType({
    required super.optionParent,
    required this.prefix,
    required this.suffix,
  }) : super.addToOptionParent(optionType: _thisOptionType);

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'prefix': prefix,
      'suffix': suffix,
    };
  }

  factory THStationNamesCommandOption.fromMap(Map<String, dynamic> map) {
    return THStationNamesCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
      prefix: map['prefix'],
      suffix: map['suffix'],
    );
  }

  factory THStationNamesCommandOption.fromJson(String jsonString) {
    return THStationNamesCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THStationNamesCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    String? prefix,
    String? suffix,
  }) {
    return THStationNamesCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
    );
  }

  @override
  bool operator ==(covariant THStationNamesCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.prefix == prefix &&
        other.suffix == suffix;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        prefix,
        suffix,
      );

  // set preffix(String preffix) {
  //   if (preffix.contains(' ')) {
  //     throw THCustomException(
  //         "Preffix can't contain spaces in THStationNamesCommandOption: '$preffix'");
  //   }

  //   _prefix = preffix;
  // }

  // set suffix(String suffix) {
  //   if (suffix.contains(' ')) {
  //     throw THCustomException(
  //         "Suffix can't contain spaces in THStationNamesCommandOption: '$suffix'");
  //   }

  //   _suffix = suffix;
  // }

  @override
  String specToFile() {
    return '$prefix $suffix';
  }
}
