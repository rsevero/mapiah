// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'th_command_option.dart';

// copyright <date> <string> . copyright date and name
class THCopyrightCommandOption extends THCommandOption {
  late final THDatetimePart datetime;
  final THStringPart message;

  /// Constructor necessary for dart_mappable support.
  THCopyrightCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.datetime,
    required this.message,
  }) : super.forCWJM();

  THCopyrightCommandOption({
    required super.parentMPID,
    required this.datetime,
    required String message,
    super.originalLineInTH2File = '',
  }) : message = THStringPart(content: message),
       super();

  THCopyrightCommandOption.fromString({
    required super.parentMPID,
    required String datetime,
    required String message,
    super.originalLineInTH2File = '',
  }) : message = THStringPart(content: message),
       super() {
    this.datetime = THDatetimePart.fromString(datetime: datetime);
  }

  THCopyrightCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required String datetime,
    required String message,
    super.originalLineInTH2File = '',
  }) : message = THStringPart(content: message),
       super.forCWJM() {
    this.datetime = THDatetimePart.fromString(datetime: datetime);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.copyright;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'datetime': datetime.toMap(), 'message': message.toMap()});

    return map;
  }

  factory THCopyrightCommandOption.fromMap(Map<String, dynamic> map) {
    return THCopyrightCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      datetime: THDatetimePart.fromMap(map['datetime']),
      message: THStringPart.fromMap(map['message']),
    );
  }

  factory THCopyrightCommandOption.fromJson(String jsonString) {
    return THCopyrightCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THCopyrightCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THDatetimePart? datetime,
    THStringPart? message,
  }) {
    return THCopyrightCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      datetime: datetime ?? this.datetime,
      message: message ?? this.message,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THCopyrightCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.datetime == datetime && other.message == message;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hash(datetime, message);

  @override
  String specToFile() {
    return '$datetime ${message.toString()}';
  }
}
