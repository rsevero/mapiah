part of 'th_element.dart';

// Description: Line is a command for drawing a line symbol on the map. Each line symbol
// is oriented and its visualization may depend on its orientation (e.g. pitch edge ticks). The
// general rule is that the free space is on the left, rock on the right. Examples: the lower
// side of a pitch, higher side of a chimney and interior of a passage are on the left side of
// pitch, chimney or wall symbols, respectively.
class THLine extends THElement
    with THHasOptionsMixin, THIsParentMixin, MPBoundingBox
    implements THHasPLATypeMixin {
  final THLineType lineType;

  static final _lineTypes = <String>{
    'abyss-entrance',
    'arrow',
    'border',
    'ceiling-meander',
    'ceiling-step',
    'chimney',
    'contour',
    'dripline',
    'fault',
    'fixed-ladder',
    'floor-meander',
    'floor-step',
    'flowstone',
    'gradient',
    'handrail',
    'joint',
    'label',
    'low-ceiling',
    'map-connection',
    'moonmilk',
    'overhang',
    'pit',
    'pit-chimney',
    'pitch',
    'rimstone-dam',
    'rimstone-pool',
    'rock-border',
    'rock-edge',
    'rope',
    'rope-ladder',
    'section',
    'slope',
    'steps',
    'survey',
    'u',
    'via-ferrata',
    'walk-way',
    'wall',
    'water-flow',
  };

  THLine.forCWJM({
    required super.mpID,
    required super.parentMPID,
    required super.sameLineComment,
    required this.lineType,
    required Set<int> childrenMPID,
    required LinkedHashMap<THCommandOptionType, THCommandOption> optionsMap,
    required super.originalLineInTH2File,
  }) : super.forCWJM() {
    this.childrenMPID.addAll(childrenMPID);
    addOptionsMap(optionsMap);
  }

  THLine.fromString({
    required super.parentMPID,
    required String lineTypeString,
    super.sameLineComment,
    super.originalLineInTH2File = '',
  })  : lineType = THLineType.fromFileString(lineTypeString),
        super.addToParent();

  THLine({
    required super.parentMPID,
    required this.lineType,
    super.sameLineComment,
    super.originalLineInTH2File = '',
  }) : super.addToParent();

  static bool hasLineType(String aLineType) {
    return _lineTypes.contains(aLineType);
  }

  @override
  THElementType get elementType => THElementType.line;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'lineType': lineType.name,
      'childrenMPID': childrenMPID.toList(),
      'optionsMap': THHasOptionsMixin.optionsMapToMap(optionsMap),
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
      childrenMPID: Set<int>.from(map['childrenMPID']),
      optionsMap: THHasOptionsMixin.optionsMapFromMap(map['optionsMap']),
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
    Set<int>? childrenMPID,
    LinkedHashMap<THCommandOptionType, THCommandOption>? optionsMap,
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
      childrenMPID: childrenMPID ?? this.childrenMPID,
      optionsMap: optionsMap ?? this.optionsMap,
    );
  }

  @override
  bool operator ==(covariant THLine other) {
    if (identical(this, other)) return true;

    final Function deepEq = const DeepCollectionEquality().equals;

    return other.mpID == mpID &&
        other.parentMPID == parentMPID &&
        other.sameLineComment == sameLineComment &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.lineType == lineType &&
        deepEq(other.childrenMPID, childrenMPID) &&
        deepEq(other.optionsMap, optionsMap);
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        lineType,
        childrenMPID,
        optionsMap,
      );

  @override
  bool isSameClass(Object object) {
    return object is THLine;
  }

  @override
  Rect calculateBoundingBox(TH2FileEditController th2FileEditController) {
    if (childrenMPID.isEmpty) {
      return Rect.zero;
    }

    final THFile thFile = th2FileEditController.thFile;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    bool isFirst = true;
    Offset startPoint = Offset.zero;

    for (final int childMPID in childrenMPID) {
      final THElement child = thFile.elementByMPID(childMPID);

      if (child is! THLineSegment) {
        continue;
      }

      if (isFirst) {
        startPoint = child.endPoint.coordinates;
        isFirst = false;
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

  int getPreviousLineSegmentMPID(int lineSegmentMPID, THFile thFile) {
    int? previousLineSegmentMPID;

    for (final int childMPID in childrenMPID) {
      final THElementType childElementType = thFile.getElementTypeByMPID(
        childMPID,
      );

      if ((childElementType != THElementType.bezierCurveLineSegment) &&
          (childElementType != THElementType.straightLineSegment)) {
        continue;
      }
      if (previousLineSegmentMPID == null) {
        previousLineSegmentMPID = childMPID;
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

  THLineSegment getPreviousLineSegment(
    THLineSegment lineSegment,
    THFile thFile,
  ) {
    final int previousLineSegmentMPID =
        getPreviousLineSegmentMPID(lineSegment.mpID, thFile);

    return thFile.lineByMPID(previousLineSegmentMPID) as THLineSegment;
  }

  @override
  String get plaType {
    return lineType.name;
  }
}
