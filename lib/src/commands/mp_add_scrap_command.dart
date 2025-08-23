part of 'mp_command.dart';

class MPAddScrapCommand extends MPCommand {
  final THScrap newScrap;
  late final Iterable<THElement> scrapChildren;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addScrap;

  MPAddScrapCommand.forCWJM({
    required this.newScrap,
    required this.scrapChildren,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddScrapCommand({
    required this.newScrap,
    required this.scrapChildren,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.addScrap;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyAddScrap(
      newScrap: newScrap,
      scrapChildren: scrapChildren,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemoveScrapCommand(
      scrapMPID: newScrap.mpID,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPAddScrapCommand copyWith({
    THScrap? newScrap,
    Iterable<THElement>? scrapChildren,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddScrapCommand.forCWJM(
      newScrap: newScrap ?? this.newScrap,
      scrapChildren: scrapChildren ?? this.scrapChildren,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddScrapCommand.fromMap(Map<String, dynamic> map) {
    return MPAddScrapCommand.forCWJM(
      newScrap: THScrap.fromMap(map['newScrap']),
      scrapChildren: List<THElement>.from(
        map['scrapChildren'].map((x) => THElement.fromMap(x)),
      ),
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPAddScrapCommand.fromJson(String source) {
    return MPAddScrapCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'newScrap': newScrap.toMap(),
      'scrapChildren': scrapChildren.map((e) => e.toMap()),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPAddScrapCommand &&
        other.newScrap == newScrap &&
        other.scrapChildren == scrapChildren &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hash(newScrap, scrapChildren);
}
