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
  static const String _thisOptionType = 'author';
  late THDatetimePart datetime;
  late THPersonPart person;

  /// Constructor necessary for dart_mappable support.
  THAuthorCommandOption.withExplicitParameters(
    super.parentMapiahID,
    super.optionType,
    this.datetime,
    this.person,
  ) : super.withExplicitParameters();

  THAuthorCommandOption(THHasOptions optionParent, this.datetime, this.person)
      : super(optionParent, _thisOptionType);

  THAuthorCommandOption.fromString(
      THHasOptions optionParent, String aDatetime, String aPerson)
      : super(optionParent, _thisOptionType) {
    datetime = THDatetimePart(aDatetime);
    person = THPersonPart.fromString(aPerson);
  }

  @override
  String specToFile() {
    return '$datetime $person';
  }
}
