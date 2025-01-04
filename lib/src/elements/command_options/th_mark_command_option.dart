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
  static const String _thisOptionType = 'mark';
  late String _mark;

  /// Constructor necessary for dart_mappable support.
  THMarkCommandOption.withExplicitOptionType(
      super.optionParent, super.optionType, String mark) {
    this.mark = mark;
  }

  THMarkCommandOption(THHasOptions optionParent, String mark)
      : super(optionParent, _thisOptionType) {
    this.mark = mark;
  }

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
