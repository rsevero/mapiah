import 'package:mapiah/src/th_elements/command_options/th_command_option.dart';

// id <ext_keyword> . ID of the symbol.
class THIDCommandOption extends THCommandOption {
  late String _thID;

  THIDCommandOption(super.optionParent, String aTHID) {
    optionParent.thFile.addElementWithTHID(optionParent, aTHID);
    _thID = aTHID;
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
