part of 'mp_create_command_params.dart';

class MPCreatePointCommandParams extends MPCreateCommandParams {
  final THPoint point;

  MPCreatePointCommandParams({required this.point});

  @override
  MPCreateCommandParams copyWith({THPoint? point}) {
    return MPCreatePointCommandParams(
      point: point ?? this.point,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map.addAll({
      'point': point.toMap(),
    });

    return map;
  }

  factory MPCreatePointCommandParams.fromMap(Map<String, dynamic> map) {
    return MPCreatePointCommandParams(
      point: THPoint.fromMap(map['point']),
    );
  }

  factory MPCreatePointCommandParams.fromJson(String source) {
    return MPCreatePointCommandParams.fromMap(jsonDecode(source));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPCreatePointCommandParams && other.point == point;
  }

  @override
  int get hashCode => point.hashCode;

  @override
  MPCreateCommandParamsType get paramsType => MPCreateCommandParamsType.point;
}
