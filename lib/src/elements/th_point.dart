part of 'th_element.dart';

// Description: Point is a command for drawing a point map symbol.
// Syntax: point <x> <y> <type> [OPTIONS]
// Context: scrap
// Arguments:
// • <x> and <y> are the drawing coordinates of an object.
// • <type> determines the type of an object. The following types are supported:
// special objects: dimensions7 , section8 , station9 ;
// labels: altitude10 , date11 , height12 , label, passage-height13 , remark, station-
// name14 ;
// symbolic passage fills: 15 bedrock, blocks, clay, debris, guano, ice, mudcrack, mud,
// pebbles, raft, sand, snow, water;
// speleothems: anastomosis, aragonite, cave-pearl, clay-tree, crystal, curtains,
// curtain, disc-pillar, disc-stalactite, disc-stalagmite, disc-pillars, disc-
// stalactites, disc-stalagmites, disk, flowstone, flute, gypsum-flower, gyp-
// sum, helictites, helictite, karren, moonmilk, pendant, pillar-with-curtains,
// pillars-with-curtains, pillar, popcorn, raft-cone, rimstone-dam, rimstone-
// pool, scallop, soda-straw, stalactite-stalagmite, stalactites-stalagmites,
// stalactite, stalactites, stalagmite, stalagmites, volcano, wall-calcite;
// equipment: anchor, bridge, camp, fixed-ladder, gate, handrail, masonry, name-
// plate, no-equipment, no-wheelchair, rope-ladder, rope, steps, traverse, via-
// ferrata, walkway, wheelchair;
// passage ends: breakdown-choke, clay-choke, continuation, entrance, flowstone-
// choke, low-end, narrow-end;
// others: air-draught16 , altar, archeo-excavation, archeo-material, audio, bat,
// bones, danger, dig, electric-light, ex-voto, extra17 , gradient, human-bones,
// ice-pillar, ice-stalactite, ice-stalagmite, map-connection18 , paleo-material,
// photo, root, seed-germination, sink, spring19 , tree-trunk, u20 , vegetable-debris,
// water-drip, water-flow.
class THPoint extends THElement
    with THHasOptionsMixin, MPBoundingBoxMixin, THHasPLATypeMixin
    implements THPointInterface {
  final THPositionPart position;
  final THPointType pointType;

  THPoint.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required this.position,
    required this.pointType,
    required String unknownPLAType,
    required SplayTreeMap<THCommandOptionType, THCommandOption> optionsMap,
    required SplayTreeMap<String, THAttrCommandOption> attrOptionsMap,
    required super.originalLineInTH2File,
  }) : super.forCWJM() {
    _unknownPLAType = unknownPLAType;
    addOptionsMap(optionsMap);
    addUpdateAttrOptionsMap(attrOptionsMap);
  }

  THPoint({
    required super.parentMPID,
    super.sameLineComment,
    required this.position,
    required this.pointType,
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

  @override
  THElementType get elementType => THElementType.point;

  THPoint.fromString({
    required super.parentMPID,
    super.sameLineComment,
    required List<dynamic> pointDataList,
    required String pointTypeString,
    SplayTreeMap<THCommandOptionType, THCommandOption>? optionsMap,
    SplayTreeMap<String, THAttrCommandOption>? attrOptionsMap,
    super.originalLineInTH2File = '',
  }) : position = THPositionPart.fromStringList(list: pointDataList),
       pointType = THPointType.fromString(pointTypeString),
       super.getMPID() {
    _unknownPLAType = THPointType.unknownPLATypeFromString(pointTypeString);
    if (optionsMap != null) {
      addOptionsMap(optionsMap);
    }
    if (attrOptionsMap != null) {
      addUpdateAttrOptionsMap(attrOptionsMap);
    }
  }
  THPoint.pointTypeFromString({
    required super.parentMPID,
    super.sameLineComment,
    required this.position,
    required String pointTypeString,
    SplayTreeMap<THCommandOptionType, THCommandOption>? optionsMap,
    SplayTreeMap<String, THAttrCommandOption>? attrOptionsMap,
    super.originalLineInTH2File = '',
  }) : pointType = THPointType.fromString(pointTypeString),
       super.getMPID() {
    _unknownPLAType = THPointType.hasPointType(pointTypeString)
        ? ''
        : pointTypeString;
    if (optionsMap != null) {
      addOptionsMap(optionsMap);
    }
    if (attrOptionsMap != null) {
      addUpdateAttrOptionsMap(attrOptionsMap);
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'position': position.toMap(),
      'pointType': pointType.name,
      'unknownPLAType': unknownPLAType,
      'optionsMap': THHasOptionsMixin.optionsMapToMap(optionsMap),
      'attrOptionsMap': THHasOptionsMixin.attrOptionsMapToMap(attrOptionsMap),
    });

    return map;
  }

  factory THPoint.fromMap(Map<String, dynamic> map) {
    return THPoint.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      position: THPositionPart.fromMap(map['position']),
      pointType: THPointType.values.byName(map['pointType']),
      unknownPLAType: map['unknownPLAType'],
      optionsMap: THHasOptionsMixin.optionsMapFromMap(map['optionsMap']),
      attrOptionsMap: THHasOptionsMixin.attrOptionsMapFromMap(
        map['attrOptionsMap'],
      ),
    );
  }

  factory THPoint.fromJson(String jsonString) {
    return THPoint.fromMap(jsonDecode(jsonString));
  }

  @override
  THPoint copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    THPositionPart? position,
    THPointType? pointType,
    String? unknownPLAType,
    SplayTreeMap<THCommandOptionType, THCommandOption>? optionsMap,
    SplayTreeMap<String, THAttrCommandOption>? attrOptionsMap,
  }) {
    return THPoint.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      position: position ?? this.position,
      pointType: pointType ?? this.pointType,
      unknownPLAType: unknownPLAType ?? this.unknownPLAType,
      optionsMap: optionsMap ?? this.optionsMap,
      attrOptionsMap: attrOptionsMap ?? this.attrOptionsMap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THPoint) return false;
    if (!super.equalsBase(other)) return false;

    final Function deepEq = const DeepCollectionEquality().equals;

    return other.position == position &&
        other.pointType == pointType &&
        other.unknownPLAType == unknownPLAType &&
        deepEq(other.optionsMap, optionsMap) &&
        deepEq(other.attrOptionsMap, attrOptionsMap);
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    position,
    pointType,
    unknownPLAType,
    DeepCollectionEquality().hash(optionsMap),
    DeepCollectionEquality().hash(attrOptionsMap),
  );

  @override
  bool isSameClass(Object object) {
    return object is THPoint;
  }

  @override
  Rect calculateBoundingBox(TH2FileEditController th2FileEditController) {
    return MPNumericAux.orderedRectSmallestAroundPoint(
      center: position.coordinates,
    );
  }

  @override
  String get plaType {
    return (pointType == THPointType.unknown)
        ? unknownPLAType
        : pointType.toFileString();
  }

  @override
  double get x {
    return position.coordinates.dx;
  }

  @override
  double get y {
    return position.coordinates.dy;
  }

  int get decimalPositions {
    return position.decimalPositions;
  }

  @override
  void setTHFile(THFile thFile) {
    if (this.thFile == thFile) {
      return;
    }

    super.setTHFile(thFile);

    setTHFileToOptions(thFile);
  }
}
