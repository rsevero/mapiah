import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_point_position_part.dart';
import 'package:mapiah/src/elements/parts/th_string_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_sketch_command_option.mapper.dart';

// sketch <filename> <x> <y> . underlying sketch bitmap specification (lower left cor-
// ner coordinates).
@MappableClass()
class THSketchCommandOption extends THCommandOption
    with THSketchCommandOptionMappable {
  static const String _thisOptionType = 'sketch';
  late THStringPart _filename;
  late THPointPositionPart point;

  /// Constructor necessary for dart_mappable support.
  THSketchCommandOption.withExplicitOptionType(
      super.optionParent, super.optionType, String filename, this.point) {
    _filename = THStringPart(filename);
  }

  THSketchCommandOption.fromString(
      THHasOptions optionParent, String aFilename, List<dynamic> aPointList)
      : super(optionParent, _thisOptionType) {
    _filename = THStringPart(aFilename);
    pointFromStringList(aPointList);
  }

  void pointFromStringList(List<dynamic> aList) {
    point = THPointPositionPart.fromStringList(aList);
  }

  set filename(String aFilename) {
    _filename.content = aFilename;
  }

  String get filename {
    return _filename.content;
  }

  @override
  String specToFile() {
    String asString = '';

    asString = "${_filename.toFile()} ${point.toString()}";

    return asString;
  }
}
