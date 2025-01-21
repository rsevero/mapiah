import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/parts/th_string_part.dart';

// sketch <filename> <x> <y> . underlying sketch bitmap specification (lower left cor-
// ner coordinates).
class THSketchCommandOption extends THCommandOption {
  static const String _thisOptionType = 'sketch';
  late final THStringPart _filename;
  late final THPositionPart point;

  THSketchCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required String filename,
    required this.point,
  }) : super() {
    _filename = THStringPart(content: filename);
  }

  THSketchCommandOption.fromString({
    required super.optionParent,
    required String filename,
    required List<dynamic> pointList,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    _filename = THStringPart(content: filename);
    pointFromStringList(pointList);
  }

  void pointFromStringList(List<dynamic> list) {
    point = THPositionPart.fromStringList(list: list);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'filename': _filename.toMap(),
      'point': point.toMap(),
    };
  }

  factory THSketchCommandOption.fromMap(Map<String, dynamic> map) {
    return THSketchCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
      filename: map['filename']['content'],
      point: THPositionPart.fromMap(map['point']),
    );
  }

  factory THSketchCommandOption.fromJson(String jsonString) {
    return THSketchCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THSketchCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    String? filename,
    THPositionPart? point,
  }) {
    return THSketchCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      filename: filename ?? _filename.content,
      point: point ?? this.point,
    );
  }

  @override
  bool operator ==(covariant THSketchCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other._filename == _filename &&
        other.point == point;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        _filename,
        point,
      );

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
