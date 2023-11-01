import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THArea extends THElement with THHasOptions {
  late String _areaType;

  static final _areaTypes = <String>{
    'bedrock',
    'blocks',
    'clay',
    'debris',
    'flowstone',
    'ice',
    'moonmilk',
    'mudcrack',
    'pebbles',
    'pillar',
    'pillar-with-curtains',
    'pillars',
    'pillars-with-curtains',
    'sand',
    'snow',
    'stalactite',
    'stalactite-stalagmite',
    'stalagmite',
    'sump',
    'u',
    'water',
  };

  THArea(super.parent, String aAreaType) : super.withParent() {
    areaType = aAreaType;
  }

  static bool hasAreaType(String aAreaType) {
    return _areaTypes.contains(aAreaType);
  }

  set areaType(String aAreaType) {
    if (!hasAreaType(aAreaType)) {
      throw THCustomException("Unrecognized THArea type '$aAreaType'.");
    }

    _areaType = aAreaType;
  }

  String get areaType {
    return _areaType;
  }
}
