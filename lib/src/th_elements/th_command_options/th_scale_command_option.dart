import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_parts/th_length_unit_part.dart';

class THScaleCommandOption extends THCommandOption {
  THScaleCommandOption(super.parent, super.value);

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
  set value(List<dynamic> aValue) {
    final newValueList = [];

    var hasUnit = false;
    for (var value in aValue) {
      if (hasUnit) {
        throw 'Unsupported scale option parameter after unit.';
      }

      // Properly set parameters
      if (value is THDoublePart) {
        newValueList.add(value);
        continue;
      } else if (value is THLengthUnitPart) {
        newValueList.add(value);
        hasUnit = true;
        continue;
      }

      // String parameters
      var isDouble = double.tryParse(value);
      if ((isDouble == null) & !hasUnit) {
        if (!THLengthUnitPart.isUnit(value)) {
          throw 'Unknwon length unit.';
        }

        final newUnit = THLengthUnitPart.fromString(value);
        newValueList.add(newUnit);
        hasUnit = true;
        continue;
      }
      final newDouble = THDoublePart.fromString(value);
      newValueList.add(newDouble);
    }
  }
}
