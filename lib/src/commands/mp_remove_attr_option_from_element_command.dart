part of 'mp_command.dart';

class MPRemoveAttrOptionFromElementCommand extends MPCommand {
  final int parentMPID;
  final String attrName;
  final String newOriginalLineInTH2File;
  final String currentOriginalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeOptionFromElement;

  MPRemoveAttrOptionFromElementCommand.forCWJM({
    required this.attrName,
    required this.parentMPID,
    required this.newOriginalLineInTH2File,
    required this.currentOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveAttrOptionFromElementCommand({
    required this.attrName,
    required this.parentMPID,
    super.descriptionType = _defaultDescriptionType,
    this.currentOriginalLineInTH2File = '',
    this.newOriginalLineInTH2File = '',
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removeAttrOptionFromElement;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController
        .applyRemoveAttrOptionFromElement(
          attrName: attrName,
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

    final THAttrCommandOption? option = parentElement.attrOptionByName(
      attrName,
    );

    if (option == null) {
      throw StateError(
        'Parent element does not have attr option with name $attrName',
      );
    }

    final MPCommand oppositeCommand = MPSetAttrOptionToElementCommand.forCWJM(
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
  MPRemoveAttrOptionFromElementCommand copyWith({
    String? attrName,
    int? parentMPID,
    String? fromOriginalLineInTH2File,
    String? currentOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveAttrOptionFromElementCommand.forCWJM(
      attrName: attrName ?? this.attrName,
      parentMPID: parentMPID ?? this.parentMPID,
      newOriginalLineInTH2File:
          fromOriginalLineInTH2File ?? this.newOriginalLineInTH2File,
      currentOriginalLineInTH2File:
          currentOriginalLineInTH2File ?? this.currentOriginalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveAttrOptionFromElementCommand.fromMap(
    Map<String, dynamic> map,
  ) {
    return MPRemoveAttrOptionFromElementCommand.forCWJM(
      attrName: map['attrName'],
      parentMPID: map['parentMPID'],
      newOriginalLineInTH2File: map['newOriginalLineInTH2File'],
      currentOriginalLineInTH2File: map['currentOriginalLineInTH2File'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveAttrOptionFromElementCommand.fromJson(String jsonString) {
    return MPRemoveAttrOptionFromElementCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'attrName': attrName,
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

    return other is MPRemoveAttrOptionFromElementCommand &&
        other.attrName == attrName &&
        other.parentMPID == parentMPID &&
        other.newOriginalLineInTH2File == newOriginalLineInTH2File &&
        other.currentOriginalLineInTH2File == currentOriginalLineInTH2File;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    attrName,
    parentMPID,
    newOriginalLineInTH2File,
    currentOriginalLineInTH2File,
  );
}
