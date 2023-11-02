import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_has_text.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

// text . text of the label, remark or continuation. It may contain following formatting
// keywords:24
// <br> . line break
// <center>/<centre>, <left>, <right> . line alignment for multi-line labels. Ignored
// if there is no <br> tag.
// <thsp> . thin space
// <rm>, <it>, <bf>, <ss>, <si> . font switches
// <rtl> and </rtl> . marks beginning and end of a right-to-left written text
// <lang:XX> . creates multilingual label (see string type for detailed description)
// 6.1.0<size:N> . specify the font size in points; N should be an integer between 1 and 127.
// 6.1.1<size:N%> . specify the font size as a percentage of the native font size of the given
// label; N should be between 1 and 999.25
// <size:S> . specify the font size using predefined scales; S can be one of xs, s, m, l, 6.1.1
// xl.
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
