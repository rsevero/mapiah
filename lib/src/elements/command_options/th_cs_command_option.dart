part of 'th_command_option.dart';

// cs <coordinate system> assumes that (calibrated) local scrap coordinates are
// given in specified coordinate system. It is useful for absolute placing of
// imported sketches where no survey stations are specified.
class THCSCommandOption extends THCommandOption {
  late final THCSPart cs;

  /// Constructor necessary for dart_mappable support.
  THCSCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.cs,
  }) : super.forCWJM();

  THCSCommandOption.fromString({
    required super.parentMPID,
    required String csString,
    required bool forOutputOnly,
    super.originalLineInTH2File = '',
  }) : super() {
    cs = THCSPart(name: csString, forOutputOnly: forOutputOnly);
  }

  THCSCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required String csString,
    required bool forOutputOnly,
    super.originalLineInTH2File = '',
  }) : super.forCWJM() {
    cs = THCSPart(name: csString, forOutputOnly: forOutputOnly);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.cs;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'cs': cs.toMap()});

    return map;
  }

  factory THCSCommandOption.fromMap(Map<String, dynamic> map) {
    return THCSCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      cs: THCSPart.fromMap(map['cs']),
    );
  }

  factory THCSCommandOption.fromJson(String jsonString) {
    return THCSCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THCSCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THCSPart? cs,
  }) {
    return THCSCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      cs: cs ?? this.cs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THCSCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.cs == cs;
  }

  @override
  int get hashCode => super.hashCode ^ cs.hashCode;

  @override
  String specToFile() {
    return cs.toString();
  }
}
