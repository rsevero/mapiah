// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'th_command_option.dart';

// name <reference> . if the point type is station, this option gives the
// reference to the real survey station.
class THStationNameCommandOption extends THCommandOption {
  late final String reference;

  THStationNameCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.reference,
  }) : super.forCWJM();

  THStationNameCommandOption({
    required super.parentMPID,
    required this.reference,
    super.originalLineInTH2File = '',
  }) : super();

  THStationNameCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required this.reference,
    super.originalLineInTH2File = '',
  }) : super.forCWJM();

  @override
  THCommandOptionType get type => THCommandOptionType.station;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'reference': reference});

    return map;
  }

  factory THStationNameCommandOption.fromMap(Map<String, dynamic> map) {
    return THStationNameCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      reference: map['reference'],
    );
  }

  factory THStationNameCommandOption.fromJson(String jsonString) {
    return THStationNameCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THStationNameCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    String? reference,
  }) {
    return THStationNameCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      reference: reference ?? this.reference,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THStationNameCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.reference == reference;
  }

  @override
  int get hashCode => super.hashCode ^ reference.hashCode;

  @override
  String specToFile() {
    return reference;
  }
}
