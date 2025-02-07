part of 'mp_create_command_params.dart';

class MPCreatePointCommandParams extends MPCreateCommandParams {
  final int pointMapiahID;

  MPCreatePointCommandParams({required this.pointMapiahID});

  @override
  MPCreateCommandParams copyWith({int? pointMapiahID}) {
    return MPCreatePointCommandParams(
      pointMapiahID: pointMapiahID ?? this.pointMapiahID,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map.addAll({
      'pointMapiahID': pointMapiahID,
    });

    return map;
  }

  factory MPCreatePointCommandParams.fromMap(Map<String, dynamic> map) {
    return MPCreatePointCommandParams(
      pointMapiahID: map['pointMapiahID'],
    );
  }

  factory MPCreatePointCommandParams.fromJson(String source) {
    return MPCreatePointCommandParams.fromMap(jsonDecode(source));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPCreatePointCommandParams &&
        other.pointMapiahID == pointMapiahID;
  }

  @override
  int get hashCode => pointMapiahID.hashCode;

  @override
  MPCreateCommandParamsType get paramsType => MPCreateCommandParamsType.point;
}
