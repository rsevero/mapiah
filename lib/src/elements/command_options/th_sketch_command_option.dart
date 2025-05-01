part of 'th_command_option.dart';

// sketch <filename> <x> <y> . underlying sketch bitmap specification (lower
// left corner coordinates).
class THSketchCommandOption extends THCommandOption {
  late final THStringPart _filename;
  late final THPositionPart point;

  THSketchCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required String filename,
    required this.point,
  }) : super.forCWJM() {
    _filename = THStringPart(content: filename);
  }

  THSketchCommandOption.fromString({
    required super.optionParent,
    required String filename,
    required List<dynamic> pointList,
    super.originalLineInTH2File = '',
  }) : super() {
    _filename = THStringPart(content: filename);
    pointFromStringList(pointList);
  }

  THSketchCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required String filename,
    required List<String> pointList,
    super.originalLineInTH2File = '',
  }) : super.forCWJM() {
    _filename = THStringPart(content: filename);
    pointFromStringList(pointList);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.sketch;

  void pointFromStringList(List<dynamic> list) {
    point = THPositionPart.fromStringList(list: list);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'filename': _filename.toMap(),
      'point': point.toMap(),
    });

    return map;
  }

  factory THSketchCommandOption.fromMap(Map<String, dynamic> map) {
    return THSketchCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      filename: map['filename']['content'],
      point: THPositionPart.fromMap(map['point']),
    );
  }

  factory THSketchCommandOption.fromJson(String jsonString) {
    return THSketchCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THSketchCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    String? filename,
    THPositionPart? point,
  }) {
    return THSketchCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      filename: filename ?? _filename.content,
      point: point ?? this.point,
    );
  }

  @override
  bool operator ==(covariant THSketchCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other._filename == _filename &&
        other.point == point;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        _filename,
        point,
      );

  String get filename {
    return _filename.content;
  }

  @override
  String specToFile() {
    String asString = '';

    asString = "${_filename.toString()} ${point.toString()}";

    return asString;
  }
}
