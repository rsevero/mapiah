part of 'th_element.dart';

class THArea extends THElement
    with THHasOptionsMixin, THIsParentMixin
    implements THHasPLATypeMixin {
  late final String _areaType;

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
    required String areaType,
    required List<int> childrenMapiahID,
    required LinkedHashMap<String, THCommandOption> optionsMap,
  }) : super.forCWJM() {
    _areaType = areaType;
    addOptionsMap(optionsMap);
  }

  THArea({
    required super.parentMapiahID,
    required String areaType,
  })  : _areaType = areaType,
        super.addToParent() {
    if (!hasAreaType(areaType)) {
      throw THCustomException("Unrecognized THArea type '$areaType'.");
    }
  }

  @override
  THElementType get elementType => THElementType.area;

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': elementType.name,
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
      'areaType': _areaType,
      'childrenMapiahID': childrenMapiahID.toList(),
      'optionsMap':
          optionsMap.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory THArea.fromMap(Map<String, dynamic> map) {
    return THArea.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      areaType: map['areaType'],
      childrenMapiahID: List<int>.from(map['childrenMapiahID']),
      optionsMap: LinkedHashMap<String, THCommandOption>.from(
        map['optionsMap']
            .map((key, value) => MapEntry(key, THCommandOption.fromMap(value))),
      ),
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
    String? areaType,
    List<int>? childrenMapiahID,
    LinkedHashMap<String, THCommandOption>? optionsMap,
  }) {
    return THArea.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: sameLineComment ?? this.sameLineComment,
      areaType: areaType ?? _areaType,
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
        other._areaType == _areaType &&
        deepEq(other.childrenMapiahID, childrenMapiahID) &&
        deepEq(other.optionsMap, optionsMap);
  }

  @override
  int get hashCode => Object.hash(
        mapiahID,
        parentMapiahID,
        sameLineComment,
        _areaType,
        childrenMapiahID,
        optionsMap,
      );

  static bool hasAreaType(String areaType) {
    return _areaTypes.contains(areaType);
  }

  // @override
  // set plaType(String aAreaType) {
  //   if (!hasAreaType(aAreaType)) {
  //     throw THCustomException("Unrecognized THArea type '$aAreaType'.");
  //   }

  //   _areaType = aAreaType;
  // }

  @override
  String get plaType {
    return _areaType;
  }

  String get areaType {
    return _areaType;
  }

  @override
  bool isSameClass(Object object) {
    return object is THArea;
  }
}
