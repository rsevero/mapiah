// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'th_element.dart';

class THArea extends THElement
    with
        MPBoundingBoxMixin,
        THHasOptionsMixin,
        THHasPLATypeMixin,
        THIsParentMixin {
  final THAreaType areaType;

  Set<String>? _lineTHIDs;
  List<int>? _lineMPIDs;
  List<int>? _areaBorderTHIDMPIDs;

  static const DeepCollectionEquality _deepEq = DeepCollectionEquality();

  THArea.forCWJM({
    required super.mpID,
    required super.parentMPID,
    required super.sameLineComment,
    required this.areaType,
    required String unknownPLAType,
    required List<int> childrenMPIDs,
    required SplayTreeMap<THCommandOptionType, THCommandOption> optionsMap,
    required SplayTreeMap<String, THAttrCommandOption> attrOptionsMap,
    required super.originalLineInTH2File,
  }) : super.forCWJM() {
    _unknownPLAType = unknownPLAType;
    this.childrenMPIDs.addAll(childrenMPIDs);
    addOptionsMap(optionsMap);
    addUpdateAttrOptionsMap(attrOptionsMap);
  }

  THArea({
    required super.parentMPID,
    required this.areaType,
    required String unknownPLAType,
    SplayTreeMap<THCommandOptionType, THCommandOption>? optionsMap,
    SplayTreeMap<String, THAttrCommandOption>? attrOptionsMap,
    super.originalLineInTH2File = '',
  }) : super.getMPID() {
    _unknownPLAType = unknownPLAType;
    if (optionsMap != null) {
      addOptionsMap(optionsMap);
    }
    if (attrOptionsMap != null) {
      addUpdateAttrOptionsMap(attrOptionsMap);
    }
  }

  THArea.fromString({
    required super.parentMPID,
    required String areaTypeString,
    SplayTreeMap<THCommandOptionType, THCommandOption>? optionsMap,
    SplayTreeMap<String, THAttrCommandOption>? attrOptionsMap,
    super.originalLineInTH2File = '',
  }) : areaType = THAreaType.fromString(areaTypeString),
       super.getMPID() {
    _unknownPLAType = THAreaType.unknownPLATypeFromString(areaTypeString);
    if (optionsMap != null) {
      addOptionsMap(optionsMap);
    }
    if (attrOptionsMap != null) {
      addUpdateAttrOptionsMap(attrOptionsMap);
    }
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
    SplayTreeMap<THCommandOptionType, THCommandOption>? optionsMap,
    SplayTreeMap<String, THAttrCommandOption>? attrOptionsMap,
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
      childrenMPIDs: childrenMPIDs ?? this.childrenMPIDs.toList(),
      optionsMap:
          optionsMap ??
          SplayTreeMap<THCommandOptionType, THCommandOption>.from(
            this.optionsMap,
          ),
      attrOptionsMap:
          attrOptionsMap ??
          SplayTreeMap<String, THAttrCommandOption>.from(this.attrOptionsMap),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THArea) return false;
    if (!super.equalsBase(other)) return false;

    final Function deepEq = _deepEq.equals;

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
    DeepCollectionEquality().hash(childrenMPIDs),
    DeepCollectionEquality().hash(optionsMap),
    DeepCollectionEquality().hash(attrOptionsMap),
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

  void _updateAreaXLineInfo(TH2File th2File) {
    _lineTHIDs = <String>{};
    _lineMPIDs = <int>[];
    _areaBorderTHIDMPIDs = <int>[];

    for (final int childMPID in childrenMPIDs) {
      final THElement element = th2File.elementByMPID(childMPID);

      if (element is! THAreaBorderTHID) {
        continue;
      }

      final String lineTHID = element.thID;
      final int? lineMPID = th2File.mpIDByTHID(lineTHID);

      /// Checking _lineTHIDs for previous existence because _lineTHIDs is a Set
      /// so we solve eventual duplicate THIDs in the same area.
      if ((lineMPID != null) && !_lineTHIDs!.contains(lineTHID)) {
        _lineTHIDs!.add(lineTHID);
        _lineMPIDs!.add(lineMPID);
        _areaBorderTHIDMPIDs!.add(element.mpID);
      }
    }
  }

  Set<String> getLineTHIDs(TH2File th2File) {
    if (_lineTHIDs == null) {
      _updateAreaXLineInfo(th2File);
    }

    return _lineTHIDs!;
  }

  List<int> getLineMPIDs(TH2File th2File) {
    if (_lineMPIDs == null) {
      _updateAreaXLineInfo(th2File);
    }

    return _lineMPIDs!;
  }

  List<THLine> getLines(TH2File th2File) {
    final List<int> lineMPIDs = getLineMPIDs(th2File);
    final List<THLine> lines = [];

    for (final int lineMPID in lineMPIDs) {
      lines.add(th2File.lineByMPID(lineMPID));
    }

    return lines;
  }

  List<THAreaBorderTHID> getAreaBorderTHIDs(TH2File th2File) {
    final List<int> areaBorderTHIDMPIDs = getAreaBorderTHIDMPIDs(th2File);
    final List<THAreaBorderTHID> areaBorders = [];

    for (final int areaBorderTHIDMPID in areaBorderTHIDMPIDs) {
      areaBorders.add(th2File.areaBorderTHIDByMPID(areaBorderTHIDMPID));
    }

    return areaBorders;
  }

  List<int> getAreaBorderTHIDMPIDs(TH2File th2File) {
    if (_areaBorderTHIDMPIDs == null) {
      _updateAreaXLineInfo(th2File);
    }

    return _areaBorderTHIDMPIDs!;
  }

  bool hasLineTHID(String thID, TH2File th2File) {
    return getLineTHIDs(th2File).contains(thID);
  }

  bool hasLineMPID(int mpID, TH2File th2File) {
    return getLineMPIDs(th2File).contains(mpID);
  }

  THAreaBorderTHID? areaBorderByLineMPID(int lineMPID, TH2File th2File) {
    if (!hasLineMPID(lineMPID, th2File)) {
      return null;
    }

    final THLine line = th2File.lineByMPID(lineMPID);

    if (!line.hasOption(THCommandOptionType.id)) {
      return null;
    }

    final String lineTHID =
        (line.getOption(THCommandOptionType.id) as THIDCommandOption).thID;

    return areaBorderByLineTHID(lineTHID, th2File);
  }

  THAreaBorderTHID? areaBorderByLineTHID(String lineTHID, TH2File th2File) {
    if (!hasLineTHID(lineTHID, th2File)) {
      return null;
    }

    for (final int childMPID in childrenMPIDs) {
      final THElement element = th2File.elementByMPID(childMPID);

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
  void removeElementFromParent(THElement element) {
    super.removeElementFromParent(element);

    if (element is THAreaBorderTHID) {
      clearAreaXLineInfo();
    }
  }

  @override
  Rect calculateBoundingBox(TH2FileEditController th2FileEditController) {
    final TH2File th2File = th2FileEditController.th2File;
    final List<int> lineMPIDs = getLineMPIDs(th2File);
    Rect? boundingBox;

    for (final lineMPID in lineMPIDs) {
      final THLine line = th2File.lineByMPID(lineMPID);

      boundingBox =
          boundingBox?.expandToInclude(
            line.getBoundingBox(th2FileEditController)!,
          ) ??
          line.getBoundingBox(th2FileEditController)!;
    }

    return boundingBox ?? Rect.zero;
  }

  @override
  void setTHFile(TH2File th2File) {
    if (this.th2File == th2File) {
      return;
    }

    super.setTHFile(th2File);

    setTHFileToOptions(th2File);
    setTHFileToChildren(th2File);
  }

  @override
  String get typeSubtypeID {
    return MPCommandOptionAux.getPLATypeAndSubtypeID(
      plaType: areaType.name,
      plaSubtype: MPCommandOptionAux.getSubtype(this) ?? '',
    );
  }
}
