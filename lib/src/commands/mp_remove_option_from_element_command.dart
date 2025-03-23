part of 'mp_command.dart';

class MPRemoveOptionFromElementCommand extends MPCommand {
  final THCommandOptionType optionType;
  final int parentMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeOptionFromElement;
  THHasOptionsMixin? _parentElement;

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
    if (_parentElement == null) {
      final THElement parentElement =
          th2FileEditController.thFile.elementByMPID(parentMPID);

      if (parentElement is! THHasOptionsMixin) {
        return;
      }

      _parentElement = parentElement;
    }

    _parentElement!.removeOption(optionType);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    if (_parentElement == null) {
      final THElement parentElement =
          th2FileEditController.thFile.elementByMPID(parentMPID);

      if (parentElement is! THHasOptionsMixin) {
        throw StateError('Parent element is not an option element');
      }

      _parentElement = parentElement;
    }

    final THCommandOption? option = _parentElement!.optionByType(optionType);

    if (option == null) {
      throw StateError('Parent element does not have the option');
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
