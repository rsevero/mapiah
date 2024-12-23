import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_line.dart';
import 'package:mapiah/src/th_elements/parts/th_double_part.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

// height <value> . height of pit or wall:pit; available in METAPOST as a numeric
// variable ATTR__height.
class THLineHeightCommandOption extends THCommandOption {
  late THDoublePart height;

  THLineHeightCommandOption(super.optionParent, THDoublePart aHeight) {
    if (optionParent is THLine) {
      final platype = (optionParent as THLine).plaType;
      if ((platype != 'pit') && (platype != 'wall')) {
        throw THCustomException(
            "Only available for 'pit' and 'wall:pit' lines.");
      }
    } else {
      throw THCustomException("Only available for lines.");
    }
    height = aHeight;
  }

  THLineHeightCommandOption.fromString(super.optionParent, String aHeight) {
    if (optionParent is THLine) {
      final platype = (optionParent as THLine).plaType;
      if ((platype != 'pit') && (platype != 'wall')) {
        throw THCustomException(
            "Only available for 'pit' and 'wall:pit' lines.");
      }
    } else {
      throw THCustomException("Only available for lines.");
    }
    height = THDoublePart.fromString(aHeight);
  }

  @override
  String get optionType => 'height';

  @override
  String specToFile() {
    return height.toString();
  }
}
