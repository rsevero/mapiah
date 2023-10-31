import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';
import 'package:mapiah/src/th_parts/th_point_part.dart';

class THPoint extends THElement with THHasOptions {
  late THPointPart point;
  late String _pointType;

  static final _pointTypes = <String>{
    'air-draught',
    'altar',
    'altitude',
    'anastomosis',
    'anchor',
    'aragonite',
    'archeo-excavation',
    'archeo-material',
    'audio',
    'bat',
    'bedrock',
    'blocks',
    'bones',
    'breakdown-choke',
    'bridge',
    'camp',
    'cave-pearl',
    'clay',
    'clay-choke',
    'clay-tree',
    'continuation',
    'crystal',
    'curtain',
    'curtains',
    'danger',
    'date',
    'debris',
    'dig',
    'dimensions',
    'disc-pillar',
    'disc-pillars',
    'disc-stalactite',
    'disc-stalactites',
    'disc-stalagmite',
    'disc-stalagmites',
    'disk',
    'electric-light',
    'entrance',
    'ex-voto',
    'extra',
    'fixed-ladder',
    'flowstone',
    'flowstone-choke',
    'flute',
    'gate',
    'gradient',
    'guano',
    'gypsum',
    'gypsum-flower',
    'handrail',
    'height',
    'helictite',
    'helictites',
    'human-bones',
    'ice',
    'ice-pillar',
    'ice-stalactite',
    'ice-stalagmite',
    'karren',
    'label',
    'low-end',
    'map-connection',
    'masonry',
    'moonmilk',
    'mud',
    'mudcrack',
    'name-plate',
    'narrow-end',
    'no-equipment',
    'no-wheelchair',
    'paleo-material',
    'passage-height',
    'pebbles',
    'pendant',
    'photo',
    'pillar',
    'pillar-with-curtains',
    'pillars-with-curtains',
    'popcorn',
    'raft',
    'raft-cone',
    'remark',
    'rimstone-dam',
    'rimstone-pool',
    'root',
    'rope',
    'rope-ladder',
    'sand',
    'scallop',
    'section',
    'seed-germination',
    'sink',
    'snow',
    'soda-straw',
    'spring',
    'stalactite',
    'stalactite-stalagmite',
    'stalactites',
    'stalactites-stalagmites',
    'stalagmite',
    'stalagmites',
    'station',
    'station-name',
    'steps',
    'traverse',
    'tree-trunk',
    'u',
    'vegetable-debris',
    'via-ferrata',
    'volcano',
    'walkway',
    'wall-calcite',
    'water',
    'water-drip',
    'water-flow',
    'wheelchair',
  };

  THPoint(super.parent, this.point, String aPointType) : super.withParent() {
    pointType = aPointType;
  }

  THPoint.fromString(super.parent, List<dynamic> aList, String aPointType)
      : super.withParent() {
    point = THPointPart.fromStringList(aList);
    pointType = aPointType;
  }

  static bool hasType(String aPointType) {
    return THPoint._pointTypes.contains(aPointType);
  }

  set pointType(String aPointType) {
    if (!THPoint.hasType(aPointType)) {
      throw THCustomException("Unrecognized THPoint type '$aPointType'");
    }

    _pointType = aPointType;
  }

  String get pointType {
    return _pointType;
  }
}
