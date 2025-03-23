part of 'mp_command.dart';

class MPAddOptionToElementCommand extends MPCommand {
  final THCommandOption option;
  final int parentMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addOptionToElement;

  MPAddOptionToElementCommand.forCWJM({
    required this.option,
    required this.parentMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddOptionToElementCommand({
    required this.option,
    required this.parentMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.addOptionToElement;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final THElement parentElement =
        th2FileEditController.thFile.elementByMPID(parentMPID);

    if (parentElement is! THHasOptionsMixin) {
      return;
    }

    parentElement.addUpdateOption(option);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPRemoveOptionFromElementCommand oppositeCommand =
        MPRemoveOptionFromElementCommand(
      optionType: option.type,
      parentMPID: parentMPID,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    THCommandOption? option,
    int? parentMPID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddOptionToElementCommand.forCWJM(
      option: option ?? this.option,
      parentMPID: parentMPID ?? this.parentMPID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddOptionToElementCommand.fromMap(Map<String, dynamic> map) {
    return MPAddOptionToElementCommand.forCWJM(
      option: THCommandOption.fromMap(map['option']),
      parentMPID: map['parentMPID'],
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPAddOptionToElementCommand.fromJson(String jsonString) {
    return MPAddOptionToElementCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'option': option.toMap(),
      'parentMPID': parentMPID,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPAddOptionToElementCommand &&
        other.option == option &&
        other.parentMPID == parentMPID &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hash(option, parentMPID);
}
