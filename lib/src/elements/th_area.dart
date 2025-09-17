part of 'th_element.dart';

class THArea extends THElement
    with THHasOptionsMixin, THIsParentMixin, MPBoundingBox, THHasPLATypeMixin {
  final THAreaType areaType;

  Set<String>? _lineTHIDs;
  List<int>? _lineMPIDs;
  List<int>? _areaBorderTHIDMPIDs;

  THArea.forCWJM({
    required super.mpID,
    required super.parentMPID,
    required super.sameLineComment,
    required this.areaType,
    required String unknownPLAType,
    required List<int> childrenMPIDs,
    required LinkedHashMap<THCommandOptionType, THCommandOption> optionsMap,
    required LinkedHashMap<String, THAttrCommandOption> attrOptionsMap,
    required super.originalLineInTH2File,
  }) : super.forCWJM() {
    _unknownPLAType = unknownPLAType;
    this.childrenMPIDs.addAll(childrenMPIDs);
    addOptionsMap(optionsMap);
    addAttrOptionsMap(attrOptionsMap);
  }

  THArea({
    required super.parentMPID,
    required this.areaType,
    required String unknownPLAType,
    super.originalLineInTH2File = '',
  }) : super.getMPID() {
    _unknownPLAType = unknownPLAType;
  }

  THArea.fromString({
    required super.parentMPID,
    required String areaTypeString,
    super.originalLineInTH2File = '',
  }) : areaType = THAreaType.fromString(areaTypeString),
       super.getMPID() {
    _unknownPLAType = THAreaType.unknownPLATypeFromString(areaTypeString);
  }

  @override
  THElementType get elementType => THElementType.area;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'areaType': areaType.name,
      'unknownPLAType': unknownPLAType,
      'childrenMPIDs': childrenMPIDs.toList(),
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
      unknownPLAType: map['unknownPLAType'],
      childrenMPIDs: List<int>.from(map['childrenMPIDs']),
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
    String? unknownPLAType,
    List<int>? childrenMPIDs,
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
      unknownPLAType: unknownPLAType ?? this.unknownPLAType,
      childrenMPIDs: childrenMPIDs ?? this.childrenMPIDs,
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
        other.unknownPLAType == unknownPLAType &&
        deepEq(other.childrenMPIDs, childrenMPIDs) &&
        deepEq(other.optionsMap, optionsMap) &&
        deepEq(other.attrOptionsMap, attrOptionsMap);
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    areaType,
    unknownPLAType,
    childrenMPIDs,
    optionsMap,
    attrOptionsMap,
  );

  @override
  String get plaType {
    return (areaType == THAreaType.unknown)
        ? unknownPLAType
        : areaType.toFileString();
  }

  @override
  bool isSameClass(Object object) {
    return object is THArea;
  }

  bool isTHIDChild(String thID) {
    return childrenMPIDs.contains(int.parse(thID));
  }

  void _updateAreaXLineInfo(THFile thFile) {
    _lineTHIDs = <String>{};
    _lineMPIDs = <int>[];
    _areaBorderTHIDMPIDs = <int>[];

    for (final int childMPID in childrenMPIDs) {
      final THElement element = thFile.elementByMPID(childMPID);

      if (element is! THAreaBorderTHID) {
        continue;
      }

      final String lineTHID = element.thID;
      final int lineMPID = thFile.mpIDByTHID(lineTHID);

      /// Checking _lineTHIDs for previous existence because _lineTHIDs is a Set
      /// so we solve eventual duplicate THIDs in the same area.
      if (!_lineTHIDs!.contains(lineTHID)) {
        _lineTHIDs!.add(lineTHID);
        _lineMPIDs!.add(lineMPID);
        _areaBorderTHIDMPIDs!.add(element.mpID);
      }
    }
  }

  Set<String> getLineTHIDs(THFile thFile) {
    if (_lineTHIDs == null) {
      _updateAreaXLineInfo(thFile);
    }

    return _lineTHIDs!;
  }

  List<int> getLineMPIDs(THFile thFile) {
    if (_lineMPIDs == null) {
      _updateAreaXLineInfo(thFile);
    }

    return _lineMPIDs!;
  }

  List<THLine> getLines(THFile thFile) {
    final List<int> lineMPIDs = getLineMPIDs(thFile);
    final List<THLine> lines = [];

    for (final int lineMPID in lineMPIDs) {
      lines.add(thFile.lineByMPID(lineMPID));
    }

    return lines;
  }

  List<THAreaBorderTHID> getAreaBorderTHIDs(THFile thFile) {
    final List<int> areaBorderTHIDMPIDs = getAreaBorderTHIDMPIDs(thFile);
    final List<THAreaBorderTHID> areaBorders = [];

    for (final int areaBorderTHIDMPID in areaBorderTHIDMPIDs) {
      areaBorders.add(thFile.areaBorderTHIDByMPID(areaBorderTHIDMPID));
    }

    return areaBorders;
  }

  List<int> getAreaBorderTHIDMPIDs(THFile thFile) {
    if (_areaBorderTHIDMPIDs == null) {
      _updateAreaXLineInfo(thFile);
    }

    return _areaBorderTHIDMPIDs!;
  }

  bool hasLineTHID(String thID, THFile thFile) {
    return getLineTHIDs(thFile).contains(thID);
  }

  bool hasLineMPID(int mpID, THFile thFile) {
    return getLineMPIDs(thFile).contains(mpID);
  }

  THAreaBorderTHID? areaBorderByLineMPID(int lineMPID, THFile thFile) {
    if (!hasLineMPID(lineMPID, thFile)) {
      return null;
    }

    final THLine line = thFile.lineByMPID(lineMPID);

    if (!line.hasOption(THCommandOptionType.id)) {
      return null;
    }

    final String lineTHID =
        (line.optionByType(THCommandOptionType.id) as THIDCommandOption).thID;

    return areaBorderByLineTHID(lineTHID, thFile);
  }

  THAreaBorderTHID? areaBorderByLineTHID(String lineTHID, THFile thFile) {
    if (!hasLineTHID(lineTHID, thFile)) {
      return null;
    }

    for (final int childMPID in childrenMPIDs) {
      final THElement element = thFile.elementByMPID(childMPID);

      if (element is THAreaBorderTHID && (element.thID == lineTHID)) {
        return element;
      }
    }

    return null;
  }

  void clearAreaXLineInfo() {
    _lineTHIDs = null;
    _lineMPIDs = null;
    _areaBorderTHIDMPIDs = null;
  }

  @override
  Rect calculateBoundingBox(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final List<int> lineMPIDs = getLineMPIDs(thFile);
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
}
