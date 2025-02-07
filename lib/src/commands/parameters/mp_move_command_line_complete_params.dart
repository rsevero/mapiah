part of 'mp_move_command_complete_params.dart';

class MPMoveCommandLineCompleteParams extends MPMoveCommandCompleteParams {
  final MPMoveCommandLineOriginalParams original;
  final LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap;

  MPMoveCommandLineCompleteParams({
    required this.original,
    required this.modifiedLineSegmentsMap,
  });

  @override
  MPMoveCommandCompleteParamsType get type =>
      MPMoveCommandCompleteParamsType.line;

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map.addAll({
      'original': original.toMap(),
      'modifiedLineSegmentsMap': modifiedLineSegmentsMap.map(
        (key, value) => MapEntry(key.toString(), value.toMap()),
      ),
    });

    return map;
  }

  factory MPMoveCommandLineCompleteParams.fromMap(Map<String, dynamic> map) {
    return MPMoveCommandLineCompleteParams(
      original: MPMoveCommandLineOriginalParams.fromMap(map['original']),
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

  factory MPMoveCommandLineCompleteParams.fromJson(String source) {
    return MPMoveCommandLineCompleteParams.fromMap(jsonDecode(source));
  }

  @override
  MPMoveCommandLineCompleteParams copyWith({
    MPMoveCommandLineOriginalParams? original,
    LinkedHashMap<int, THLineSegment>? modifiedLineSegmentsMap,
  }) {
    return MPMoveCommandLineCompleteParams(
      original: original ?? this.original,
      modifiedLineSegmentsMap:
          modifiedLineSegmentsMap ?? this.modifiedLineSegmentsMap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveCommandLineCompleteParams &&
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
