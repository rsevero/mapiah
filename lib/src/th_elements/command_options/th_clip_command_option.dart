import 'dart:collection';

import 'package:mapiah/src/th_elements/th_area.dart';
import 'package:mapiah/src/th_elements/command_options/th_multiple_choice_command_option.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_elements/th_line.dart';
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
    /// The -clip option is supported only for some point types.
    if (optionParent is THPoint) {
      final parentAsPoint = optionParent as THPoint;
      if (_unsupportedPointTypes.contains(parentAsPoint.plaType)) {
        throw THCustomException(
            "Unsupported point type '${parentAsPoint.plaType}' 'clip' option.");
      }

      /// But it is supported for all line and area types.
    } else if ((optionParent is! THLine) && (optionParent is! THArea)) {
      throw THCustomException(
          "Unsupported parent command type '${optionParent.elementType}' for 'clip' option.");
    }
  }
}
