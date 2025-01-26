part of 'mp_move_command_complete_parameters.dart';

class MPMoveCommandLineCompleteParameters
    extends MPMoveCommandCompleteParameters {
  final MPMoveCommandLineOriginalParameters original;
  final LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap;

  MPMoveCommandLineCompleteParameters({
    required this.original,
    required this.modifiedLineSegmentsMap,
  });

  @override
  MPMoveCommandCompleteParametersType get type =>
      MPMoveCommandCompleteParametersType.line;

  @override
  Map<String, dynamic> toMap() {
    return {
      'moveCommandCompleteParametersType': type.name,
      'original': original.toMap(),
      'modifiedLineSegmentsMap': modifiedLineSegmentsMap.map(
        (key, value) => MapEntry(key.toString(), value.toMap()),
      ),
    };
  }

  factory MPMoveCommandLineCompleteParameters.fromMap(
      Map<String, dynamic> map) {
    return MPMoveCommandLineCompleteParameters(
      original: MPMoveCommandLineOriginalParameters.fromMap(map['original']),
      modifiedLineSegmentsMap: LinkedHashMap<int, THLineSegment>.fromEntries(
        (map['modifiedLineSegmentsMap'] as Map<String, dynamic>).entries.map(
              (e) => MapEntry(
                int.parse(e.key),
                THLineSegment.fromMap(e.value),
              ),
            ),
      ),
    );
  }

  factory MPMoveCommandLineCompleteParameters.fromJson(String source) {
    return MPMoveCommandLineCompleteParameters.fromMap(jsonDecode(source));
  }

  @override
  MPMoveCommandLineCompleteParameters copyWith({
    MPMoveCommandLineOriginalParameters? original,
    LinkedHashMap<int, THLineSegment>? modifiedLineSegmentsMap,
  }) {
    return MPMoveCommandLineCompleteParameters(
      original: original ?? this.original,
      modifiedLineSegmentsMap:
          modifiedLineSegmentsMap ?? this.modifiedLineSegmentsMap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveCommandLineCompleteParameters &&
        other.original == original &&
        const DeepCollectionEquality()
            .equals(other.modifiedLineSegmentsMap, modifiedLineSegmentsMap);
  }

  @override
  int get hashCode => Object.hash(
        original,
        Object.hashAll(modifiedLineSegmentsMap.entries),
      );
}
