import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_has_platype.dart';

// Description: Line is a command for drawing a line symbol on the map. Each line symbol
// is oriented and its visualization may depend on its orientation (e.g. pitch edge ticks). The
// general rule is that the free space is on the left, rock on the right. Examples: the lower
// side of a pitch, higher side of a chimney and interior of a passage are on the left side of
// pitch, chimney or wall symbols, respectively.
class THLine extends THElement
    with THHasOptions, THParent
    implements THHasPLAType {
  late final String _lineType;

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

  THLine({
    required super.mapiahID,
    required super.parentMapiahID,
    required super.sameLineComment,
    required String lineType,
    required List<int> childrenMapiahID,
    required LinkedHashMap<String, THCommandOption> optionsMap,
  })  : _lineType = lineType,
        super() {
    this.childrenMapiahID.addAll(childrenMapiahID);
    addOptionsMap(optionsMap);
  }

  THLine.addToParent({
    required super.parentMapiahID,
    required String lineType,
    super.sameLineComment,
  })  : _lineType = lineType,
        super.addToParent();

  @override
  THLine copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    String? lineType,
    List<int>? childrenMapiahID,
    LinkedHashMap<String, THCommandOption>? optionsMap,
  }) {
    return THLine(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: sameLineComment ?? this.sameLineComment,
      lineType: lineType ?? this.lineType,
      childrenMapiahID:
          childrenMapiahID ?? List<int>.from(this.childrenMapiahID),
      optionsMap: optionsMap ??
          LinkedHashMap<String, THCommandOption>.from(this.optionsMap),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'lineType': lineType,
      'childrenMapiahID': childrenMapiahID.toList(),
      'optionsMap':
          optionsMap.map((key, value) => MapEntry(key, value.toMap())),
    });
    return map;
  }

  @override
  bool operator ==(covariant THLine other) {
    if (identical(this, other)) return true;

    return super == other &&
        _lineType == other._lineType &&
        const ListEquality<int>()
            .equals(childrenMapiahID, other.childrenMapiahID) &&
        const MapEquality<String, THCommandOption>()
            .equals(optionsMap, other.optionsMap);
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        _lineType,
        Object.hashAll(childrenMapiahID),
        Object.hashAll(optionsMap.entries),
      );

  static bool hasLineType(String aLineType) {
    return _lineTypes.contains(aLineType);
  }

  @override
  bool isSameClass(Object object) {
    return object is THLine;
  }

  String get lineType {
    return _lineType;
  }

  @override
  String get plaType {
    return lineType;
  }
}
