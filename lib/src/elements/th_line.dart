import 'dart:collection';

import 'package:dogs_core/dogs_core.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_has_platype.dart';

// Description: Line is a command for drawing a line symbol on the map. Each line symbol
// is oriented and its visualization may depend on its orientation (e.g. pitch edge ticks). The
// general rule is that the free space is on the left, rock on the right. Examples: the lower
// side of a pitch, higher side of a chimney and interior of a passage are on the left side of
// pitch, chimney or wall symbols, respectively.
@serializable
class THLine extends THElement
    with Dataclass<THLine>, THHasOptions, THParent
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

  static bool hasLineType(String aLineType) {
    return _lineTypes.contains(aLineType);
  }

  @override
  Map<String, dynamic> toMap() {
    return dogs.toNative<THLine>(this);
  }

  factory THLine.fromMap(Map<String, dynamic> map) {
    return dogs.fromNative<THLine>(map);
  }

  @override
  String toJson() {
    return dogs.toJson<THLine>(this);
  }

  factory THLine.fromJson(String jsonString) {
    return dogs.fromJson<THLine>(jsonString);
  }

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
      lineType: lineType ?? _lineType,
      childrenMapiahID:
          childrenMapiahID ?? List<int>.from(this.childrenMapiahID),
      optionsMap: optionsMap ??
          LinkedHashMap<String, THCommandOption>.from(this.optionsMap),
    );
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
