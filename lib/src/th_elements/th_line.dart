import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THLine extends THElement with THHasOptions {
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

  THLine(super.parent, String aLineType) : super.withParent() {
    lineType = aLineType;
  }

  static bool hasLineType(String aLineType) {
    return _lineTypes.contains(aLineType);
  }

  set lineType(String aLineType) {
    if (!hasLineType(aLineType)) {
      throw THCustomException("Unrecognized THLine type '$aLineType'.");
    }

    _lineType = aLineType;
  }

  String get lineType {
    return _lineType;
  }
}
