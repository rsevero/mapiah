import 'dart:collection';

import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

// subtype <keyword> . determines the object’s subtype. The following subtypes for
// given types are supported:
// station: 21 temporary (default), painted, natural, fixed;
// air-draught: winter, summer, undefined (default);
// water-flow: permanent (default), intermittent, paleo.
// The subtype may be specified also directly in <type> specification using ‘:’ as a
// separator.22
// Any subtype specification can be used with user defined type (u). In this case you need
// also to define corresponding metapost symbol (see the chapter New map symbols).
class THSubtypeCommandOption extends THCommandOption {
  late String _subtype;

  static final _allowedSubtypes = {
    'air-draught': {
      'default': 'undefined',
      'subtypes': <String>{
        'winter,',
        'summer,',
        'undefined',
      }
    },
    'station': {
      'default': 'temporary',
      'subtypes': <String>{
        'temporary',
        'painted',
        'natural',
        'fixed',
      }
    },
    'water-flow': {
      'default': 'permanent',
      'subtypes': <String>{
        'permanent',
        'intermittent,',
        'paleo',
      }
    },
  };

  THSubtypeCommandOption(THPoint super.parentOption, String aSubtype) {
    subtype = aSubtype;
  }

  set subtype(String aSubtype) {
    final pointType = (parentOption as THPoint).pointType;
    if ((pointType != 'u') &&
        (!_allowedSubtypes.containsKey(pointType) ||
            !(_allowedSubtypes[pointType]!['subtypes'] as LinkedHashSet<String>)
                .contains(aSubtype))) {
      throw THCustomException(
          "Unsupported subtype '$aSubtype' in option type '$optionType' for a point of type '$pointType' object");
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
