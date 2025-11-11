part of 'th_element.dart';

// Description: Line is a command for drawing a line symbol on the map. Each line symbol
// is oriented and its visualization may depend on its orientation (e.g. pitch edge ticks). The
// general rule is that the free space is on the left, rock on the right. Examples: the lower
// side of a pitch, higher side of a chimney and interior of a passage are on the left side of
// pitch, chimney or wall symbols, respectively.
class THLine extends THElement
    with THHasOptionsMixin, THIsParentMixin, MPBoundingBox, THHasPLATypeMixin {
  final THLineType lineType;

  List<int>? _lineSegmentMPIDs;
  List<THLineSegment>? _lineSegments;

  THLine.forCWJM({
    required super.mpID,
    required super.parentMPID,
    required super.sameLineComment,
    required this.lineType,
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

  THLine({
    required super.parentMPID,
    required this.lineType,
    required String unknownPLAType,
    super.sameLineComment,
    super.originalLineInTH2File = '',
  }) : super.getMPID() {
    _unknownPLAType = unknownPLAType;
  }

  THLine.fromString({
    required super.parentMPID,
    required String lineTypeString,
    super.sameLineComment,
    super.originalLineInTH2File = '',
  }) : lineType = THLineType.fromString(lineTypeString),

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
    SplayTreeMap<THCommandOptionType, THCommandOption>? optionsMap,
    SplayTreeMap<String, THAttrCommandOption>? attrOptionsMap,
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
        deepEq(other.optionsMap, optionsMap) &&
        deepEq(other.attrOptionsMap, attrOptionsMap);
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    lineType,
    unknownPLAType,
    const DeepCollectionEquality().hash(childrenMPIDs),
    const DeepCollectionEquality().hash(optionsMap),
    const DeepCollectionEquality().hash(attrOptionsMap),
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
    final int indexLineSegmentMPID = getLineSegmentIndexByMPID(
      lineSegmentMPID,
      thFile,
    );

    if (indexLineSegmentMPID == -1) {
      throw Exception(
        'THLine.getNextLineSegmentMPID: lineSegmentMPID not found',
      );
    }

    final List<int> lineSegmentMPIDs = getLineSegmentMPIDs(thFile);

    if (indexLineSegmentMPID == lineSegmentMPIDs.length - 1) {
      return null;
    }

    return lineSegmentMPIDs[indexLineSegmentMPID + 1];
  }

  List<int> getLineSegmentMPIDs(THFile thFile) {
    _lineSegmentMPIDs ??= _generateLineSegmentMPIDs(thFile);

    return _lineSegmentMPIDs!;
  }

  List<int> _generateLineSegmentMPIDs(THFile thFile) {
    final List<int> lineSegmentMPIDs = [];

    for (final int childMPID in childrenMPIDs) {
      final THElementType childType = thFile.getElementTypeByMPID(childMPID);

      if ((childType == THElementType.bezierCurveLineSegment) ||
          (childType == THElementType.straightLineSegment)) {
        lineSegmentMPIDs.add(childMPID);
      }
    }

    return lineSegmentMPIDs;
  }

  List<THLineSegment> getLineSegments(THFile thFile) {
    _lineSegments ??= _generateLineSegmentsList(thFile);

    return _lineSegments!;
  }

  List<THLineSegment> _generateLineSegmentsList(THFile thFile) {
    final List<THLineSegment> lineSegments = [];
    final List<int> lineSegmentMPIDs = getLineSegmentMPIDs(thFile);

    for (final int lineSegmentMPID in lineSegmentMPIDs) {
      final THLineSegment lineSegment = thFile.lineSegmentByMPID(
        lineSegmentMPID,
      );

      lineSegments.add(lineSegment);
    }

    return lineSegments;
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

  void resetLineSegmentsLists() {
    _lineSegmentMPIDs = null;
    _lineSegments = null;

    clearBoundingBox();
  }

  int getLineSegmentIndexByMPID(int lineSegmentMPID, THFile thFile) {
    return getLineSegmentMPIDs(thFile).indexOf(lineSegmentMPID);
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
      resetLineSegmentsLists();
    }
  }

  @override
  void removeElementFromParent(THFile thFile, THElement element) {
    super.removeElementFromParent(thFile, element);

    if (element is THLineSegment) {
      resetLineSegmentsLists();
    }
  }

  void insertLineSegmentBefore(
    THLineSegment lineSegment,
    int beforeLineSegmentMPID,
    THFile thFile,
  ) {
    final int childrenMPIDIndex = getLineSegmentIndexByMPID(
      beforeLineSegmentMPID,
      thFile,
    );

    if (childrenMPIDIndex == -1) {
      throw Exception(
        'THLine.insertLineSegmentBefore: line segment not found in childrenMPID',
      );
    }

    childrenMPIDs.insert(childrenMPIDIndex, lineSegment.mpID);

    final int lineSegmentsMPIDsIndex = getLineSegmentIndexByMPID(
      beforeLineSegmentMPID,
      thFile,
    );

    if (lineSegmentsMPIDsIndex == -1) {
      throw Exception(
        'THLine.insertLineSegmentBefore: line segment not found in lineSegmentsMPIDs',
      );
    }

    resetLineSegmentsLists();
    clearBoundingBox();
  }

  LinkedHashMap<int, THLineSegment> getLineSegmentsMap(THFile thFile) {
    final LinkedHashMap<int, THLineSegment> lineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();
    final List<int> lineSegmentMPIDs = getLineSegmentMPIDs(thFile);

    for (final int lineSegmentMPID in lineSegmentMPIDs) {
      final THLineSegment lineSegment =
          thFile.elementByMPID(lineSegmentMPID) as THLineSegment;

      lineSegmentsMap[lineSegmentMPID] = lineSegment;
    }

    return lineSegmentsMap;
  }

  List<({int lineSegmentPosition, THLineSegment lineSegment})>
  getLineSegmentsPositionList(THFile thFile) {
    final List<({int lineSegmentPosition, THLineSegment lineSegment})>
    originalLineSegments = [];
    final List<int> lineSegmentMPIDs = getLineSegmentMPIDs(thFile);

    for (final int originalLineSegmentMPID in lineSegmentMPIDs) {
      final THLineSegment originalLineSegment = thFile.lineSegmentByMPID(
        originalLineSegmentMPID,
      );
      final int originalLineSegmentPosition = getChildPosition(
        originalLineSegment,
      );

      originalLineSegments.add((
        lineSegmentPosition: originalLineSegmentPosition,
        lineSegment: originalLineSegment,
      ));
    }

    return originalLineSegments;
  }
}
