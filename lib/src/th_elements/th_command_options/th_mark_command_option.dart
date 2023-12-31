import 'package:mapiah/src/th_definitions/th_definitions.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

// mark <keyword> . is used to mark the point on the line (see join command).
class THMarkCommandOption extends THCommandOption {
  late String _mark;

  THMarkCommandOption(super.optionParent, String aMark) {
    mark = aMark;
  }

  @override
  String get optionType => 'mark';

  set mark(String aMark) {
    if (!thKeywordRegex.hasMatch(aMark)) {
      throw THCustomException(
          "Invalid mark '$aMark'. A mark must be a keyword.");
    }
    _mark = aMark;
  }

  String get mark {
    return _mark;
  }

  @override
  String specToFile() {
    return _mark;
  }
}
