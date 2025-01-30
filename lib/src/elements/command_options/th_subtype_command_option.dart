part of 'th_command_option.dart';

// subtype <keyword> . determines the object’s subtype. The following subtypes for
// given types are supported:
// station: 21 temporary (default), painted, natural, fixed;
// air-draught: winter, summer, undefined (default);
// water-flow: permanent (default), intermittent, paleo.
// The subtype may be specified also directly in <type> specification using ‘:’ as a
// separator.22
// Any subtype specification can be used with user defined type (u). In this case you need
// also to define corresponding metapost symbol (see the chapter New map symbols).
class THSubtypeCommandOption extends THCommandOption {
  final String subtype;

  // static final Map<String, Map<String, Map<String, Object>>> _allowedSubtypes =
  //     {
  //   'point': {
  //     'air-draught': {
  //       'default': 'undefined',
  //       'subtypes': <String>{
  //         'winter',
  //         'summer',
  //         'undefined',
  //       },
  //     },
  //     'station': {
  //       'default': 'temporary',
  //       'subtypes': <String>{
  //         'temporary',
  //         'painted',
  //         'natural',
  //         'fixed',
  //       },
  //     },
  //     'water-flow': {
  //       'default': 'permanent',
  //       'subtypes': <String>{
  //         'permanent',
  //         'intermittent',
  //         'paleo',
  //       },
  //     },
  //   },
  //   'line': {
  //     'border': {
  //       'default': 'visible',
  //       'subtypes': <String>{
  //         'invisible',
  //         'presumed',
  //         'temporary',
  //         'visible',
  //       },
  //     },
  //     'survey': {
  //       'default': 'cave',
  //       'subtypes': <String>{
  //         'cave',
  //         'surface',
  //       },
  //     },
  //     'wall': {
  //       'default': 'bedrock',
  //       'subtypes': <String>{
  //         'bedrock',
  //         'blocks',
  //         'clay',
  //         'debris',
  //         'flowstone',
  //         'ice',
  //         'invisible',
  //         'moonmilk',
  //         'overlying',
  //         'pebbles',
  //         'pit',
  //         'presumed',
  //         'sand',
  //         'underlying',
  //         'unsurveyed',
  //       },
  //     },
  //     'water-flow': {
  //       'default': 'permanent',
  //       'subtypes': <String>{
  //         'permanent',
  //         'conjectural',
  //         'intermittent',
  //       },
  //     },
  //   },
  // };

  THSubtypeCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.subtype,
  }) : super.forCWJM();

  THSubtypeCommandOption({
    required super.optionParent,
    required this.subtype,
    super.originalLineInTH2File = '',
  }) : super();

  @override
  THCommandOptionType get optionType => THCommandOptionType.subtype;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'subtype': subtype,
    });

    return map;
  }

  factory THSubtypeCommandOption.fromMap(Map<String, dynamic> map) {
    return THSubtypeCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      subtype: map['subtype'],
    );
  }

  factory THSubtypeCommandOption.fromJson(String jsonString) {
    return THSubtypeCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THSubtypeCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    String? subtype,
  }) {
    return THSubtypeCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      subtype: subtype ?? this.subtype,
    );
  }

  @override
  bool operator ==(covariant THSubtypeCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.subtype == subtype;
  }

  @override
  int get hashCode => super.hashCode ^ subtype.hashCode;

  @override
  String specToFile() {
    return subtype;
  }
}
