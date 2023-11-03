import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_has_text.dart';
import 'package:mapiah/src/th_elements/th_parts/th_datetime_part.dart';

// copyright <date> <string> . copyright date and name
class THCopyrightCommandOption extends THCommandOption with THHasText {
  late THDatetimePart datetime;

  THCopyrightCommandOption(
      super.parent, this.datetime, String aCopyrightMessage) {
    text = aCopyrightMessage;
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
}
