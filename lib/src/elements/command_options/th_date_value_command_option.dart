// date: -value <date> sets the date for the date point.
import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_date_value_command_option.mapper.dart';

@MappableClass()
class THDateValueCommandOption extends THCommandOption
    with THDateValueCommandOptionMappable {
  static const String _thisOptionType = 'value';
  late THDatetimePart date;

  /// Constructor necessary for dart_mappable support.
  THDateValueCommandOption.withExplicitOptionType(
      super.thFile, super.parentMapiahID, super.optionType, this.date)
      : super.withExplicitProperties() {
    _checkOptionParent();
  }

  THDateValueCommandOption.fromString(THHasOptions optionParent, String date)
      : super(optionParent, _thisOptionType) {
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
}
