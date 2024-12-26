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
  late THDatetimePart datetime;

  THCopyrightCommandOption(
      super.parent, this.datetime, String copyrightMessage) {
    text = copyrightMessage;
  }

  THCopyrightCommandOption.fromString(
      super.parent, String aDatetime, String aText) {
    datetime = THDatetimePart(aDatetime);
    text = aText;
  }

  @override
  String get optionType {
    return 'copyright';
  }

  @override
  String specToFile() {
    return '$datetime ${textToFile()}';
  }

  String get copyrightMessage => text;
}
