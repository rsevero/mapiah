// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'th_element.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
abstract class THLineSegment extends THElement
    with THHasOptionsMixin
    implements THPointInterface {
  late final THPositionPart endPoint;
  Rect? _boundingBox;

  THLineSegment.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required this.endPoint,
    required SplayTreeMap<THCommandOptionType, THCommandOption> optionsMap,
    required SplayTreeMap<String, THAttrCommandOption> attrOptionsMap,
    required super.originalLineInTH2File,
  }) : super.forCWJM() {
    addOptionsMap(optionsMap);
    addUpdateAttrOptionsMap(attrOptionsMap);
  }

  THLineSegment.withEndPoint({
    required super.parentMPID,
    super.sameLineComment,
    required this.endPoint,
    SplayTreeMap<THCommandOptionType, THCommandOption>? optionsMap,
    SplayTreeMap<String, THAttrCommandOption>? attrOptionsMap,
    super.originalLineInTH2File = '',
  }) : super.getMPID() {
    if (optionsMap != null) {
      addOptionsMap(optionsMap);
    }
    if (attrOptionsMap != null) {
      addUpdateAttrOptionsMap(attrOptionsMap);
    }
  }

  THLineSegment.withoutEndPoint({
    required super.parentMPID,
    super.sameLineComment,
    SplayTreeMap<THCommandOptionType, THCommandOption>? optionsMap,
    SplayTreeMap<String, THAttrCommandOption>? attrOptionsMap,
    super.originalLineInTH2File = '',
  }) : super.getMPID() {
    if (optionsMap != null) {
      addOptionsMap(optionsMap);
    }
    if (attrOptionsMap != null) {
      addUpdateAttrOptionsMap(attrOptionsMap);
    }
  }

  @override
  THElementType get elementType => THElementType.lineSegment;

  @override
  double get x {
    return endPoint.coordinates.dx;
  }

  @override
  double get y {
    return endPoint.coordinates.dy;
  }

  int get endPointDecimalPositions {
    return endPoint.decimalPositions;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'endPoint': endPoint.toMap(),
      'optionsMap': THHasOptionsMixin.optionsMapToMap(optionsMap),
      'attrOptionsMap': THHasOptionsMixin.attrOptionsMapToMap(attrOptionsMap),
    });

    return map;
  }

  static THLineSegment fromMap(Map<String, dynamic> map) {
    final THElementType elementType = THElementType.values.byName(
      map['elementType'],
    );

    switch (elementType) {
      case THElementType.straightLineSegment:
        return THStraightLineSegment.fromMap(map);
      case THElementType.bezierCurveLineSegment:
        return THBezierCurveLineSegment.fromMap(map);
      default:
        throw Exception('Invalid THElementType: $elementType');
    }
  }

  @override
  THLineSegment copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    THPositionPart? endPoint,
    SplayTreeMap<THCommandOptionType, THCommandOption>? optionsMap,
    SplayTreeMap<String, THAttrCommandOption>? attrOptionsMap,
  });

  @override
  bool equalsBase(Object other) {
    if (!super.equalsBase(other)) return false;

    final Function deepEq = DeepCollectionEquality().equals;

    return other is THLineSegment &&
        endPoint == other.endPoint &&
        deepEq(optionsMap, other.optionsMap) &&
        deepEq(attrOptionsMap, other.attrOptionsMap);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return equalsBase(other);
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        endPoint,
        DeepCollectionEquality().hash(optionsMap),
        DeepCollectionEquality().hash(attrOptionsMap),
      );

  void clearBoundingBox() {
    _boundingBox = null;
  }

  Rect getBoundingBox(Offset startPoint) {
    _boundingBox ??= _calculateBoundingBox(startPoint);

    return _boundingBox!;
  }

  Rect _calculateBoundingBox(Offset startPoint);

  @override
  bool addUpdateOption(THCommandOption option) {
    final bool changed = super.addUpdateOption(option);

    if (option.type == THCommandOptionType.subtype) {
      if (th2File != null) {
        final THLine parentLine = th2File!.lineByMPID(parentMPID);

        parentLine.updateSubtypeLineSegmentMPIDs();
      }
    }

    _invalidateCache(option.type);

    return changed;
  }

  @override
  bool removeOption(
    THCommandOptionType type, {
    bool callUpdateSubtypeLineSegmentMPIDs = true,
  }) {
    final bool removed = super.removeOption(type);

    if (type == THCommandOptionType.subtype) {
      if ((th2File != null) && callUpdateSubtypeLineSegmentMPIDs) {
        final THLine parentLine = th2File!.lineByMPID(parentMPID);

        parentLine.updateSubtypeLineSegmentMPIDs();
      }
    }

    _invalidateCache(type);

    return removed;
  }

  @override
  void setTH2File(TH2File th2File) {
    if (this.th2File == th2File) {
      return;
    }

    super.setTH2File(th2File);

    setTH2FileToOptions(th2File);
  }

  void _invalidateCache(THCommandOptionType type) {
    if ((type == THCommandOptionType.lSize) ||
        (type == THCommandOptionType.orientation)) {
      if (th2File != null) {
        (parent() as THLine).clearLineSegmentsWithSizeOrientationCache();
      }
    } else if (type == THCommandOptionType.mark) {
      if (th2File != null) {
        (parent() as THLine).clearLineSegmentsWithMarkCache();
      }
    }
  }
}
