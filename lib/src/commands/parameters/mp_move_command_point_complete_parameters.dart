part of 'mp_move_command_complete_parameters.dart';

class MPMoveCommandPointCompleteParameters
    extends MPMoveCommandCompleteParameters {
  final MPMoveCommandPointOriginalParameters original;
  final Offset modifiedCoordinates;

  MPMoveCommandPointCompleteParameters({
    required this.original,
    required this.modifiedCoordinates,
  });

  @override
  MPMoveCommandCompleteParametersType get type =>
      MPMoveCommandCompleteParametersType.point;

  @override
  Map<String, dynamic> toMap() {
    return {
      'moveCommandCompleteParametersType': type.name,
      'original': original.toMap(),
      'modifiedCoordinates': {
        'dx': modifiedCoordinates.dx,
        'dy': modifiedCoordinates.dy,
      },
    };
  }

  factory MPMoveCommandPointCompleteParameters.fromMap(
      Map<String, dynamic> map) {
    return MPMoveCommandPointCompleteParameters(
      original: MPMoveCommandPointOriginalParameters.fromMap(map['original']),
      modifiedCoordinates: Offset(
        map['modifiedCoordinates']['dx'],
        map['modifiedCoordinates']['dy'],
      ),
    );
  }

  factory MPMoveCommandPointCompleteParameters.fromJson(String source) {
    return MPMoveCommandPointCompleteParameters.fromMap(jsonDecode(source));
  }

  @override
  MPMoveCommandPointCompleteParameters copyWith({
    MPMoveCommandPointOriginalParameters? original,
    Offset? modifiedCoordinates,
  }) {
    return MPMoveCommandPointCompleteParameters(
      original: original ?? this.original,
      modifiedCoordinates: modifiedCoordinates ?? this.modifiedCoordinates,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveCommandPointCompleteParameters &&
        other.original == original &&
        other.modifiedCoordinates == modifiedCoordinates;
  }

  @override
  int get hashCode => Object.hash(original, modifiedCoordinates);
}
