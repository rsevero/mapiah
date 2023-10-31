import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_parts/th_datetime_part.dart';
import 'package:mapiah/src/th_elements/th_parts/th_string_part.dart';

class THCopyrightCommandOption extends THCommandOption {
  late THDatetimePart datetime;
  late THStringPart _message;

  THCopyrightCommandOption(super.parent, this.datetime, String aMessage) {
    _message = THStringPart(aMessage);
  }

  THCopyrightCommandOption.fromString(
      super.parent, String aDatetime, String aMessage) {
    datetime = THDatetimePart(aDatetime);
    _message = THStringPart(aMessage);
  }

  set message(String aMessage) {
    _message.content = aMessage;
  }

  String get message {
    return _message.content;
  }

  @override
  String get optionType {
    return 'copyright';
  }

  @override
  String specToFile() {
    return '$datetime ${_message.toFile()}';
  }
}
