import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_has_platype.dart';
import 'package:mapiah/src/elements/th_has_text.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_text_command_option.mapper.dart';

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
@MappableClass()
class THTextCommandOption extends THCommandOption
    with THTextCommandOptionMappable, THHasText {
  static const String _thisOptionType = 'text';
  static final Map<String, Set<String>> _supportedTypes = {
    'point': {
      'label',
      'remark',
      'continuation',
    },
    'line': {
      'label',
    },
  };

  /// Constructor necessary for dart_mappable support.
  THTextCommandOption.withExplicitOptionType(
      super.optionParent, super.optionType, String text) {
    _checkOptionParent();
    this.text = text;
  }

  THTextCommandOption(THHasOptions optionParent, String text)
      : super(optionParent, _thisOptionType) {
    _checkOptionParent();
    this.text = text;
  }

  void _checkOptionParent() {
    final String parentType = optionParent.elementType;
    if (_supportedTypes.containsKey(parentType)) {
      final String plaType = (optionParent as THHasPLAType).plaType;
      if (!_supportedTypes[parentType]!.contains(plaType)) {
        throw THCustomException(
            "'text' command option not supported on elements of type '$parentType' and plaType '$plaType'.");
      }
    } else {
      throw THCustomException(
          "'text' command option not supported on elements of type '$parentType'.");
    }
  }

  @override
  String specToFile() {
    return textToFile();
  }
}
