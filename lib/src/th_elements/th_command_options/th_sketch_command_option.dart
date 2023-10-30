import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_parts/th_point_part.dart';

class THSketchCommandOption extends THCommandOption {
  String filename;
  late THPointPart point;

  THSketchCommandOption(super.parent, this.filename, this.point);

  THSketchCommandOption.fromString(
      super.parent, this.filename, List<dynamic> aPointList) {
    pointFromStringList(aPointList);
  }

  void pointFromStringList(List<dynamic> aList) {
    point = THPointPart.fromStringList(aList);
  }

  @override
  String optionType() {
    return 'sketch';
  }

  @override
  String specToFile() {
    var asString = '';

    asString = "$filename ${point.x.toString()} ${point.y.toString()}";

    return asString;
  }
}
