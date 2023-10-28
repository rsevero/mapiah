import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';

class THCSCommandOption extends THCommandOption {
  String? coordinateSystem;

  THCSCommandOption(super.parent);

  @override
  String optionType() {
    return 'cs';
  }

  @override
  String specToString() {
    var asString = (coordinateSystem == null) ? '' : coordinateSystem!.trim();

    return asString;
  }
}
