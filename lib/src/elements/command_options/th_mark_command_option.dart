import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

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
