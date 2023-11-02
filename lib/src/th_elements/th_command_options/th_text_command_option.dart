import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_has_text.dart';
import 'package:mapiah/src/th_elements/th_parts/th_string_part.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THTextCommandOption extends THCommandOption with THHasText {
  static final _supportedPointTypes = <String>{
    'label',
    'remark',
    'continuation'
  };

  THTextCommandOption(super.parentOption, String aText) {
    if ((parentOption is! THPoint) ||
        (!_supportedPointTypes.contains((parentOption as THPoint).pointType))) {
      throw THCustomException(
          "'text' command option not supported on points of type '${(parentOption as THPoint).pointType}'.");
    }
    text = aText;
  }

  @override
  String get optionType => 'text';

  @override
  String specToFile() {
    return textToFile();
  }
}
