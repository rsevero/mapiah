part of 'mp_command.dart';

class MPRemoveOptionFromElementCommand extends MPCommand {
  final int parentMPID;
  final THCommandOptionType optionType;
  final String originalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeOptionFromElement;

  MPRemoveOptionFromElementCommand.forCWJM({
    required this.optionType,
    required this.parentMPID,
    required this.originalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveOptionFromElementCommand({
    required this.optionType,
    required this.parentMPID,
    super.descriptionType = _defaultDescriptionType,
  })  : originalLineInTH2File = '',
        super();

  @override
  MPCommandType get type => MPCommandType.removeOptionFromElement;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyRemoveOptionFromElement(
      optionType: optionType,
      parentMPID: parentMPID,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THHasOptionsMixin parentElement =
        th2FileEditController.thFile.hasOptionByMPID(parentMPID);

    final THCommandOption? option = parentElement.optionByType(optionType);

    if (option == null) {
      throw StateError(
          'Parent element does not have option of type $optionType');
    }

    final MPSetOptionToElementCommand oppositeCommand =
        MPSetOptionToElementCommand.forCWJM(
      option: option,
      originalLineInTH2File: th2FileEditController.thFile
          .elementByMPID(option.parentMPID)
          .originalLineInTH2File,
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
    String? originalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveOptionFromElementCommand.forCWJM(
      optionType: optionType ?? this.optionType,
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveOptionFromElementCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveOptionFromElementCommand.forCWJM(
      optionType: THCommandOptionType.values.byName(map['optionType']),
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
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
      'originalLineInTH2File': originalLineInTH2File,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPRemoveOptionFromElementCommand &&
        other.optionType == optionType &&
        other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        optionType,
        parentMPID,
        originalLineInTH2File,
      );
}
