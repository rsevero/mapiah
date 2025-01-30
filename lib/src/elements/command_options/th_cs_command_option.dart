part of 'th_command_option.dart';

// cs <coordinate system> assumes that (calibrated) local scrap coordinates are given
// in specified coordinate system. It is useful for absolute placing of imported sketches
// where no survey stations are specified.
class THCSCommandOption extends THCommandOption {
  late final THCSPart cs;

  /// Constructor necessary for dart_mappable support.
  THCSCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.cs,
  }) : super.forCWJM();

  THCSCommandOption.fromString({
    required super.optionParent,
    required String csString,
    required bool forOutputOnly,
    super.originalLineInTH2File = '',
  }) : super() {
    cs = THCSPart(name: csString, forOutputOnly: forOutputOnly);
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.cs;

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'cs': cs.toMap(),
    };
  }

  factory THCSCommandOption.fromMap(Map<String, dynamic> map) {
    return THCSCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      cs: THCSPart.fromMap(map['cs']),
    );
  }

  factory THCSCommandOption.fromJson(String jsonString) {
    return THCSCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THCSCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THCSPart? cs,
  }) {
    return THCSCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      cs: cs ?? this.cs,
    );
  }

  @override
  bool operator ==(covariant THCSCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID && other.cs == cs;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        cs,
      );

  @override
  String specToFile() {
    return cs.toString();
  }
}
