part of 'mp_move_command_original_params.dart';

class MPMoveCommandLineOriginalParams extends MPMoveCommandOriginalParams {
  final LinkedHashMap<int, THLineSegment> lineSegmentsMap;

  MPMoveCommandLineOriginalParams({
    required super.mpID,
    required this.lineSegmentsMap,
  });

  @override
  MPMoveCommandOriginalParamsType get type =>
      MPMoveCommandOriginalParamsType.line;

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map.addAll({
      'mpID': mpID,
      'lineSegmentsMap': lineSegmentsMap.map(
        (key, value) => MapEntry(key.toString(), value.toMap()),
      ),
    });

    return map;
  }

  factory MPMoveCommandLineOriginalParams.fromMap(Map<String, dynamic> map) {
    return MPMoveCommandLineOriginalParams(
      mpID: map['mpID'],
      lineSegmentsMap: LinkedHashMap<int, THLineSegment>.fromEntries(
        (map['lineSegmentsMap'] as Map<String, dynamic>).entries.map(
              (e) => MapEntry(
                int.parse(e.key),
                THLineSegment.fromMap(e.value),
              ),
            ),
      ),
    );
  }

  factory MPMoveCommandLineOriginalParams.fromJson(String source) {
    return MPMoveCommandLineOriginalParams.fromMap(jsonDecode(source));
  }

  @override
  MPMoveCommandLineOriginalParams copyWith({
    int? mpID,
    LinkedHashMap<int, THLineSegment>? lineSegmentsMap,
  }) {
    return MPMoveCommandLineOriginalParams(
      mpID: mpID ?? this.mpID,
      lineSegmentsMap: lineSegmentsMap ?? this.lineSegmentsMap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveCommandLineOriginalParams &&
        other.mpID == mpID &&
        const DeepCollectionEquality()
            .equals(other.lineSegmentsMap, lineSegmentsMap);
  }

  @override
  int get hashCode => Object.hash(
        mpID,
        Object.hashAll(lineSegmentsMap.entries),
      );
}
