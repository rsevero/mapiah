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
    if (parentOption is THPoint) {
      final parentAsPoint = parentOption as THPoint;
      if (_unsupportedPointTypes.contains(parentAsPoint.pointType)) {
        throw THCustomException(
            "Unsupported point type '${parentAsPoint.pointType}' 'clip' option.");
      }
    } else {
      throw THCustomException(
          "Unsupported parent command type '${parentOption.commandType}' for 'clip' option.");
    }
  }
}
