import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_text.dart';

// title <string> . description of the object
class THTitleCommandOption extends THCommandOption with THHasText {
  THTitleCommandOption(super.parent, String aTitle) {
    text = aTitle;
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
