part of 'mp_move_command_original_params.dart';

class MPMoveCommandPointOriginalParams extends MPMoveCommandOriginalParams {
  final Offset coordinates;

  MPMoveCommandPointOriginalParams({
    required super.mapiahID,
    required this.coordinates,
  });

  @override
  MPMoveCommandOriginalParamsType get type =>
      MPMoveCommandOriginalParamsType.point;

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map.addAll({
      'mapiahID': mapiahID,
      'coordinates': {
        'dx': coordinates.dx,
        'dy': coordinates.dy,
      },
    });

    return map;
  }

  factory MPMoveCommandPointOriginalParams.fromMap(Map<String, dynamic> map) {
    return MPMoveCommandPointOriginalParams(
      mapiahID: map['mapiahID'],
      coordinates: Offset(
        map['coordinates']['dx'],
        map['coordinates']['dy'],
      ),
    );
  }

  factory MPMoveCommandPointOriginalParams.fromJson(String source) {
    return MPMoveCommandPointOriginalParams.fromMap(jsonDecode(source));
  }

  @override
  MPMoveCommandPointOriginalParams copyWith({
    int? mapiahID,
    Offset? coordinates,
  }) {
    return MPMoveCommandPointOriginalParams(
      mapiahID: mapiahID ?? this.mapiahID,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveCommandPointOriginalParams &&
        other.mapiahID == mapiahID &&
        other.coordinates == coordinates;
  }

  @override
  int get hashCode => Object.hash(mapiahID, coordinates);
}
