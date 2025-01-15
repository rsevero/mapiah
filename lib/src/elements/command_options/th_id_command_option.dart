import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_id_command_option.mapper.dart';

// id <ext_keyword> . ID of the symbol.
@MappableClass()
class THIDCommandOption extends THCommandOption with THIDCommandOptionMappable {
  static const String _thisOptionType = 'id';
  late String _thID;

  /// Constructor necessary for dart_mappable support.
  THIDCommandOption.withExplicitParameters(
      super.thFile, super.parentMapiahID, super.optionType, String thID)
      : _thID = thID,
        super.withExplicitParameters();

  THIDCommandOption(THHasOptions optionParent, String thID)
      : _thID = thID,
        super(optionParent, _thisOptionType) {
    optionParent.thFile.addElementWithTHID(optionParent, thID);
  }

  set thID(String aTHID) {
    optionParent.thFile.updateTHID(optionParent, aTHID);
    _thID = aTHID;
  }

  String get thID {
    return _thID;
  }

  @override
  String specToFile() {
    return _thID;
  }
}
