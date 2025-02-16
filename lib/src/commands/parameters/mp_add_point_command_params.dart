part of 'mp_add_element_command_params.dart';

class MPAddPointCommandParams extends MPAddElementCommandParams {
  final THPoint point;

  MPAddPointCommandParams({required this.point});

  @override
  MPAddElementCommandParams copyWith({THPoint? point}) {
    return MPAddPointCommandParams(
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

  factory MPAddPointCommandParams.fromMap(Map<String, dynamic> map) {
    return MPAddPointCommandParams(
      point: THPoint.fromMap(map['point']),
    );
  }

  factory MPAddPointCommandParams.fromJson(String source) {
    return MPAddPointCommandParams.fromMap(jsonDecode(source));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPAddPointCommandParams && other.point == point;
  }

  @override
  int get hashCode => point.hashCode;

  @override
  MPAddElementCommandParamsType get paramsType =>
      MPAddElementCommandParamsType.point;
}
