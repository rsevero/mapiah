import 'dart:collection';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_has_platype.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_line.mapper.dart';

// Description: Line is a command for drawing a line symbol on the map. Each line symbol
// is oriented and its visualization may depend on its orientation (e.g. pitch edge ticks). The
// general rule is that the free space is on the left, rock on the right. Examples: the lower
// side of a pitch, higher side of a chimney and interior of a passage are on the left side of
// pitch, chimney or wall symbols, respectively.
@MappableClass()
class THLine extends THElement
    with THLineMappable, THHasOptions, THParent
    implements THHasPLAType {
  late String _lineType;

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

  /// Used by dart_mappable.
  THLine.notAddedToParent(
    super.mapiahID,
    super.parentMapiaID,
    super.sameLineComment,
    String lineType,
    List<int> childrenMapiahID,
    LinkedHashMap<String, THCommandOption> optionsMap,
  ) : super.notAddToParent() {
    this.lineType = lineType;
    this.childrenMapiahID.addAll(childrenMapiahID);
    addOptionsMap(optionsMap);
  }

  THLine(super.parentMapiahID, String lineType) : super() {
    this.lineType = lineType;
  }

  static bool hasLineType(String aLineType) {
    return _lineTypes.contains(aLineType);
  }

  @override
  bool isSameClass(Object object) {
    return object is THLine;
  }

  set lineType(String lineType) {
    if (!hasLineType(lineType)) {
      throw THCustomException("Unrecognized THLine type '$lineType'.");
    }

    _lineType = lineType;
  }

  String get lineType {
    return _lineType;
  }

  @override
  set plaType(String aLineType) {
    lineType = aLineType;
  }

  @override
  String get plaType {
    return lineType;
  }
}
