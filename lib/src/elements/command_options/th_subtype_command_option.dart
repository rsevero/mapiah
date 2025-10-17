part of 'th_command_option.dart';

// subtype <keyword> . determines the object’s subtype. The following subtypes
// for given types are supported:
//
// * points:
// ** station: temporary (default), painted, natural, fixed;
// ** air-draught: winter, summer, undefined (default);
// ** water-flow: permanent (default), intermittent, paleo.
//
// * lines:
// ** border: invisible, presumed, temporary, visible (default);
// ** survey: cave (default), surface;
// ** wall: bedrock, blocks, clay, debris, flowstone, ice, invisible, moonmilk,
//   overlying, pebbles, pit, presumed, sand, underlying, unsurveyed;
// ** water-flow: permanent (default), conjectural, intermittent.
//
// The subtype may be specified also directly in <type> specification using ‘:’
// as a separator.
// Any subtype specification can be used with user defined type (u). In this
// case you need also to define corresponding metapost symbol (see the chapter
// New map symbols).
class THSubtypeCommandOption extends THCommandOption {
  final String subtype;

  THSubtypeCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.subtype,
  }) : super.forCWJM();

  THSubtypeCommandOption({
    required super.parentMPID,
    required this.subtype,
    super.originalLineInTH2File = '',
  }) : super();

  @override
  THCommandOptionType get type => THCommandOptionType.subtype;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'subtype': subtype});

    return map;
  }

  factory THSubtypeCommandOption.fromMap(Map<String, dynamic> map) {
    return THSubtypeCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      subtype: map['subtype'],
    );
  }

  factory THSubtypeCommandOption.fromJson(String jsonString) {
    return THSubtypeCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THSubtypeCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    String? subtype,
  }) {
    return THSubtypeCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      subtype: subtype ?? this.subtype,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THSubtypeCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.subtype == subtype;
  }

  @override
  int get hashCode => super.hashCode ^ subtype.hashCode;

  @override
  String specToFile() {
    return subtype;
  }
}
