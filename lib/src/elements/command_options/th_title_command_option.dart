import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_has_text.dart';

part 'th_title_command_option.mapper.dart';

// title <string> . description of the object
@MappableClass()
class THTitleCommandOption extends THCommandOption
    with THTitleCommandOptionMappable, THHasText {
  static const String _thisOptionType = 'title';

  /// Constructor necessary for dart_mappable support.
  THTitleCommandOption.withExplicitOptionType(
      super.optionParent, super.optionType, String text) {
    this.text = text;
  }

  THTitleCommandOption(THHasOptions optionParent, String text)
      : super(optionParent, _thisOptionType) {
    this.text = text;
  }

  @override
  String specToFile() {
    return textToFile();
  }
}
