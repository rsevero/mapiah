import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_parts/th_cs_part.dart';

class THCSCommandOption extends THCommandOption {
  THCSPart? coordinateSystem;

  THCSCommandOption(super.parent);

  @override
  String optionType() {
    return 'cs';
  }

  @override
  String specToString() {
    var asString =
        (coordinateSystem == null) ? '' : coordinateSystem.toString();

    return asString;
  }
}
