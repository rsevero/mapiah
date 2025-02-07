part of 'mp_create_command_params.dart';

class MPCreateLineCommandParams extends MPCreateCommandParams {
  final THLine line;
  final List<THElement> lineChildren;

  MPCreateLineCommandParams({
    required this.line,
    required this.lineChildren,
  });

  @override
  MPCreateCommandParams copyWith({
    THLine? line,
    List<THElement>? lineChildren,
  }) {
    return MPCreateLineCommandParams(
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

  factory MPCreateLineCommandParams.fromMap(Map<String, dynamic> map) {
    return MPCreateLineCommandParams(
      line: THLine.fromMap(map['line']),
      lineChildren: List<THElement>.from(
        map['lineChildren'].map((x) => THElement.fromMap(x)),
      ),
    );
  }

  factory MPCreateLineCommandParams.fromJson(String source) {
    return MPCreateLineCommandParams.fromMap(jsonDecode(source));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPCreateLineCommandParams &&
        other.line == line &&
        other.lineChildren == lineChildren;
  }

  @override
  int get hashCode => line.hashCode ^ Object.hashAll(lineChildren);

  @override
  MPCreateCommandParamsType get paramsType => MPCreateCommandParamsType.line;
}
