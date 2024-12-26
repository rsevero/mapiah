import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_has_text.dart';

part 'th_title_command_option.mapper.dart';

// title <string> . description of the object
@MappableClass()
class THTitleCommandOption extends THCommandOption
    with THTitleCommandOptionMappable, THHasText {
  THTitleCommandOption(super.parent, String text) {
    this.text = text;
  }

  @override
  String get optionType {
    return 'title';
  }

  @override
  String specToFile() {
    return textToFile();
  }
}
