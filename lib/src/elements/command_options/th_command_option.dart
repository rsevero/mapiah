import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_command_option.mapper.dart';

@MappableClass()
abstract class THCommandOption with THCommandOptionMappable {
  late THFile _thFile;
  late int parentMapiahID;
  late final String _optionType;

  // Constructor necessary for dart_mappable support.
  THCommandOption.withExplicitProperties(
      THFile thFile, this.parentMapiahID, String optionType) {
    _optionType = optionType;
    _thFile = thFile;
  }

  THCommandOption(THHasOptions optionParent, String optionType) {
    _optionType = optionType;
    _thFile = optionParent.thFile;
    parentMapiahID = optionParent.mapiahID;
    optionParent.addUpdateOption(this);
  }

  String get optionType => _optionType;

  THFile get thFile => _thFile;

  THHasOptions get optionParent =>
      _thFile.elementByMapiahID(parentMapiahID) as THHasOptions;

  String specToFile();

  THCommandOption clone() {
    final THCommandOption newOption = copyWith();

    return newOption;
  }
}
