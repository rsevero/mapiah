part of 'th_element.dart';

class THArea extends THElement
    with THHasOptionsMixin, THIsParentMixin
    implements THHasPLATypeMixin {
  final THAreaType areaType;

  static final _areaTypes = <String>{
    'bedrock',
    'blocks',
    'clay',
    'debris',
    'flowstone',
    'ice',
    'moonmilk',
    'mudcrack',
    'pebbles',
    'pillar',
    'pillar-with-curtains',
    'pillars',
    'pillars-with-curtains',
    'sand',
    'snow',
    'stalactite',
    'stalactite-stalagmite',
    'stalagmite',
    'sump',
    'u',
    'water',
  };

  THArea.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    required super.sameLineComment,
    required this.areaType,
    required Set<int> childrenMapiahID,
    required LinkedHashMap<THCommandOptionType, THCommandOption> optionsMap,
    required super.originalLineInTH2File,
  }) : super.forCWJM() {
    addOptionsMap(optionsMap);
  }

  THArea({
    required super.parentMapiahID,
    required String areaTypeString,
    super.originalLineInTH2File = '',
  })  : areaType = THAreaType.fromFileString(areaTypeString),
        super.addToParent();

  @override
  THElementType get elementType => THElementType.area;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'areaType': areaType.name,
      'childrenMapiahID': childrenMapiahID.toList(),
      'optionsMap':
          optionsMap.map((key, value) => MapEntry(key.name, value.toMap())),
    });

    return map;
  }

  factory THArea.fromMap(Map<String, dynamic> map) {
    return THArea.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      areaType: THAreaType.values.byName(map['areaType']),
      childrenMapiahID: Set<int>.from(map['childrenMapiahID']),
      optionsMap: THHasOptionsMixin.optionsMapFromMap(map['optionsMap']),
    );
  }

  factory THArea.fromJson(String jsonString) {
    return THArea.fromMap(jsonDecode(jsonString));
  }

  @override
  THArea copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    THAreaType? areaType,
    Set<int>? childrenMapiahID,
    LinkedHashMap<THCommandOptionType, THCommandOption>? optionsMap,
  }) {
    return THArea.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      areaType: areaType ?? this.areaType,
      childrenMapiahID: childrenMapiahID ?? this.childrenMapiahID,
      optionsMap: optionsMap ?? this.optionsMap,
    );
  }

  @override
  bool operator ==(covariant THArea other) {
    if (identical(this, other)) return true;

    final Function deepEq = const DeepCollectionEquality().equals;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.areaType == areaType &&
        deepEq(other.childrenMapiahID, childrenMapiahID) &&
        deepEq(other.optionsMap, optionsMap);
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        areaType,
        childrenMapiahID,
        optionsMap,
      );

  static bool hasAreaType(String areaType) {
    return _areaTypes.contains(areaType);
  }

  @override
  String get plaType {
    return areaType.name;
  }

  @override
  bool isSameClass(Object object) {
    return object is THArea;
  }
}
