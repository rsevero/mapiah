import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_parts/th_string_part.dart';

class THTitleCommandOption extends THCommandOption {
  late THStringPart _title;

  THTitleCommandOption(super.parent, String aContent) {
    _title = THStringPart(aContent);
  }

  @override
  String get optionType {
    return 'title';
  }

  set title(String aTitle) {
    _title.content = aTitle;
  }

  String get title {
    return _title.content;
  }

  @override
  String specToFile() {
    return _title.toFile();
  }
}
