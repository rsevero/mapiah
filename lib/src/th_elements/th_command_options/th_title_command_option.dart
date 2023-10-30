import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_parts/th_string_part.dart';

class THTitleCommandOption extends THCommandOption {
  late THStringPart _title;

  THTitleCommandOption(super.parent, String aContent) {
    _title = THStringPart(aContent);
  }

  @override
  String optionType() {
    return 'title';
  }

  @override
  String specToFile() {
    return _title.toFile();
  }
}
