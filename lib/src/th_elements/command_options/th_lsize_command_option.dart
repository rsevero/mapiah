import 'package:mapiah/src/th_elements/command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_line.dart';
import 'package:mapiah/src/th_elements/parts/th_double_part.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

// l-size <number> . Size of the line (to the left). Only valid on and required for slope
// type.
//
// size <number> . synonym of l-size
class THLSizeCommandOption extends THCommandOption {
  late THDoublePart number;

  THLSizeCommandOption(super.optionParent, THDoublePart aNumber) {
    if ((optionParent.parent is! THLine) ||
        ((optionParent.parent as THLine).plaType != 'slope')) {
      throw THCustomException(
          "'l-size' option only supported for 'slope' lines.");
    }
    number = aNumber;
  }

  THLSizeCommandOption.fromString(super.optionParent, String aNumber) {
    if ((optionParent.parent is! THLine) ||
        ((optionParent.parent as THLine).plaType != 'slope')) {
      throw THCustomException(
          "'l-size' option only supported for 'slope' lines.");
    }
    number = THDoublePart.fromString(aNumber);
  }

  @override
  String get optionType => 'l-size';

  @override
  String specToFile() {
    return number.toString();
  }
}
