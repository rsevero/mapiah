import 'dart:collection';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_point_interface.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_has_platype.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';

part 'th_point.mapper.dart';

// Description: Point is a command for drawing a point map symbol.
// Syntax: point <x> <y> <type> [OPTIONS]
// Context: scrap
// Arguments:
// • <x> and <y> are the drawing coordinates of an object.
// • <type> determines the type of an object. The following types are supported:
// special objects: dimensions7 , section8 , station9 ;
// labels: altitude10 , date11 , height12 , label, passage-height13 , remark, station-
// name14 ;
// symbolic passage fills: 15 bedrock, blocks, clay, debris, guano, ice, mudcrack, mud,
// pebbles, raft, sand, snow, water;
// speleothems: anastomosis, aragonite, cave-pearl, clay-tree, crystal, curtains,
// curtain, disc-pillar, disc-stalactite, disc-stalagmite, disc-pillars, disc-
// stalactites, disc-stalagmites, disk, flowstone, flute, gypsum-flower, gyp-
// sum, helictites, helictite, karren, moonmilk, pendant, pillar-with-curtains,
// pillars-with-curtains, pillar, popcorn, raft-cone, rimstone-dam, rimstone-
// pool, scallop, soda-straw, stalactite-stalagmite, stalactites-stalagmites,
// stalactite, stalactites, stalagmite, stalagmites, volcano, wall-calcite;
// equipment: anchor, bridge, camp, fixed-ladder, gate, handrail, masonry, name-
// plate, no-equipment, no-wheelchair, rope-ladder, rope, steps, traverse, via-
// ferrata, walkway, wheelchair;
// passage ends: breakdown-choke, clay-choke, continuation, entrance, flowstone-
// choke, low-end, narrow-end;
// others: air-draught16 , altar, archeo-excavation, archeo-material, audio, bat,
// bones, danger, dig, electric-light, ex-voto, extra17 , gradient, human-bones,
// ice-pillar, ice-stalactite, ice-stalagmite, map-connection18 , paleo-material,
// photo, root, seed-germination, sink, spring19 , tree-trunk, u20 , vegetable-debris,
// water-drip, water-flow.
@MappableClass()
class THPoint extends THElement
    with THPointMappable, THHasOptions
    implements THHasPLAType, THPointInterface {
  late final THPositionPart _position;
  late final String _pointType;

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

  /// Used by dart_mappable to decode a THPoint object from a map and create a
  /// new instance with copyWith.
  THPoint.notAddedToParent(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
    THPositionPart position,
    String pointType,
    LinkedHashMap<String, THCommandOption> optionsMap,
  ) : super.notAddToParent() {
    _position = position;
    _pointType = pointType;
    addOptionsMap(optionsMap);
  }

  THPoint(
    super.parentMapiahID,
    THPositionPart coordinates,
    String pointType,
  ) : super() {
    _position = coordinates;
    _pointType = pointType;
  }

  THPoint.fromString(
    super.parentMapiahID,
    List<dynamic> pointDataList,
    String pointType,
  ) : super() {
    _position = THPositionPart.fromStringList(pointDataList);
    plaType = pointType;
  }

  static bool hasPointType(String pointType) {
    return _pointTypes.contains(pointType);
  }

  @override
  bool isSameClass(Object object) {
    return object is THPoint;
  }

  set pointType(String pointType) {
    if (!hasPointType(pointType)) {
      throw THCustomException("Unrecognized THPoint type '$pointType'.");
    }

    _pointType = pointType;
  }

  String get pointType {
    return _pointType;
  }

  @override
  set plaType(String pointType) {
    _pointType = pointType;
  }

  @override
  String get plaType {
    return pointType;
  }

  THPositionPart get position {
    return _position;
  }

  @override
  double get x {
    return _position.coordinates.dx;
  }

  @override
  double get y {
    return _position.coordinates.dy;
  }

  int get decimalPositions {
    return _position.decimalPositions;
  }

  set decimalPositions(int decimalPositions) {
    _position.decimalPositions = decimalPositions;
  }
}
