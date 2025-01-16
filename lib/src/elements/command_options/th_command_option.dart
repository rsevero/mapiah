import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_command_option.mapper.dart';

@MappableClass()
abstract class THCommandOption with THCommandOptionMappable {
  late int parentMapiahID;
  late final String _optionType;

  // Constructor necessary for dart_mappable support.
  THCommandOption.withExplicitParameters(
    this.parentMapiahID,
    String optionType,
  ) {
    _optionType = optionType;
  }

  THCommandOption(THHasOptions optionParent, String optionType) {
    _optionType = optionType;
    parentMapiahID = optionParent.mapiahID;
    optionParent.addUpdateOption(this);
  }

  String get optionType => _optionType;

  THHasOptions optionParent(THFile thFile) =>
      thFile.elementByMapiahID(parentMapiahID) as THHasOptions;

  String specToFile();
}
