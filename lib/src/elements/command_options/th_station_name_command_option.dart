// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'th_command_option.dart';

// name <name> . if the point type is station, this option gives the
// name of the real survey station.
class THStationNameCommandOption extends THCommandOption {
  late final String name;

  THStationNameCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.name,
  }) : super.forCWJM();

  THStationNameCommandOption({
    required super.parentMPID,
    required this.name,
    super.originalLineInTH2File = '',
  }) : super();

  THStationNameCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required this.name,
    super.originalLineInTH2File = '',
  }) : super.forCWJM();

  @override
  THCommandOptionType get type => THCommandOptionType.station;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'name': name});

    return map;
  }

  factory THStationNameCommandOption.fromMap(Map<String, dynamic> map) {
    return THStationNameCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      name: map['name'],
    );
  }

  factory THStationNameCommandOption.fromJson(String jsonString) {
    return THStationNameCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THStationNameCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    String? name,
  }) {
    return THStationNameCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THStationNameCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.name == name;
  }

  @override
  int get hashCode => super.hashCode ^ name.hashCode;

  @override
  String specToFile() {
    return name;
  }
}
