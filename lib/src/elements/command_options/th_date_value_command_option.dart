// date: -value <date> sets the date for the date point.
import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_date_value_command_option.mapper.dart';

@MappableClass()
class THDateValueCommandOption extends THCommandOption
    with THDateValueCommandOptionMappable {
  static const String _thisOptionType = 'value';
  late THDatetimePart date;

  /// Constructor necessary for dart_mappable support.
  THDateValueCommandOption.withExplicitParameters(
    super.parentMapiahID,
    super.optionType,
    this.date,
  ) : super.withExplicitParameters();

  THDateValueCommandOption.fromString(THHasOptions optionParent, String date)
      : super(optionParent, _thisOptionType) {
    this.date = THDatetimePart(date);
  }

  void valueFromString(String aDate) {
    date.datetime = aDate;
  }

  @override
  String specToFile() {
    return date.toString();
  }
}
