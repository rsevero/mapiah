part of 'mp_command.dart';

class MPRemoveOptionFromElementCommand extends MPCommand {
  final int parentMPID;
  final THCommandOptionType optionType;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeOptionFromElement;

  MPRemoveOptionFromElementCommand.forCWJM({
    required this.optionType,
    required this.parentMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveOptionFromElementCommand({
    required this.optionType,
    required this.parentMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removeOptionFromElement;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.removeOptionFromElement(
      optionType: optionType,
      parentMPID: parentMPID,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THHasOptionsMixin parentElement = th2FileEditController
        .elementEditController
        .getParentElement(parentMPID);

    final THCommandOption? option = parentElement.optionByType(optionType);

    if (option == null) {
      throw StateError(
          'Parent element does not have option of type $optionType');
    }

    final MPSetOptionToElementCommand oppositeCommand =
        MPSetOptionToElementCommand(
      option: option,
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
    THCommandOptionType? optionType,
    int? parentMPID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveOptionFromElementCommand.forCWJM(
      optionType: optionType ?? this.optionType,
      parentMPID: parentMPID ?? this.parentMPID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveOptionFromElementCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveOptionFromElementCommand.forCWJM(
      optionType: THCommandOptionType.values.byName(map['optionType']),
      parentMPID: map['parentMPID'],
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPRemoveOptionFromElementCommand.fromJson(String jsonString) {
    return MPRemoveOptionFromElementCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'optionType': optionType.name,
      'parentMPID': parentMPID,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPRemoveOptionFromElementCommand &&
        other.optionType == optionType &&
        other.parentMPID == parentMPID &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hash(optionType, parentMPID);
}
