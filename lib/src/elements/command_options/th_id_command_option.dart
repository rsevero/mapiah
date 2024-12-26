import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_id_command_option.mapper.dart';

// id <ext_keyword> . ID of the symbol.
@MappableClass()
class THIDCommandOption extends THCommandOption with THIDCommandOptionMappable {
  late String _thID;

  THIDCommandOption(super.optionParent, String thID) {
    this.thID = thID;
  }

  set thID(String aTHID) {
    optionParent.thFile.updateTHID(optionParent, aTHID);
    _thID = aTHID;
  }

  String get thID {
    return _thID;
  }

  @override
  String get optionType => 'id';

  @override
  String specToFile() {
    return _thID;
  }
}
