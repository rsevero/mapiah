import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_parts/th_datetime_part.dart';

class THCopyrightCommandOption extends THCommandOption {
  late THDatetimePart datetime;
  late String message;

  THCopyrightCommandOption(super.parent, this.datetime, this.message);

  THCopyrightCommandOption.fromString(
      super.parent, String aDatetime, this.message) {
    datetime = THDatetimePart(aDatetime);
  }

  @override
  String optionType() {
    return 'copyright';
  }

  @override
  String specToFile() {
    return '$datetime "$message"';
  }
}
