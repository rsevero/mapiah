import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_parts/th_datetime_part.dart';
import 'package:mapiah/src/th_elements/th_parts/th_person_part.dart';

// author <date> <person> . author of the data and its creation date
class THAuthorCommandOption extends THCommandOption {
  late THDatetimePart datetime;
  late THPersonPart person;

  THAuthorCommandOption(super.parent, this.datetime, this.person);

  THAuthorCommandOption.fromString(
      super.parent, String aDatetime, String aPerson) {
    datetime = THDatetimePart(aDatetime);
    person = THPersonPart.fromString(aPerson);
  }

  @override
  String get optionType {
    return 'author';
  }

  @override
  String specToFile() {
    return '$datetime $person';
  }
}
