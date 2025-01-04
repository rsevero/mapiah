import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_has_text.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';

part 'th_copyright_command_option.mapper.dart';

// copyright <date> <string> . copyright date and name
@MappableClass()
class THCopyrightCommandOption extends THCommandOption
    with THCopyrightCommandOptionMappable, THHasText {
  static const String _thisOptionType = 'copyright';
  late THDatetimePart datetime;

  /// Constructor necessary for dart_mappable support.
  THCopyrightCommandOption.withExplicitOptionType(super.optionParent,
      super.optionType, this.datetime, String copyrightMessage) {
    text = copyrightMessage;
  }

  THCopyrightCommandOption(
      THHasOptions optionParent, this.datetime, String copyrightMessage)
      : super(optionParent, _thisOptionType) {
    text = copyrightMessage;
  }

  THCopyrightCommandOption.fromString(
      THHasOptions optionParent, String aDatetime, String aText)
      : super(optionParent, _thisOptionType) {
    datetime = THDatetimePart(aDatetime);
    text = aText;
  }

  @override
  String specToFile() {
    return '$datetime ${textToFile()}';
  }

  String get copyrightMessage => text;
}
