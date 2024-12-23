// date: -value <date> sets the date for the date point.
import 'package:mapiah/src/elements/command_options/th_value_command_option.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

class THDateValueCommandOption extends THValueCommandOption {
  late THDatetimePart _date;

  THDateValueCommandOption.fromString(super.optionParent, String aDate) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'date')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'date'.");
    }
    _date = THDatetimePart(aDate);
  }

  void valueFromString(String aDate) {
    _date.datetime = aDate;
  }

  @override
  String specToFile() {
    return _date.toString();
  }
}
