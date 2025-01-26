part of 'mp_move_command_original_parameters.dart';

class MPMoveCommandPointOriginalParameters
    extends MPMoveCommandOriginalParameters {
  final Offset coordinates;

  MPMoveCommandPointOriginalParameters({
    required super.mapiahID,
    required this.coordinates,
  });

  @override
  MPMoveCommandOriginalParametersType get type =>
      MPMoveCommandOriginalParametersType.point;

  @override
  Map<String, dynamic> toMap() {
    return {
      'moveCommandOriginalParametersType': type.name,
      'mapiahID': mapiahID,
      'coordinates': {
        'dx': coordinates.dx,
        'dy': coordinates.dy,
      },
    };
  }

  factory MPMoveCommandPointOriginalParameters.fromMap(
      Map<String, dynamic> map) {
    return MPMoveCommandPointOriginalParameters(
      mapiahID: map['mapiahID'],
      coordinates: Offset(
        map['coordinates']['dx'],
        map['coordinates']['dy'],
      ),
    );
  }

  factory MPMoveCommandPointOriginalParameters.fromJson(String source) {
    return MPMoveCommandPointOriginalParameters.fromMap(jsonDecode(source));
  }

  @override
  MPMoveCommandPointOriginalParameters copyWith({
    int? mapiahID,
    Offset? coordinates,
  }) {
    return MPMoveCommandPointOriginalParameters(
      mapiahID: mapiahID ?? this.mapiahID,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveCommandPointOriginalParameters &&
        other.mapiahID == mapiahID &&
        other.coordinates == coordinates;
  }

  @override
  int get hashCode => Object.hash(mapiahID, coordinates);
}
