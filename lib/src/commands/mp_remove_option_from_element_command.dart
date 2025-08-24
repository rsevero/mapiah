part of 'mp_command.dart';

class MPRemoveOptionFromElementCommand extends MPCommand {
  final int parentMPID;
  final THCommandOptionType optionType;
  final String newOriginalLineInTH2File;
  final String currentOriginalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeOptionFromElement;

  MPRemoveOptionFromElementCommand.forCWJM({
    required this.optionType,
    required this.parentMPID,
    required this.newOriginalLineInTH2File,
    required this.currentOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveOptionFromElementCommand({
    required this.optionType,
    required this.parentMPID,
    super.descriptionType = _defaultDescriptionType,
    this.currentOriginalLineInTH2File = '',
    this.newOriginalLineInTH2File = '',
  }) : super();

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
      newOriginalLineInTH2File: keepOriginalLineTH2File
          ? currentOriginalLineInTH2File
          : newOriginalLineInTH2File,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THHasOptionsMixin parentElement = th2FileEditController.thFile
        .hasOptionByMPID(parentMPID);

    final THCommandOption? option = parentElement.optionByType(optionType);

    if (option == null) {
      throw StateError(
        'Parent element does not have option of type $optionType',
      );
    }

    final MPCommand oppositeCommand = MPSetOptionToElementCommand.forCWJM(
      option: option,
      newOriginalLineInTH2File: currentOriginalLineInTH2File,
      currentOriginalLineInTH2File: newOriginalLineInTH2File,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPRemoveOptionFromElementCommand copyWith({
    THCommandOptionType? attrName,
    int? parentMPID,
    String? newOriginalLineInTH2File,
    String? currentOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveOptionFromElementCommand.forCWJM(
      optionType: attrName ?? this.optionType,
      parentMPID: parentMPID ?? this.parentMPID,
      newOriginalLineInTH2File:
          newOriginalLineInTH2File ?? this.newOriginalLineInTH2File,
      currentOriginalLineInTH2File:
          currentOriginalLineInTH2File ?? this.currentOriginalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveOptionFromElementCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveOptionFromElementCommand.forCWJM(
      optionType: THCommandOptionType.values.byName(map['optionType']),
      parentMPID: map['parentMPID'],
      newOriginalLineInTH2File: map['newOriginalLineInTH2File'],
      currentOriginalLineInTH2File: map['currentOriginalLineInTH2File'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
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
      'newOriginalLineInTH2File': newOriginalLineInTH2File,
      'currentOriginalLineInTH2File': currentOriginalLineInTH2File,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveOptionFromElementCommand &&
        other.optionType == optionType &&
        other.parentMPID == parentMPID &&
        other.newOriginalLineInTH2File == newOriginalLineInTH2File &&
        other.currentOriginalLineInTH2File == currentOriginalLineInTH2File;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        optionType,
        parentMPID,
        newOriginalLineInTH2File,
        currentOriginalLineInTH2File,
      );
}
