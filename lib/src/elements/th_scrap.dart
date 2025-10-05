part of 'th_element.dart';

// Description: Scrap is a piece of 2D map, which doesn’t contain overlapping passages
// (i.e. all the passages may be drawn on the paper without overlapping). For small and
// simple caves, the whole cave may belong to one scrap. In complicated systems, a scrap is
// 21usually one chamber or one passage. Ideally, a scrap contains about 100 m of the cave.5
// Each scrap is processed separately by METAPOST; scraps which are too large may exceed
// METAPOST’s memory and cause errors.
// Scrap consists of point, line and area map symbols. See chapter How the map is put
// together for explanation how and in which order are they displayed.
// Scrap border consists of lines with the -outline out or -outline in options (passage
// walls have -outline out by default). These lines shouldn’t intersect—otherwise Therion
// (METAPOST) can’t determine the interior of the scrap and METAPOST issues a warning
// message “scrap outline intersects itself”.
// Each scrap has its own local cartesian coordinate system, which usually corresponds with
// the millimeter paper (if you measure the coordinates of map symbols by hand) or pixels
// of the scanned image (if you use XTherion). Therion does the transformation from this
// local coordinate system to the real coordinates using the positions of survey stations,
// which are specified both in the scrap as point map symbols and in centreline data. If the
// scrap doesn’t contain at least two survey stations with the -name reference, you have to
// use the -scale option for calibrating the scrap. (This is usual for cross sections.)
class THScrap extends THElement
    with
        THHasOptionsMixin,
        THIsParentMixin,
        THCalculateChildrenBoundingBoxMixin,
        MPBoundingBox
    implements THHasTHID {
  late String _thID;

  static const DeepCollectionEquality _deepEq = DeepCollectionEquality();

  THScrap.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required String thID,
    required List<int> childrenMPIDs,
    required SplayTreeMap<THCommandOptionType, THCommandOption> optionsMap,
    required SplayTreeMap<String, THAttrCommandOption> attrOptionsMap,
    required super.originalLineInTH2File,
  }) : super.forCWJM() {
    _thID = thID;
    this.childrenMPIDs.addAll(childrenMPIDs);
    addOptionsMap(optionsMap);
    addAttrOptionsMap(attrOptionsMap);
  }

  THScrap({
    required super.parentMPID,
    required String thID,
    super.originalLineInTH2File = '',
  }) : super.getMPID() {
    _thID = thID;
  }

  @override
  THElementType get elementType => THElementType.scrap;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'thID': _thID,
      'childrenMPIDs': childrenMPIDs.toList(),
      'optionsMap': THHasOptionsMixin.optionsMapToMap(optionsMap),
      'attrOptionsMap': THHasOptionsMixin.attrOptionsMapToMap(attrOptionsMap),
    });

    return map;
  }

  factory THScrap.fromMap(Map<String, dynamic> map) {
    return THScrap.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      thID: map['thID'],
      childrenMPIDs: List<int>.from(map['childrenMPIDs']),
      optionsMap: THHasOptionsMixin.optionsMapFromMap(map['optionsMap']),
      attrOptionsMap: THHasOptionsMixin.attrOptionsMapFromMap(
        map['attrOptionsMap'],
      ),
    );
  }

  factory THScrap.fromJson(String jsonString) {
    return THScrap.fromMap(jsonDecode(jsonString));
  }

  @override
  THScrap copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    String? thID,
    List<int>? childrenMPIDs,
    SplayTreeMap<THCommandOptionType, THCommandOption>? optionsMap,
    SplayTreeMap<String, THAttrCommandOption>? attrOptionsMap,
  }) {
    return THScrap.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      thID: thID ?? _thID,
      childrenMPIDs: childrenMPIDs ?? this.childrenMPIDs,
      optionsMap: optionsMap ?? this.optionsMap,
      attrOptionsMap: attrOptionsMap ?? this.attrOptionsMap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THScrap) return false;
    if (!super.equalsBase(other)) return false;

    final Function deepEq = _deepEq.equals;

    return other._thID == _thID &&
        deepEq(other.childrenMPIDs, childrenMPIDs) &&
        deepEq(other.optionsMap, optionsMap) &&
        deepEq(other.attrOptionsMap, attrOptionsMap);
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    _thID,
    _deepEq.hash(childrenMPIDs),
    _deepEq.hash(optionsMap),
    _deepEq.hash(attrOptionsMap),
  );

  @override
  bool isSameClass(Object object) {
    return object is THScrap;
  }

  @override
  String get thID {
    return _thID;
  }

  void setTHID(THFile thFile, String aTHID) {
    thFile.updateTHID(this, aTHID);
    _thID = aTHID;
  }

  @override
  Rect calculateBoundingBox(TH2FileEditController th2FileEditController) {
    return calculateChildrenBoundingBox(th2FileEditController, childrenMPIDs);
  }
}
