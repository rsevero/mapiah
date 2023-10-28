import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_parts/th_length_unit_part.dart';

class THScaleCommandOption extends THCommandOption {
  List<THDoublePart> numericSpecifications = [];
  THLengthUnitPart? unitValue;

  THScaleCommandOption(super.parent);

  @override
  String optionType() {
    return 'scale';
  }

  @override
  String specToString() {
    var asString = '';

    if (numericSpecifications.isEmpty) {
      return asString;
    }

    for (var aValue in numericSpecifications) {
      asString += " ${aValue.toString()}";
    }

    if (unitValue != null) {
      asString += " ${unitValue.toString()}";
    }

    asString = asString.trim();

    if (asString.contains(' ')) {
      asString = "[$asString]";
    }

    return asString;
  }
}
