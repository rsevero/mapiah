import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_has_text.dart';
import 'package:mapiah/src/th_elements/th_parts/th_string_part.dart';

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
