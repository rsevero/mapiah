import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_scrap_command_option.mapper.dart';

// scrap <reference> . if the point type is section, this is a reference to a cross-section
// scrap.
@MappableClass()
class THScrapCommandOption extends THCommandOption
    with THScrapCommandOptionMappable {
  late String reference;

  THScrapCommandOption(super.optionParent, this.reference) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'section')) {
      throw THCustomException(
          "Option 'scrap' only valid for points of type 'section'.");
    }
  }

  @override
  String get optionType => 'scrap';

  @override
  String specToFile() {
    return reference;
  }
}
