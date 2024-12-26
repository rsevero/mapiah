// date: -value <date> sets the date for the date point.
import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_date_value_command_option.mapper.dart';

@MappableClass()
class THDateValueCommandOption extends THCommandOption
    with THDateValueCommandOptionMappable {
  late THDatetimePart date;

  THDateValueCommandOption(super.optionParent, this.date) {
    _checkOptionParent();
  }

  THDateValueCommandOption.fromString(super.optionParent, String date) {
    _checkOptionParent();
    this.date = THDatetimePart(date);
  }

  void _checkOptionParent() {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'date')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'date'.");
    }
  }

  void valueFromString(String aDate) {
    date.datetime = aDate;
  }

  @override
  String specToFile() {
    return date.toString();
  }

  @override
  String get optionType => 'value';
}
