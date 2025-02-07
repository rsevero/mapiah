part of 'mp_move_command_complete_params.dart';

class MPMoveCommandPointCompleteParams extends MPMoveCommandCompleteParams {
  final MPMoveCommandPointOriginalParams original;
  final Offset modifiedCoordinates;

  MPMoveCommandPointCompleteParams({
    required this.original,
    required this.modifiedCoordinates,
  });

  @override
  MPMoveCommandCompleteParamsType get type =>
      MPMoveCommandCompleteParamsType.point;

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map.addAll({
      'original': original.toMap(),
      'modifiedCoordinates': {
        'dx': modifiedCoordinates.dx,
        'dy': modifiedCoordinates.dy,
      },
    });

    return map;
  }

  factory MPMoveCommandPointCompleteParams.fromMap(Map<String, dynamic> map) {
    return MPMoveCommandPointCompleteParams(
      original: MPMoveCommandPointOriginalParams.fromMap(map['original']),
      modifiedCoordinates: Offset(
        map['modifiedCoordinates']['dx'],
        map['modifiedCoordinates']['dy'],
      ),
    );
  }

  factory MPMoveCommandPointCompleteParams.fromJson(String source) {
    return MPMoveCommandPointCompleteParams.fromMap(jsonDecode(source));
  }

  @override
  MPMoveCommandPointCompleteParams copyWith({
    MPMoveCommandPointOriginalParams? original,
    Offset? modifiedCoordinates,
  }) {
    return MPMoveCommandPointCompleteParams(
      original: original ?? this.original,
      modifiedCoordinates: modifiedCoordinates ?? this.modifiedCoordinates,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveCommandPointCompleteParams &&
        other.original == original &&
        other.modifiedCoordinates == modifiedCoordinates;
  }

  @override
  int get hashCode => Object.hash(original, modifiedCoordinates);
}
