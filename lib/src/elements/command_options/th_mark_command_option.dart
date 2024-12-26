import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_mark_command_option.mapper.dart';

// mark <keyword> . is used to mark the point on the line (see join command).
@MappableClass()
class THMarkCommandOption extends THCommandOption
    with THMarkCommandOptionMappable {
  late String _mark;

  THMarkCommandOption(super.optionParent, String mark) {
    this.mark = mark;
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
