import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_line_height_command_option.mapper.dart';

// height <value> . height of pit or wall:pit; available in METAPOST as a numeric
// variable ATTR__height.
@MappableClass()
class THLineHeightCommandOption extends THCommandOption
    with THLineHeightCommandOptionMappable {
  late THDoublePart height;

  THLineHeightCommandOption(super.optionParent, this.height) {
    _checkOptionParent();
  }

  THLineHeightCommandOption.fromString(super.optionParent, String height) {
    _checkOptionParent();
    this.height = THDoublePart.fromString(height);
  }

  void _checkOptionParent() {
    if (optionParent is THLine) {
      final platype = (optionParent as THLine).plaType;
      if ((platype != 'pit') && (platype != 'wall')) {
        throw THCustomException(
            "Only available for 'pit' and 'wall:pit' lines.");
      }
    } else {
      throw THCustomException("Only available for lines.");
    }
  }

  @override
  String get optionType => 'height';

  @override
  String specToFile() {
    return height.toString();
  }
}
