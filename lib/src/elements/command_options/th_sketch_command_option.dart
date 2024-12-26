import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_point_part.dart';
import 'package:mapiah/src/elements/parts/th_string_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_sketch_command_option.mapper.dart';

// sketch <filename> <x> <y> . underlying sketch bitmap specification (lower left cor-
// ner coordinates).
@MappableClass()
class THSketchCommandOption extends THCommandOption
    with THSketchCommandOptionMappable {
  late THStringPart _filename;
  late THPointPart point;

  THSketchCommandOption(super.parent, String filename, this.point) {
    _filename = THStringPart(filename);
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
