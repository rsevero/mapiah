part of 'th_element.dart';

class THArea extends THElement
    with THHasOptionsMixin, THIsParentMixin, MPBoundingBox
    implements THHasPLATypeMixin {
  final THAreaType areaType;
  final String? _userDefinedPLAType;

  Set<String>? _lineTHIDs;
  Set<int>? _lineMPIDs;

  THArea.forCWJM({
    required super.mpID,
    required super.parentMPID,
    required super.sameLineComment,
    required this.areaType,
    String? userDefinedPLAType,
    required List<int> childrenMPID,
    required LinkedHashMap<THCommandOptionType, THCommandOption> optionsMap,
    required LinkedHashMap<String, THAttrCommandOption> attrOptionsMap,
    required super.originalLineInTH2File,
  }) : _userDefinedPLAType = userDefinedPLAType,
       super.forCWJM() {
    addOptionsMap(optionsMap);
    addAttrOptionsMap(attrOptionsMap);
  }

  THArea({
    required super.parentMPID,
    required this.areaType,
    String? userDefinedPLAType,
    super.originalLineInTH2File = '',
  }) : _userDefinedPLAType = userDefinedPLAType,
       super.addToParent();

  THArea.fromString({
    required super.parentMPID,
    required String areaTypeString,
    super.originalLineInTH2File = '',
  }) : areaType = THAreaType.fromFileString(areaTypeString),
       _userDefinedPLAType = (THAreaType.hasAreaType(areaTypeString))
           ? null
           : areaTypeString,
       super.addToParent();

  @override
  THElementType get elementType => THElementType.area;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'areaType': areaType.name,
      if (_userDefinedPLAType != null)
        'userDefinedPLAType': _userDefinedPLAType,
      'childrenMPID': childrenMPID.toList(),
      'optionsMap': THHasOptionsMixin.optionsMapToMap(optionsMap),
      'attrOptionsMap': THHasOptionsMixin.attrOptionsMapToMap(attrOptionsMap),
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
      userDefinedPLAType: (map.containsKey('userDefinedPLAType'))
          ? map['userDefinedPLAType']
          : null,
      childrenMPID: List<int>.from(map['childrenMPID']),
      optionsMap: THHasOptionsMixin.optionsMapFromMap(map['optionsMap']),
      attrOptionsMap: THHasOptionsMixin.attrOptionsMapFromMap(
        map['attrOptionsMap'],
      ),
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
    String? userDefinedPLAType,
    bool makeUserDefinedPLATypeNull = false,
    List<int>? childrenMPID,
    LinkedHashMap<THCommandOptionType, THCommandOption>? optionsMap,
    LinkedHashMap<String, THAttrCommandOption>? attrOptionsMap,
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
      userDefinedPLAType: makeUserDefinedPLATypeNull
          ? null
          : (userDefinedPLAType ?? this.userDefinedPLAType),
      childrenMPID: childrenMPID ?? this.childrenMPID,
      optionsMap: optionsMap ?? this.optionsMap,
      attrOptionsMap: attrOptionsMap ?? this.attrOptionsMap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THArea) return false;
    if (!super.equalsBase(other)) return false;

    final Function deepEq = const DeepCollectionEquality().equals;

    return other.areaType == areaType &&
        other.userDefinedPLAType == _userDefinedPLAType &&
        deepEq(other.childrenMPID, childrenMPID) &&
        deepEq(other.optionsMap, optionsMap) &&
        deepEq(other.attrOptionsMap, attrOptionsMap);
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        areaType,
        _userDefinedPLAType,
        childrenMPID,
        optionsMap,
        attrOptionsMap,
      );

  @override
  String get plaType {
    return ((areaType == THAreaType.userDefined) &&
            (_userDefinedPLAType != null))
        ? _userDefinedPLAType
        : areaType.toFileString();
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

      final int lineMPID = thFile.mpIDByTHID(element.thID);

      _lineMPIDs!.add(lineMPID);
      _lineTHIDs!.add(element.thID);
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

      boundingBox =
          boundingBox?.expandToInclude(
            line.getBoundingBox(th2FileEditController),
          ) ??
          line.getBoundingBox(th2FileEditController);
    }

    return boundingBox ?? Rect.zero;
  }

  @override
  String? get userDefinedPLAType {
    return (areaType == THAreaType.userDefined) ? _userDefinedPLAType : null;
  }
}
