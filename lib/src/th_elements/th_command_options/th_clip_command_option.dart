import 'dart:collection';

import 'package:mapiah/src/th_elements/th_command_options/th_multiple_choice_command_option.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THClipCommandOption extends THMultipleChoiceCommandOption {
  static final _unsupportedPointTypes = HashSet.from({
    'altitude',
    'date',
    'height',
    'label',
    'passage-height',
    'remark',
    'station-name',
    'station',
  });

  THClipCommandOption(THHasOptions aOptionParent, String aChoice)
      : super(aOptionParent, 'clip', aChoice) {
    if (_unsupportedPointTypes.contains((parentOption as THPoint).pointType)) {
      throw THCustomException(
          "Unsupported point type '${aOptionParent.type}' 'clip' option.");
    }
  }
}
