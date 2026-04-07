// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_command.dart';

class MPMoveImageInsertConfigCommand extends MPCommand {
  final int imageMPID;
  final THDoublePart fromXX;
  final THDoublePart fromYY;
  final THDoublePart toXX;
  final THDoublePart toYY;
  final String fromOriginalLineInTH2File;
  final String toOriginalLineInTH2File;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.moveElements;

  MPMoveImageInsertConfigCommand.forCWJM({
    required this.imageMPID,
    required this.fromXX,
    required this.fromYY,
    required this.toXX,
    required this.toYY,
    required this.fromOriginalLineInTH2File,
    required this.toOriginalLineInTH2File,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM();

  MPMoveImageInsertConfigCommand({
    required this.imageMPID,
    required double fromXX,
    required double fromYY,
    required double toXX,
    required double toYY,
    int? fromXXDecimalPositions,
    int? fromYYDecimalPositions,
    int? toXXDecimalPositions,
    int? toYYDecimalPositions,
    required this.fromOriginalLineInTH2File,
    required this.toOriginalLineInTH2File,
    super.descriptionType = defaultDescriptionType,
  }) : fromXX = THDoublePart(
         value: fromXX,
         decimalPositions: fromXXDecimalPositions,
       ),
       fromYY = THDoublePart(
         value: fromYY,
         decimalPositions: fromYYDecimalPositions,
       ),
       toXX = THDoublePart(value: toXX, decimalPositions: toXXDecimalPositions),
       toYY = THDoublePart(value: toYY, decimalPositions: toYYDecimalPositions),
       super();

  @override
  MPCommandType get type => MPCommandType.moveImageInsertConfig;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;
    final MPRuntimeImageInsertConfigMixin originalImage = th2FileEditController
        .th2File
        .imageByMPID(imageMPID);
    final MPRuntimeImageInsertConfigMixin modifiedImage = originalImage
        .copyWithImageInsertConfigBase(
          xx: toXX,
          yy: toYY,
          originalLineInTH2File: toOriginalLineInTH2File,
        );

    originalImage.copyRuntimeImageCacheTo(
      targetImage: modifiedImage,
      th2FileEditController: th2FileEditController,
    );

    elementEditController.substituteElement(modifiedImage as THElement);
    elementEditController.addOutdatedCloneMPID(imageMPID);
    elementEditController.updateControllersAfterElementEditPartial();
    elementEditController.updateControllersAfterElementEditFinal();
    th2FileEditController.triggerImagesRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPMoveImageInsertConfigCommand oppositeCommand =
        MPMoveImageInsertConfigCommand.forCWJM(
          imageMPID: imageMPID,
          fromXX: toXX,
          fromYY: toYY,
          toXX: fromXX,
          toYY: fromYY,
          fromOriginalLineInTH2File: toOriginalLineInTH2File,
          toOriginalLineInTH2File: fromOriginalLineInTH2File,
          descriptionType: descriptionType,
        );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = super.toMap();

    map.addAll(<String, dynamic>{
      'imageMPID': imageMPID,
      'fromXX': fromXX.toMap(),
      'fromYY': fromYY.toMap(),
      'toXX': toXX.toMap(),
      'toYY': toYY.toMap(),
      'fromOriginalLineInTH2File': fromOriginalLineInTH2File,
      'toOriginalLineInTH2File': toOriginalLineInTH2File,
    });

    return map;
  }

  factory MPMoveImageInsertConfigCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveImageInsertConfigCommand.forCWJM(
      imageMPID: map['imageMPID'],
      fromXX: THDoublePart.fromMap(map['fromXX']),
      fromYY: THDoublePart.fromMap(map['fromYY']),
      toXX: THDoublePart.fromMap(map['toXX']),
      toYY: THDoublePart.fromMap(map['toYY']),
      fromOriginalLineInTH2File: map['fromOriginalLineInTH2File'],
      toOriginalLineInTH2File: map['toOriginalLineInTH2File'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPMoveImageInsertConfigCommand.fromJson(String source) {
    return MPMoveImageInsertConfigCommand.fromMap(jsonDecode(source));
  }

  @override
  MPMoveImageInsertConfigCommand copyWith({
    int? imageMPID,
    THDoublePart? fromXX,
    THDoublePart? fromYY,
    THDoublePart? toXX,
    THDoublePart? toYY,
    String? fromOriginalLineInTH2File,
    String? toOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMoveImageInsertConfigCommand.forCWJM(
      imageMPID: imageMPID ?? this.imageMPID,
      fromXX: fromXX ?? this.fromXX,
      fromYY: fromYY ?? this.fromYY,
      toXX: toXX ?? this.toXX,
      toYY: toYY ?? this.toYY,
      fromOriginalLineInTH2File:
          fromOriginalLineInTH2File ?? this.fromOriginalLineInTH2File,
      toOriginalLineInTH2File:
          toOriginalLineInTH2File ?? this.toOriginalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (!super.equalsBase(other)) {
      return false;
    }

    return other is MPMoveImageInsertConfigCommand &&
        other.imageMPID == imageMPID &&
        other.fromXX == fromXX &&
        other.fromYY == fromYY &&
        other.toXX == toXX &&
        other.toYY == toYY &&
        other.fromOriginalLineInTH2File == fromOriginalLineInTH2File &&
        other.toOriginalLineInTH2File == toOriginalLineInTH2File;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    imageMPID,
    fromXX,
    fromYY,
    toXX,
    toYY,
    fromOriginalLineInTH2File,
    toOriginalLineInTH2File,
  );
}
