part of 'th_element.dart';

class THArea extends THElement
    with THHasOptionsMixin, THIsParentMixin, MPBoundingBox
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

  Set<String>? _lineTHIDs;
  Set<int>? _lineMPIDs;

  THArea.forCWJM({
    required super.mpID,
    required super.parentMPID,
    required super.sameLineComment,
    required this.areaType,
    required Set<int> childrenMPID,
    required LinkedHashMap<THCommandOptionType, THCommandOption> optionsMap,
    required super.originalLineInTH2File,
  }) : super.forCWJM() {
    addOptionsMap(optionsMap);
  }

  THArea({
    required super.parentMPID,
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
      'childrenMPID': childrenMPID.toList(),
      'optionsMap': THHasOptionsMixin.optionsMapToMap(optionsMap),
    });

    return map;
  }

  factory THArea.fromMap(Map<String, dynamic> map) {
    return THArea.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      areaType: THAreaType.values.byName(map['areaType']),
      childrenMPID: Set<int>.from(map['childrenMPID']),
      optionsMap: THHasOptionsMixin.optionsMapFromMap(map['optionsMap']),
    );
  }

  factory THArea.fromJson(String jsonString) {
    return THArea.fromMap(jsonDecode(jsonString));
  }

  @override
  THArea copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    THAreaType? areaType,
    Set<int>? childrenMPID,
    LinkedHashMap<THCommandOptionType, THCommandOption>? optionsMap,
  }) {
    return THArea.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      areaType: areaType ?? this.areaType,
      childrenMPID: childrenMPID ?? this.childrenMPID,
      optionsMap: optionsMap ?? this.optionsMap,
    );
  }

  @override
  bool operator ==(covariant THArea other) {
    if (identical(this, other)) return true;

    final Function deepEq = const DeepCollectionEquality().equals;

    return other.mpID == mpID &&
        other.parentMPID == parentMPID &&
        other.sameLineComment == sameLineComment &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.areaType == areaType &&
        deepEq(other.childrenMPID, childrenMPID) &&
        deepEq(other.optionsMap, optionsMap);
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        areaType,
        childrenMPID,
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

  bool isTHIDChild(String thID) {
    return childrenMPID.contains(int.parse(thID));
  }

  void _updateAreaXLineInfo(THFile thFile) {
    _lineTHIDs = <String>{};
    _lineMPIDs = <int>{};

    for (final int childMPID in childrenMPID) {
      final THElement element = thFile.elementByMPID(childMPID);

      if (element is! THAreaBorderTHID) {
        continue;
      }

      final int lineMPID = thFile.mpIDByTHID(element.id);

      _lineMPIDs!.add(lineMPID);
      _lineTHIDs!.add(element.id);
    }
  }

  Set<String> getLineTHIDs(THFile thFile) {
    if (_lineTHIDs == null) {
      _updateAreaXLineInfo(thFile);
    }

    return _lineTHIDs!;
  }

  Set<int> getLineMPIDs(THFile thFile) {
    if (_lineMPIDs == null) {
      _updateAreaXLineInfo(thFile);
    }

    return _lineMPIDs!;
  }

  bool hasLineTHID(String thID, THFile thFile) {
    return getLineTHIDs(thFile).contains(thID);
  }

  bool hasLineMPID(int mpID, THFile thFile) {
    return getLineMPIDs(thFile).contains(mpID);
  }

  void clearAreaXLineInfo() {
    _lineTHIDs = null;
    _lineMPIDs = null;
  }

  @override
  Rect calculateBoundingBox(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final Set<int> lineMPIDs = getLineMPIDs(thFile);
    Rect? boundingBox;

    for (final lineMPID in lineMPIDs) {
      final THLine line = thFile.lineByMPID(lineMPID);

      boundingBox = boundingBox
              ?.expandToInclude(line.getBoundingBox(th2FileEditController)) ??
          line.getBoundingBox(th2FileEditController);
    }

    return boundingBox ?? Rect.zero;
  }
}
