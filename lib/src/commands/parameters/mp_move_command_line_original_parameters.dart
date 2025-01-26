part of 'mp_move_command_original_parameters.dart';

class MPMoveCommandLineOriginalParameters
    extends MPMoveCommandOriginalParameters {
  final LinkedHashMap<int, THLineSegment> lineSegmentsMap;

  MPMoveCommandLineOriginalParameters({
    required super.mapiahID,
    required this.lineSegmentsMap,
  });

  @override
  MPMoveCommandOriginalParametersType get type =>
      MPMoveCommandOriginalParametersType.line;

  @override
  Map<String, dynamic> toMap() {
    return {
      'moveCommandOriginalParametersType': type.name,
      'mapiahID': mapiahID,
      'lineSegmentsMap': lineSegmentsMap.map(
        (key, value) => MapEntry(key.toString(), value.toMap()),
      ),
    };
  }

  factory MPMoveCommandLineOriginalParameters.fromMap(
      Map<String, dynamic> map) {
    return MPMoveCommandLineOriginalParameters(
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

  factory MPMoveCommandLineOriginalParameters.fromJson(String source) {
    return MPMoveCommandLineOriginalParameters.fromMap(jsonDecode(source));
  }

  @override
  MPMoveCommandLineOriginalParameters copyWith({
    int? mapiahID,
    LinkedHashMap<int, THLineSegment>? lineSegmentsMap,
  }) {
    return MPMoveCommandLineOriginalParameters(
      mapiahID: mapiahID ?? this.mapiahID,
      lineSegmentsMap: lineSegmentsMap ?? this.lineSegmentsMap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveCommandLineOriginalParameters &&
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
