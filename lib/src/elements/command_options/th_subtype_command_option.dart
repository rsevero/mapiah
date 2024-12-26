import 'dart:collection';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/th_area.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_subtype_command_option.mapper.dart';

// subtype <keyword> . determines the object’s subtype. The following subtypes for
// given types are supported:
// station: 21 temporary (default), painted, natural, fixed;
// air-draught: winter, summer, undefined (default);
// water-flow: permanent (default), intermittent, paleo.
// The subtype may be specified also directly in <type> specification using ‘:’ as a
// separator.22
// Any subtype specification can be used with user defined type (u). In this case you need
// also to define corresponding metapost symbol (see the chapter New map symbols).
@MappableClass()
class THSubtypeCommandOption extends THCommandOption
    with THSubtypeCommandOptionMappable {
  late String _subtype;

  static final _allowedSubtypes = {
    'point': {
      'air-draught': {
        'default': 'undefined',
        'subtypes': <String>{
          'winter',
          'summer',
          'undefined',
        },
      },
      'station': {
        'default': 'temporary',
        'subtypes': <String>{
          'temporary',
          'painted',
          'natural',
          'fixed',
        },
      },
      'water-flow': {
        'default': 'permanent',
        'subtypes': <String>{
          'permanent',
          'intermittent',
          'paleo',
        },
      },
    },
    'line': {
      'border': {
        'default': 'visible',
        'subtypes': <String>{
          'invisible',
          'presumed',
          'temporary',
          'visible',
        },
      },
      'survey': {
        'default': 'cave',
        'subtypes': <String>{
          'cave',
          'surface',
        },
      },
      'wall': {
        'default': 'bedrock',
        'subtypes': <String>{
          'bedrock',
          'blocks',
          'clay',
          'debris',
          'flowstone',
          'ice',
          'invisible',
          'moonmilk',
          'overlying',
          'pebbles',
          'pit',
          'presumed',
          'sand',
          'underlying',
          'unsurveyed',
        },
      },
      'water-flow': {
        'default': 'permanent',
        'subtypes': <String>{
          'permanent',
          'conjectural',
          'intermittent',
        },
      },
    },
  };

  THSubtypeCommandOption(super.optionParent, String subtype) {
    this.subtype = subtype;
  }

  set subtype(String aSubtype) {
    if (optionParent is THPoint) {
      final pointType = (optionParent as THPoint).plaType;
      final allowedSubtypes = _allowedSubtypes['point']!;
      if ((pointType != 'u') &&
          (!allowedSubtypes.containsKey(pointType) ||
              !(allowedSubtypes[pointType]!['subtypes']
                      as LinkedHashSet<String>)
                  .contains(aSubtype))) {
        throw THCustomException(
            "Unsupported subtype '$aSubtype' in option type '$optionType' for a point of type '$pointType' object.");
      }
    } else if (optionParent is THLine) {
      final lineType = (optionParent as THLine).plaType;
      final allowedSubtypes = _allowedSubtypes['line']!;
      if ((lineType != 'u') &&
          (!allowedSubtypes.containsKey(lineType) ||
              !(allowedSubtypes[lineType]!['subtypes'] as LinkedHashSet<String>)
                  .contains(aSubtype))) {
        throw THCustomException(
            "Unsupported subtype '$aSubtype' in option type '$optionType' for a line of type '$lineType' object.");
      }
    } else if (optionParent is THArea) {
      final areaType = (optionParent as THArea).plaType;
      if (areaType != 'u') {
        throw THCustomException(
            "Unsupported subtype '$aSubtype' in option type '$optionType' for an area of type '$areaType' object.");
      }
    } else {
      throw THCustomException(
          "Unsupported element of type '${optionParent.elementType}' in option type '$optionType'.");
    }

    _subtype = aSubtype;
  }

  String get subtype {
    return _subtype;
  }

  @override
  String get optionType => 'subtype';

  @override
  String specToFile() {
    return subtype;
  }
}
