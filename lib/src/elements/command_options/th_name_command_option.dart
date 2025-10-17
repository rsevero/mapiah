part of 'th_command_option.dart';

// name <reference> . if the point type is station, this option gives the
// reference to the real survey station.
class THNameCommandOption extends THCommandOption {
  late final String reference;

  THNameCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.reference,
  }) : super.forCWJM();

  THNameCommandOption({
    required super.parentMPID,
    required this.reference,
    super.originalLineInTH2File = '',
  }) : super();

  THNameCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required this.reference,
    super.originalLineInTH2File = '',
  }) : super.forCWJM();

  @override
  THCommandOptionType get type => THCommandOptionType.name;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'reference': reference});

    return map;
  }

  factory THNameCommandOption.fromMap(Map<String, dynamic> map) {
    return THNameCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      reference: map['reference'],
    );
  }

  factory THNameCommandOption.fromJson(String jsonString) {
    return THNameCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THNameCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    String? reference,
  }) {
    return THNameCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      reference: reference ?? this.reference,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THNameCommandOption) return false;
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
