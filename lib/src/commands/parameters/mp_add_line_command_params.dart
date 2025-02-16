part of 'mp_add_element_command_params.dart';

class MPAddLineCommandParams extends MPAddElementCommandParams {
  final THLine line;
  final List<THElement> lineChildren;

  MPAddLineCommandParams({
    required this.line,
    required this.lineChildren,
  });

  @override
  MPAddElementCommandParams copyWith({
    THLine? line,
    List<THElement>? lineChildren,
  }) {
    return MPAddLineCommandParams(
      line: line ?? this.line,
      lineChildren: lineChildren ?? this.lineChildren,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map.addAll({
      'line': line.toMap(),
      'lineChildren': lineChildren.map((x) => x.toMap()).toList(),
    });

    return map;
  }

  factory MPAddLineCommandParams.fromMap(Map<String, dynamic> map) {
    return MPAddLineCommandParams(
      line: THLine.fromMap(map['line']),
      lineChildren: List<THElement>.from(
        map['lineChildren'].map((x) => THElement.fromMap(x)),
      ),
    );
  }

  factory MPAddLineCommandParams.fromJson(String source) {
    return MPAddLineCommandParams.fromMap(jsonDecode(source));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPAddLineCommandParams &&
        other.line == line &&
        other.lineChildren == lineChildren;
  }

  @override
  int get hashCode => line.hashCode ^ Object.hashAll(lineChildren);

  @override
  MPAddElementCommandParamsType get paramsType =>
      MPAddElementCommandParamsType.line;
}
