import 'package:mapiah/src/th_elements/command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/parts/th_point_part.dart';
import 'package:mapiah/src/th_elements/parts/th_string_part.dart';

// sketch <filename> <x> <y> . underlying sketch bitmap specification (lower left cor-
// ner coordinates).
class THSketchCommandOption extends THCommandOption {
  late THStringPart _filename;
  late THPointPart point;

  THSketchCommandOption(super.parent, String aFilename, this.point) {
    _filename = THStringPart(aFilename);
  }

  THSketchCommandOption.fromString(
      super.parent, String aFilename, List<dynamic> aPointList) {
    _filename = THStringPart(aFilename);
    pointFromStringList(aPointList);
  }

  void pointFromStringList(List<dynamic> aList) {
    point = THPointPart.fromStringList(aList);
  }

  set filename(String aFilename) {
    _filename.content = aFilename;
  }

  String get filename {
    return _filename.content;
  }

  @override
  String get optionType {
    return 'sketch';
  }

  @override
  String specToFile() {
    var asString = '';

    asString = "${_filename.toFile()} ${point.toString()}";

    return asString;
  }
}
