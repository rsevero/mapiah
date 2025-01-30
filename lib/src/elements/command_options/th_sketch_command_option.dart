part of 'th_command_option.dart';

// sketch <filename> <x> <y> . underlying sketch bitmap specification (lower left cor-
// ner coordinates).
class THSketchCommandOption extends THCommandOption {
  late final THStringPart _filename;
  late final THPositionPart point;

  THSketchCommandOption.forCWJM({
    required super.parentMapiahID,
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

  @override
  THCommandOptionType get optionType => THCommandOptionType.sketch;

  void pointFromStringList(List<dynamic> list) {
    point = THPositionPart.fromStringList(list: list);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'filename': _filename.toMap(),
      'point': point.toMap(),
    };
  }

  factory THSketchCommandOption.fromMap(Map<String, dynamic> map) {
    return THSketchCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
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
    String? filename,
    THPositionPart? point,
  }) {
    return THSketchCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      filename: filename ?? _filename.content,
      point: point ?? this.point,
    );
  }

  @override
  bool operator ==(covariant THSketchCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other._filename == _filename &&
        other.point == point;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
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
