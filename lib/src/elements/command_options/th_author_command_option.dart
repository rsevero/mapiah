import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';
import 'package:mapiah/src/elements/parts/th_person_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_author_command_option.mapper.dart';

// author <date> <person> . author of the data and its creation date
@MappableClass()
class THAuthorCommandOption extends THCommandOption
    with THAuthorCommandOptionMappable {
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
