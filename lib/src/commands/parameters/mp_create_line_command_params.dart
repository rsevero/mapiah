part of 'mp_create_command_params.dart';

class MPCreateLineCommandParams extends MPCreateCommandParams {
  final int lineMapiahID;
  final List<THElement> lineChildren;

  MPCreateLineCommandParams({
    required this.lineMapiahID,
    required this.lineChildren,
  });

  @override
  MPCreateCommandParams copyWith({
    int? lineMapiahID,
    List<THElement>? lineChildren,
  }) {
    return MPCreateLineCommandParams(
      lineMapiahID: lineMapiahID ?? this.lineMapiahID,
      lineChildren: lineChildren ?? this.lineChildren,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map.addAll({
      'lineMapiahID': lineMapiahID,
      'lineChildren': lineChildren.map((x) => x.toMap()).toList(),
    });

    return map;
  }

  factory MPCreateLineCommandParams.fromMap(Map<String, dynamic> map) {
    return MPCreateLineCommandParams(
      lineMapiahID: map['lineMapiahID'],
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
        other.lineMapiahID == lineMapiahID &&
        other.lineChildren == lineChildren;
  }

  @override
  int get hashCode => lineMapiahID.hashCode ^ Object.hashAll(lineChildren);

  @override
  MPCreateCommandParamsType get paramsType => MPCreateCommandParamsType.line;
}
