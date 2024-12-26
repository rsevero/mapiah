import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_has_platype.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_area.mapper.dart';

@MappableClass()
class THArea extends THElement
    with THAreaMappable, THHasOptions, THParent
    implements THHasPLAType {
  late final String _areaType;

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

  THArea(super.parent, String areaType)
      : _areaType = areaType,
        super.withParent() {
    if (!hasAreaType(areaType)) {
      throw THCustomException("Unrecognized THArea type '$areaType'.");
    }
  }

  static bool hasAreaType(String aAreaType) {
    return _areaTypes.contains(aAreaType);
  }

  @override
  set plaType(String aAreaType) {
    if (!hasAreaType(aAreaType)) {
      throw THCustomException("Unrecognized THArea type '$aAreaType'.");
    }

    _areaType = aAreaType;
  }

  @override
  String get plaType {
    return _areaType;
  }
}
