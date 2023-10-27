import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_parts/th_length_unit_part.dart';

class THScaleCommandOption extends THCommandOption {
  THScaleCommandOption(aParent, aValue) : super(aParent, []) {
    value = aValue;
  }

  @override
  String type() {
    return 'scale';
  }

  @override
  String valueToString() {
    var asString = '';

    for (final aValue in value) {
      asString += " ${aValue.toString()}";
    }

    if (asString.isNotEmpty) {
      asString = asString.substring(1);
    }

    if (value.length > 1) {
      asString = "[$asString]";
    }

    return asString;
  }

  // @override
  set value(List<dynamic> aValueList) {
    value.clear();

    var hasUnit = false;
    for (var aValue in aValueList) {
      if (hasUnit) {
        throw 'Unsupported scale option parameter after unit.';
      }

      // Properly set parameters
      if (aValue is THDoublePart) {
        value.add(aValue);
        continue;
      } else if (aValue is THLengthUnitPart) {
        value.add(aValue);
        hasUnit = true;
        continue;
      }

      // String parameters
      var isDouble = double.tryParse(aValue);
      if ((isDouble == null) & !hasUnit) {
        if (!THLengthUnitPart.isUnit(aValue)) {
          throw 'Unknwon length unit.';
        }

        final newUnit = THLengthUnitPart.fromString(aValue);
        value.add(newUnit);
        hasUnit = true;
        continue;
      }
      final newDouble = THDoublePart.fromString(aValue);
      value.add(newDouble);
    }
  }
}
