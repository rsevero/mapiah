import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_exceptions/th_convert_from_list_exception.dart';
import 'package:mapiah/src/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_parts/th_length_unit_part.dart';

class THScaleCommandOption extends THCommandOption {
  List<THDoublePart> _numericSpecifications;
  THLengthUnitPart? unit;

  THScaleCommandOption(super.parent, this._numericSpecifications, [this.unit]);

  @override
  String optionType() {
    return 'scale';
  }

  set numericSpecifications(List<THDoublePart> aList) {
    final length = aList.length;

    if ((length != 1) && (length != 2) && (length != 8)) {
      throw THConvertFromListException('THScaleCommandOption', aList);
    }
  }

  @override
  String specToFile() {
    var asString = '';

    for (var aValue in _numericSpecifications) {
      asString += ' ${aValue.toString()}';
    }

    if (unit != null) {
      asString += ' ${unit.toString()}';
    }

    asString = asString.trim();

    if (asString.contains(' ')) {
      asString = '[ $asString ]';
    }

    return asString;
  }
}
