import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_parts/th_point_part.dart';

class THSketchCommandOption extends THCommandOption {
  String? filename;
  THPointPart? point;

  THSketchCommandOption(super.parent);

  @override
  String optionType() {
    return 'sketch';
  }

  @override
  String specToString() {
    var asString = '';

    if (filename == null) {
      return asString;
    }

    if (point == null) {
      return asString;
    }

    asString = "$filename ${point!.x.toString()} ${point!.y.toString()}";

    return asString;
  }
}
