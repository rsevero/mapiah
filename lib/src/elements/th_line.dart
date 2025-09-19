part of 'th_element.dart';

// Description: Line is a command for drawing a line symbol on the map. Each line symbol
// is oriented and its visualization may depend on its orientation (e.g. pitch edge ticks). The
// general rule is that the free space is on the left, rock on the right. Examples: the lower
// side of a pitch, higher side of a chimney and interior of a passage are on the left side of
// pitch, chimney or wall symbols, respectively.
class THLine extends THElement
    with THHasOptionsMixin, THIsParentMixin, MPBoundingBox, THHasPLATypeMixin {
  final THLineType lineType;
  final List<int> _lineSegmentMPIDs;

  THLine.forCWJM({
    required super.mpID,
    required super.parentMPID,
    required super.sameLineComment,
    required this.lineType,
    required String unknownPLAType,
    required List<int> childrenMPIDs,
    required List<int> lineSegmentMPIDs,
    required LinkedHashMap<THCommandOptionType, THCommandOption> optionsMap,
    required LinkedHashMap<String, THAttrCommandOption> attrOptionsMap,
    required super.originalLineInTH2File,
  }) : _lineSegmentMPIDs = lineSegmentMPIDs,
       super.forCWJM() {
    _unknownPLAType = unknownPLAType;
    this.childrenMPIDs.addAll(childrenMPIDs);
    addOptionsMap(optionsMap);
    addAttrOptionsMap(attrOptionsMap);
  }

  THLine({
    required super.parentMPID,
    required this.lineType,
    required String unknownPLAType,
    super.sameLineComment,
    super.originalLineInTH2File = '',
  }) : _lineSegmentMPIDs = [],
       super.getMPID() {
    _unknownPLAType = unknownPLAType;
  }

  THLine.fromString({
    required super.parentMPID,
    required String lineTypeString,
    super.sameLineComment,
    super.originalLineInTH2File = '',
  }) : lineType = THLineType.fromString(lineTypeString),
       _lineSegmentMPIDs = [],
       super.getMPID() {
    _unknownPLAType = THLineType.unknownPLATypeFromString(lineTypeString);
  }

  @override
  THElementType get elementType => THElementType.line;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'lineType': lineType.name,
      'unknownPLAType': unknownPLAType,
      'childrenMPIDs': childrenMPIDs.toList(),
      'lineSegmentMPIDs': _lineSegmentMPIDs,
      'optionsMap': THHasOptionsMixin.optionsMapToMap(optionsMap),
      'attrOptionsMap': THHasOptionsMixin.attrOptionsMapToMap(attrOptionsMap),
    });

    return map;
  }

  factory THLine.fromMap(Map<String, dynamic> map) {
    return THLine.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      lineType: THLineType.values.byName(map['lineType']),
      unknownPLAType: map['unknownPLAType'],
      childrenMPIDs: List<int>.from(map['childrenMPIDs']),
      lineSegmentMPIDs: List<int>.from(map['lineSegmentMPIDs']),
      optionsMap: THHasOptionsMixin.optionsMapFromMap(map['optionsMap']),
      attrOptionsMap: THHasOptionsMixin.attrOptionsMapFromMap(
        map['attrOptionsMap'],
      ),
    );
  }

  factory THLine.fromJson(String jsonString) {
    return THLine.fromMap(jsonDecode(jsonString));
  }

  @override
  THLine copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    THLineType? lineType,
    String? unknownPLAType,
    List<int>? childrenMPIDs,
    List<int>? lineSegmentMPIDs,
    LinkedHashMap<THCommandOptionType, THCommandOption>? optionsMap,
    LinkedHashMap<String, THAttrCommandOption>? attrOptionsMap,
  }) {
    return THLine.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      lineType: lineType ?? this.lineType,
      unknownPLAType: unknownPLAType ?? this.unknownPLAType,
      childrenMPIDs: childrenMPIDs ?? this.childrenMPIDs,
      lineSegmentMPIDs: lineSegmentMPIDs ?? _lineSegmentMPIDs,
      optionsMap: optionsMap ?? this.optionsMap,
      attrOptionsMap: attrOptionsMap ?? this.attrOptionsMap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THLine) return false;
    if (!super.equalsBase(other)) return false;

    final Function deepEq = const DeepCollectionEquality().equals;

    return other.lineType == lineType &&
        other.unknownPLAType == unknownPLAType &&
        deepEq(other.childrenMPIDs, childrenMPIDs) &&
        deepEq(other.lineSegmentMPIDs, _lineSegmentMPIDs) &&
        deepEq(other.optionsMap, optionsMap) &&
        deepEq(other.attrOptionsMap, attrOptionsMap);
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    lineType,
    unknownPLAType,
    childrenMPIDs,
    _lineSegmentMPIDs,
    optionsMap,
    attrOptionsMap,
  );

  @override
  bool isSameClass(Object object) {
    return object is THLine;
  }

  @override
  Rect calculateBoundingBox(TH2FileEditController th2FileEditController) {
    if (childrenMPIDs.isEmpty) {
      return Rect.zero;
    }

    final THFile thFile = th2FileEditController.thFile;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    bool isFirst = true;
    Offset startPoint = Offset.zero;

    for (final int childMPID in childrenMPIDs) {
      final THElement child = thFile.elementByMPID(childMPID);

      if (child is! THLineSegment) {
        continue;
      }

      if (isFirst) {
        startPoint = child.endPoint.coordinates;
        isFirst = false;
        continue;
      }

      final Rect childBoundingBox = child.getBoundingBox(startPoint);

      startPoint = child.endPoint.coordinates;

      if (childBoundingBox.left < minX) {
        minX = childBoundingBox.left;
      }
      if (childBoundingBox.right > maxX) {
        maxX = childBoundingBox.right;
      }
      if (childBoundingBox.top < minY) {
        minY = childBoundingBox.top;
      }
      if (childBoundingBox.bottom > maxY) {
        maxY = childBoundingBox.bottom;
      }
    }

    return MPNumericAux.orderedRectFromLTRB(
      left: minX,
      top: minY,
      right: maxX,
      bottom: maxY,
    );
  }

  int? getNextLineSegmentMPID(int lineSegmentMPID, THFile thFile) {
    final int indexLineSegmentMPID = getLineSegmentIndexByMPID(lineSegmentMPID);

    if (indexLineSegmentMPID == -1) {
      throw Exception(
        'THLine.getNextLineSegmentMPID: lineSegmentMPID not found',
      );
    }

    if (indexLineSegmentMPID == _lineSegmentMPIDs.length - 1) {
      return null;
    }

    return _lineSegmentMPIDs[indexLineSegmentMPID + 1];
  }

  int? getPreviousLineSegmentMPID(int lineSegmentMPID, THFile thFile) {
    int? previousLineSegmentMPID;

    for (final int childMPID in childrenMPIDs) {
      final THElementType childElementType = thFile.getElementTypeByMPID(
        childMPID,
      );

      if ((childElementType != THElementType.bezierCurveLineSegment) &&
          (childElementType != THElementType.straightLineSegment)) {
        continue;
      }

      if (childMPID == lineSegmentMPID) {
        return previousLineSegmentMPID;
      }

      previousLineSegmentMPID = childMPID;
    }

    throw Exception(
      'THLine.getPreviousLineSegmentMPID: lineSegmentMPID not found',
    );
  }

  THLineSegment? getPreviousLineSegment(
    THLineSegment lineSegment,
    THFile thFile,
  ) {
    final int? previousLineSegmentMPID = getPreviousLineSegmentMPID(
      lineSegment.mpID,
      thFile,
    );

    return previousLineSegmentMPID == null
        ? null
        : thFile.elementByMPID(previousLineSegmentMPID) as THLineSegment;
  }

  bool isFirstLineSegment(THLineSegment lineSegment, THFile thFile) {
    final int? previousLineSegmentMPID = getPreviousLineSegmentMPID(
      lineSegment.mpID,
      thFile,
    );

    return previousLineSegmentMPID == null;
  }

  bool isLastLineSegment(THLineSegment lineSegment, THFile thFile) {
    final int? nextLineSegmentMPID = getNextLineSegmentMPID(
      lineSegment.mpID,
      thFile,
    );

    return nextLineSegmentMPID == null;
  }

  THLineSegment? getNextLineSegment(THLineSegment lineSegment, THFile thFile) {
    final int? nextLineSegmentMPID = getNextLineSegmentMPID(
      lineSegment.mpID,
      thFile,
    );

    return nextLineSegmentMPID == null
        ? null
        : thFile.elementByMPID(nextLineSegmentMPID) as THLineSegment;
  }

  @override
  String get plaType {
    return (lineType == THLineType.unknown)
        ? unknownPLAType
        : lineType.toFileString();
  }

  void addLineSegmentMPID(int lineSegmentMPID) {
    _lineSegmentMPIDs.add(lineSegmentMPID);
    clearBoundingBox();
  }

  int getLineSegmentIndexByMPID(int lineSegmentMPID) {
    return _lineSegmentMPIDs.indexOf(lineSegmentMPID);
  }

  void removeLineSegmentMPID(int lineSegmentMPID) {
    _lineSegmentMPIDs.remove(lineSegmentMPID);
    clearBoundingBox();
  }

  List<int> get lineSegmentMPIDs => _lineSegmentMPIDs;

  List<THLineSegment> getLineSegments(THFile thFile) {
    final List<THLineSegment> lineSegments = [];

    for (final int lineSegmentMPID in _lineSegmentMPIDs) {
      final THLineSegment lineSegment =
          thFile.elementByMPID(lineSegmentMPID) as THLineSegment;

      lineSegments.add(lineSegment);
    }

    return lineSegments;
  }

  @override
  void addElementToParent(
    THElement element, {
    int elementPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
  }) {
    super.addElementToParent(
      element,
      elementPositionInParent: elementPositionInParent,
    );

    if (element is THLineSegment) {
      addLineSegmentMPID(element.mpID);
    }
  }

  @override
  void removeElementFromParent(THFile thFile, THElement element) {
    super.removeElementFromParent(thFile, element);

    if (element is THLineSegment) {
      removeLineSegmentMPID(element.mpID);
    }
  }

  void insertLineSegmentBefore(
    THLineSegment lineSegment,
    int beforeLineSegmentMPID,
  ) {
    final int childrenMPIDIndex = getLineSegmentIndexByMPID(
      beforeLineSegmentMPID,
    );

    if (childrenMPIDIndex == -1) {
      throw Exception(
        'THLine.insertLineSegmentBefore: line segment not found in childrenMPID',
      );
    }

    childrenMPIDs.insert(childrenMPIDIndex, lineSegment.mpID);

    final int lineSegmentsMPIDsIndex = getLineSegmentIndexByMPID(
      beforeLineSegmentMPID,
    );

    if (lineSegmentsMPIDsIndex == -1) {
      throw Exception(
        'THLine.insertLineSegmentBefore: line segment not found in lineSegmentsMPIDs',
      );
    }

    _lineSegmentMPIDs.insert(lineSegmentsMPIDsIndex, lineSegment.mpID);
    clearBoundingBox();
  }

  LinkedHashMap<int, THLineSegment> getLineSegmentsMap(THFile thFile) {
    final LinkedHashMap<int, THLineSegment> lineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();

    for (final int lineSegmentMPID in _lineSegmentMPIDs) {
      final THLineSegment lineSegment =
          thFile.elementByMPID(lineSegmentMPID) as THLineSegment;

      lineSegmentsMap[lineSegmentMPID] = lineSegment;
    }

    return lineSegmentsMap;
  }
}
