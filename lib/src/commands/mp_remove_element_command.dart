part of 'mp_command.dart';

class MPRemoveElementCommand extends MPCommand {
  final int elementMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeElement;

  MPRemoveElementCommand.forCWJM({
    required this.elementMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveElementCommand({
    required this.elementMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removeElement;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final THElement originalElement = thFile.elementByMPID(elementMPID);
    final MPCommand addElementCommand = MPAddElementCommand.fromExisting(
      existingElement: originalElement,
      thFile: thFile,
      descriptionType: descriptionType,
    );

    _undoRedoInfo = {'addElementCommand': addElementCommand};
  }

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyRemoveElementByMPID(
      elementMPID,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand =
        _undoRedoInfo!['addElementCommand'] as MPCommand;

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPRemoveElementCommand copyWith({
    int? elementMPID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveElementCommand.forCWJM(
      elementMPID: elementMPID ?? this.elementMPID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveElementCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveElementCommand.forCWJM(
      elementMPID: map['elementMPID'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveElementCommand.fromJson(String source) {
    return MPRemoveElementCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'elementMPID': elementMPID});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveElementCommand && other.elementMPID == elementMPID;
  }

  @override
  int get hashCode => super.hashCode ^ elementMPID.hashCode;
}
