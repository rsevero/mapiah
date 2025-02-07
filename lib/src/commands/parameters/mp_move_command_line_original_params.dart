part of 'mp_move_command_original_params.dart';

class MPMoveCommandLineOriginalParams extends MPMoveCommandOriginalParams {
  final LinkedHashMap<int, THLineSegment> lineSegmentsMap;

  MPMoveCommandLineOriginalParams({
    required super.mapiahID,
    required this.lineSegmentsMap,
  });

  @override
  MPMoveCommandOriginalParamsType get type =>
      MPMoveCommandOriginalParamsType.line;

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map.addAll({
      'mapiahID': mapiahID,
      'lineSegmentsMap': lineSegmentsMap.map(
        (key, value) => MapEntry(key.toString(), value.toMap()),
      ),
    });

    return map;
  }

  factory MPMoveCommandLineOriginalParams.fromMap(Map<String, dynamic> map) {
    return MPMoveCommandLineOriginalParams(
      mapiahID: map['mapiahID'],
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
    int? mapiahID,
    LinkedHashMap<int, THLineSegment>? lineSegmentsMap,
  }) {
    return MPMoveCommandLineOriginalParams(
      mapiahID: mapiahID ?? this.mapiahID,
      lineSegmentsMap: lineSegmentsMap ?? this.lineSegmentsMap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveCommandLineOriginalParams &&
        other.mapiahID == mapiahID &&
        const DeepCollectionEquality()
            .equals(other.lineSegmentsMap, lineSegmentsMap);
  }

  @override
  int get hashCode => Object.hash(
        mapiahID,
        Object.hashAll(lineSegmentsMap.entries),
      );
}
