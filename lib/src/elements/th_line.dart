// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'th_element.dart';

// Description: Line is a command for drawing a line symbol on the map. Each line symbol
// is oriented and its visualization may depend on its orientation (e.g. pitch edge ticks). The
// general rule is that the free space is on the left, rock on the right. Examples: the lower
// side of a pitch, higher side of a chimney and interior of a passage are on the left side of
// pitch, chimney or wall symbols, respectively.
class THLine extends THElement
    with
        THHasOptionsMixin,
        THIsParentMixin,
        MPBoundingBoxMixin,
        THHasPLATypeMixin {
  final THLineType lineType;

  final LinkedHashMap<int, int> _subtypeLineSegmentMPIDsByLineSegmentIndex =
      LinkedHashMap();

  List<int>? _lineSegmentMPIDs;
  List<THLineSegment>? _lineSegments;
  Map<int, MPLineSegmentSizeOrientationInfo>? _lineSegmentsWithSizeOrientation;
  Map<int, MPLineSegmentMarkInfo>? _lineSegmentsWithMark;

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

  THLine.fromString({
    required super.parentMPID,
    required String lineTypeString,
    super.sameLineComment,
    SplayTreeMap<THCommandOptionType, THCommandOption>? optionsMap,
    SplayTreeMap<String, THAttrCommandOption>? attrOptionsMap,
    super.originalLineInTH2File = '',
  }) : lineType = THLineType.fromString(lineTypeString),

       super.getMPID() {
    _unknownPLAType = THLineType.unknownPLATypeFromString(lineTypeString);
    if (optionsMap != null) {
      addOptionsMap(optionsMap);
    }
    if (attrOptionsMap != null) {
      addUpdateAttrOptionsMap(attrOptionsMap);
    }
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

    final TH2File th2File = th2FileEditController.th2File;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    bool isFirst = true;
    Offset startPoint = Offset.zero;

    for (final int childMPID in childrenMPIDs) {
      final THElement child = th2File.elementByMPID(childMPID);

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

  void clearLineAndLineSegmentsBoundingBoxes(TH2File th2File) {
    final List<THLineSegment> lineSegments = getLineSegments(th2File);

    for (final THLineSegment lineSegment in lineSegments) {
      lineSegment.clearBoundingBox();
    }

    clearBoundingBox();
  }

  int? getNextLineSegmentMPID(int lineSegmentMPID, TH2File th2File) {
    final int indexLineSegmentMPID = getLineSegmentIndexByMPID(
      lineSegmentMPID,
      th2File,
    );

    if (indexLineSegmentMPID == -1) {
      throw Exception(
        'THLine.getNextLineSegmentMPID: lineSegmentMPID not found',
      );
    }

    final List<int> lineSegmentMPIDs = getLineSegmentMPIDs(th2File);

    if (indexLineSegmentMPID == lineSegmentMPIDs.length - 1) {
      return null;
    }

    return lineSegmentMPIDs[indexLineSegmentMPID + 1];
  }

  List<int> getLineSegmentMPIDs(TH2File th2File) {
    _lineSegmentMPIDs ??= _generateLineSegmentMPIDs(th2File);

    return _lineSegmentMPIDs!;
  }

  List<int> _generateLineSegmentMPIDs(TH2File th2File) {
    final List<int> lineSegmentMPIDs = [];

    for (final int childMPID in childrenMPIDs) {
      final THElementType childType = th2File.getElementTypeByMPID(childMPID);

      if ((childType == THElementType.bezierCurveLineSegment) ||
          (childType == THElementType.straightLineSegment)) {
        lineSegmentMPIDs.add(childMPID);
      }
    }

    return lineSegmentMPIDs;
  }

  List<THLineSegment> getLineSegments(TH2File th2File) {
    _lineSegments ??= _generateLineSegmentsList(th2File);

    return _lineSegments!;
  }

  List<THLineSegment> _generateLineSegmentsList(TH2File th2File) {
    final List<THLineSegment> lineSegments = [];
    final List<int> lineSegmentMPIDs = getLineSegmentMPIDs(th2File);

    for (final int lineSegmentMPID in lineSegmentMPIDs) {
      final THLineSegment lineSegment = th2File.lineSegmentByMPID(
        lineSegmentMPID,
      );

      lineSegments.add(lineSegment);
    }

    return lineSegments;
  }

  int? getPreviousLineSegmentMPID(int lineSegmentMPID, TH2File th2File) {
    int? previousLineSegmentMPID;

    for (final int childMPID in childrenMPIDs) {
      final THElementType childElementType = th2File.getElementTypeByMPID(
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
    TH2File th2File,
  ) {
    final int? previousLineSegmentMPID = getPreviousLineSegmentMPID(
      lineSegment.mpID,
      th2File,
    );

    return previousLineSegmentMPID == null
        ? null
        : th2File.elementByMPID(previousLineSegmentMPID) as THLineSegment;
  }

  bool isFirstLineSegment(THLineSegment lineSegment, TH2File th2File) {
    final int? previousLineSegmentMPID = getPreviousLineSegmentMPID(
      lineSegment.mpID,
      th2File,
    );

    return previousLineSegmentMPID == null;
  }

  bool isLastLineSegment(THLineSegment lineSegment, TH2File th2File) {
    final int? nextLineSegmentMPID = getNextLineSegmentMPID(
      lineSegment.mpID,
      th2File,
    );

    return nextLineSegmentMPID == null;
  }

  THLineSegment? getNextLineSegment(
    THLineSegment lineSegment,
    TH2File th2File,
  ) {
    final int? nextLineSegmentMPID = getNextLineSegmentMPID(
      lineSegment.mpID,
      th2File,
    );

    return nextLineSegmentMPID == null
        ? null
        : th2File.elementByMPID(nextLineSegmentMPID) as THLineSegment;
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

  int getLineSegmentIndexByMPID(int lineSegmentMPID, TH2File th2File) {
    return getLineSegmentMPIDs(th2File).indexOf(lineSegmentMPID);
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
  void removeElementFromParent(THElement element) {
    super.removeElementFromParent(element);

    if (element is THLineSegment) {
      resetLineSegmentsLists();
    }
  }

  void insertLineSegmentBefore(
    THLineSegment lineSegment,
    int beforeLineSegmentMPID,
    TH2File th2File,
  ) {
    final int childrenMPIDIndex = getLineSegmentIndexByMPID(
      beforeLineSegmentMPID,
      th2File,
    );

    if (childrenMPIDIndex == -1) {
      throw Exception(
        'THLine.insertLineSegmentBefore: line segment not found in childrenMPID',
      );
    }

    childrenMPIDs.insert(childrenMPIDIndex, lineSegment.mpID);

    final int lineSegmentsMPIDsIndex = getLineSegmentIndexByMPID(
      beforeLineSegmentMPID,
      th2File,
    );

    if (lineSegmentsMPIDsIndex == -1) {
      throw Exception(
        'THLine.insertLineSegmentBefore: line segment not found in lineSegmentsMPIDs',
      );
    }

    resetLineSegmentsLists();
  }

  LinkedHashMap<int, THLineSegment> getLineSegmentsMap(TH2File th2File) {
    final LinkedHashMap<int, THLineSegment> lineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();
    final List<int> lineSegmentMPIDs = getLineSegmentMPIDs(th2File);

    for (final int lineSegmentMPID in lineSegmentMPIDs) {
      final THLineSegment lineSegment =
          th2File.elementByMPID(lineSegmentMPID) as THLineSegment;

      lineSegmentsMap[lineSegmentMPID] = lineSegment;
    }

    return lineSegmentsMap;
  }

  List<({int lineSegmentPosition, THLineSegment lineSegment})>
  getLineSegmentsChildPositionList(TH2File th2File) {
    final List<({int lineSegmentPosition, THLineSegment lineSegment})>
    originalLineSegments = [];
    final List<int> lineSegmentMPIDs = getLineSegmentMPIDs(th2File);

    for (final int originalLineSegmentMPID in lineSegmentMPIDs) {
      final THLineSegment originalLineSegment = th2File.lineSegmentByMPID(
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

  Map<int, int> getLineSegmentPositionsByLineSegmentMPID(TH2File th2File) {
    final Map<int, int> lineSegmentPositionsByLineSegmentMPID = {};
    final List<int> lineSegmentMPIDs = getLineSegmentMPIDs(th2File);

    int position = 0;

    for (final int lineSegmentMPID in lineSegmentMPIDs) {
      lineSegmentPositionsByLineSegmentMPID[lineSegmentMPID] = position;
      position++;
    }

    return lineSegmentPositionsByLineSegmentMPID;
  }

  @override
  void setTHFile(TH2File th2File) {
    if (this.th2File == th2File) {
      return;
    }

    super.setTHFile(th2File);

    setTHFileToOptions(th2File);
    setTHFileToChildren(th2File);

    updateSubtypeLineSegmentMPIDs();
  }

  LinkedHashMap<int, int> get subtypeLineSegmentMPIDsByLineSegmentIndex =>
      _subtypeLineSegmentMPIDsByLineSegmentIndex;

  void updateSubtypeLineSegmentMPIDs() {
    if (th2File == null) {
      throw THCustomException(
        "At THLine.updateSubtypeLineSegmentMPIDs: THFile is null.",
      );
    }

    int lineSegmentIndex = 0;

    _subtypeLineSegmentMPIDsByLineSegmentIndex.clear();

    for (final THLineSegment lineSegment in getLineSegments(th2File!)) {
      if (lineSegment.hasOption(THCommandOptionType.subtype)) {
        if (lineSegmentIndex == 0) {
          /// Moving subtype option to line level, as first line segment subtype
          /// is in fact the line subtype.
          final THCommandOption subtypeOption = lineSegment.getOption(
            THCommandOptionType.subtype,
          )!;

          addUpdateOption(subtypeOption);
          lineSegment.removeOption(
            THCommandOptionType.subtype,
            callUpdateSubtypeLineSegmentMPIDs: false,
          );
        } else {
          _subtypeLineSegmentMPIDsByLineSegmentIndex[lineSegmentIndex] =
              lineSegment.mpID;
        }
      }

      lineSegmentIndex++;
    }
  }

  void clearLineSegmentsWithSizeOrientationCache() {
    _lineSegmentsWithSizeOrientation = null;
  }

  Map<int, MPLineSegmentSizeOrientationInfo>
  get lineSegmentsWithLSizeOrientation {
    _lineSegmentsWithSizeOrientation ??=
        _generateLineSegmentsWithSizeOrientation();

    return _lineSegmentsWithSizeOrientation!;
  }

  Map<int, MPLineSegmentSizeOrientationInfo>
  _generateLineSegmentsWithSizeOrientation() {
    if (th2File == null) {
      throw THCustomException(
        "At THLine._generateLineSegmentsWithSizeOrientation: THFile is null.",
      );
    }

    final Map<int, MPLineSegmentSizeOrientationInfo>
    lineSegmentWithSizeOrientation = {};
    final List<THLineSegment> lineSegments = getLineSegments(th2File!);

    for (final THLineSegment lineSegment in lineSegments) {
      if (lineSegment.hasOption(THCommandOptionType.lSize) ||
          lineSegment.hasOption(THCommandOptionType.orientation)) {
        lineSegmentWithSizeOrientation[lineSegment
            .mpID] = MPLineSegmentSizeOrientationInfo(
          mpID: lineSegment.mpID,
          canvasPosition: lineSegment.endPoint.coordinates,
          lSize: lineSegment.hasOption(THCommandOptionType.lSize)
              ? (lineSegment.getOption(THCommandOptionType.lSize)!
                        as THLSizeCommandOption)
                    .number
                    .value
              : null,
          orientation: lineSegment.hasOption(THCommandOptionType.orientation)
              ? (lineSegment.getOption(THCommandOptionType.orientation)!
                        as THOrientationCommandOption)
                    .azimuth
                    .value
              : null,
          th2File: th2File!,
        );
      }
    }

    return lineSegmentWithSizeOrientation;
  }

  void clearLineSegmentsWithMarkCache() {
    _lineSegmentsWithMark = null;
  }

  Map<int, MPLineSegmentMarkInfo> get lineSegmentsWithMark {
    _lineSegmentsWithMark ??= _generateLineSegmentsWithMark();

    return _lineSegmentsWithMark!;
  }

  Map<int, MPLineSegmentMarkInfo> _generateLineSegmentsWithMark() {
    if (th2File == null) {
      throw THCustomException(
        "At THLine._generateLineSegmentsWithMark: THFile is null.",
      );
    }

    final Map<int, MPLineSegmentMarkInfo> lineSegmentsWithMark = {};
    final List<THLineSegment> lineSegments = getLineSegments(th2File!);

    for (final THLineSegment lineSegment in lineSegments) {
      if (lineSegment.hasOption(THCommandOptionType.mark)) {
        lineSegmentsWithMark[lineSegment.mpID] = MPLineSegmentMarkInfo(
          mpID: lineSegment.mpID,
          canvasPosition: lineSegment.endPoint.coordinates,
          mark:
              (lineSegment.getOption(THCommandOptionType.mark)!
                      as THMarkCommandOption)
                  .mark,
        );
      }
    }

    return lineSegmentsWithMark;
  }

  @override
  String get typeSubtypeID {
    return MPCommandOptionAux.getPLATypeAndSubtypeID(
      plaType: lineType.name,
      plaSubtype: MPCommandOptionAux.getSubtype(this) ?? '',
    );
  }
}
