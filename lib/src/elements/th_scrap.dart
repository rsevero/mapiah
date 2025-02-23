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

  THScrap.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required String thID,
    required Set<int> childrenMapiahID,
    required LinkedHashMap<String, THCommandOption> optionsMap,
    required super.originalLineInTH2File,
  }) : super.forCWJM() {
    _thID = thID;
    this.childrenMapiahID.addAll(childrenMapiahID);
    addOptionsMap(optionsMap);
  }

  THScrap({
    required super.parentMapiahID,
    required String thID,
    super.originalLineInTH2File = '',
  }) : super.addToParent() {
    _thID = thID;
  }

  @override
  THElementType get elementType => THElementType.scrap;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'thID': _thID,
      'childrenMapiahID': childrenMapiahID.toList(),
      'optionsMap':
          optionsMap.map((key, value) => MapEntry(key, value.toMap())),
    });

    return map;
  }

  factory THScrap.fromMap(Map<String, dynamic> map) {
    return THScrap.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      thID: map['thID'],
      childrenMapiahID: Set<int>.from(map['childrenMapiahID']),
      optionsMap: LinkedHashMap<String, THCommandOption>.from(
        map['optionsMap']
            .map((key, value) => MapEntry(key, THCommandOption.fromMap(value))),
      ),
    );
  }

  factory THScrap.fromJson(String jsonString) {
    return THScrap.fromMap(jsonDecode(jsonString));
  }

  @override
  THScrap copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    String? thID,
    Set<int>? childrenMapiahID,
    LinkedHashMap<String, THCommandOption>? optionsMap,
  }) {
    return THScrap.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      thID: thID ?? _thID,
      childrenMapiahID: childrenMapiahID ?? this.childrenMapiahID,
      optionsMap: optionsMap ?? this.optionsMap,
    );
  }

  @override
  bool operator ==(covariant THScrap other) {
    if (identical(this, other)) return true;

    final Function deepEq = const DeepCollectionEquality().equals;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other._thID == _thID &&
        deepEq(other.childrenMapiahID, childrenMapiahID) &&
        deepEq(other.optionsMap, optionsMap);
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        _thID,
        childrenMapiahID,
        optionsMap,
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
    return calculateChildrenBoundingBox(
        th2FileEditController, childrenMapiahID);
  }
}
