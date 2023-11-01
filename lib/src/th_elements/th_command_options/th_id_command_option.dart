import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THIDCommandOption extends THCommandOption {
  late String _id;

  THIDCommandOption(super.parentOption, String aID) {
    parentOption.thFile.addElementWithID(parentOption, aID);
    _id = aID;
  }

  set id(String aID) {
    parentOption.thFile.updateElementID(parentOption, aID);
    _id = aID;
  }

  String get id {
    return _id;
  }

  @override
  String get optionType => 'id';

  @override
  String specToFile() {
    return _id;
  }
}
