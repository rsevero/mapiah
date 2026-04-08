// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_command.dart';

class MPRotateImageInsertConfigCommand extends MPCommand {
  final int imageMPID;
  final THDoublePart fromXX;
  final THDoublePart fromYY;
  final THDoublePart fromRotationCenterDx;
  final THDoublePart fromRotationCenterDy;
  final THDoublePart fromRotationDeg;
  final THDoublePart toXX;
  final THDoublePart toYY;
  final THDoublePart toRotationCenterDx;
  final THDoublePart toRotationCenterDy;
  final THDoublePart toRotationDeg;
  final String fromOriginalLineInTH2File;
  final String toOriginalLineInTH2File;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.moveElements;

  MPRotateImageInsertConfigCommand.forCWJM({
    required this.imageMPID,
    required this.fromXX,
    required this.fromYY,
    required this.fromRotationCenterDx,
    required this.fromRotationCenterDy,
    required this.fromRotationDeg,
    required this.toXX,
    required this.toYY,
    required this.toRotationCenterDx,
    required this.toRotationCenterDy,
    required this.toRotationDeg,
    required this.fromOriginalLineInTH2File,
    required this.toOriginalLineInTH2File,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM();

  @override
  MPCommandType get type => MPCommandType.rotateImageInsertConfig;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;
    final MPRuntimeImageInsertConfigMixin originalImage = th2FileEditController
        .th2File
        .imageByMPID(imageMPID);

    if (originalImage is! MPImageInsertConfig) {
      throw ArgumentError(
        'MPRotateImageInsertConfigCommand only supports MPImageInsertConfig instances.',
      );
    }

    final MPImageInsertConfig modifiedImage;

    switch (originalImage) {
      case MPXVIImageInsertConfig image:
        modifiedImage = image.copyWith(
          xx: toXX,
          yy: toYY,
          rotationCenterDx: toRotationCenterDx,
          rotationCenterDy: toRotationCenterDy,
          rotationDeg: toRotationDeg,
          originalLineInTH2File: toOriginalLineInTH2File,
        );
      case MPRasterImageInsertConfig image:
        modifiedImage = image.copyWith(
          xx: toXX,
          yy: toYY,
          rotationCenterDx: toRotationCenterDx,
          rotationCenterDy: toRotationCenterDy,
          rotationDeg: toRotationDeg,
          originalLineInTH2File: toOriginalLineInTH2File,
        );
      default:
        throw ArgumentError(
          'Unsupported MPImageInsertConfig type: ${originalImage.runtimeType}',
        );
    }

    originalImage.copyRuntimeImageCacheTo(
      targetImage: modifiedImage,
      th2FileEditController: th2FileEditController,
    );

    elementEditController.substituteElement(modifiedImage);
    elementEditController.addOutdatedCloneMPID(imageMPID);
    elementEditController.updateControllersAfterElementEditPartial();
    elementEditController.updateControllersAfterElementEditFinal();
    th2FileEditController.triggerImagesRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPRotateImageInsertConfigCommand oppositeCommand =
        MPRotateImageInsertConfigCommand.forCWJM(
          imageMPID: imageMPID,
          fromXX: toXX,
          fromYY: toYY,
          fromRotationCenterDx: toRotationCenterDx,
          fromRotationCenterDy: toRotationCenterDy,
          fromRotationDeg: toRotationDeg,
          toXX: fromXX,
          toYY: fromYY,
          toRotationCenterDx: fromRotationCenterDx,
          toRotationCenterDy: fromRotationCenterDy,
          toRotationDeg: fromRotationDeg,
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
      'fromRotationCenterDx': fromRotationCenterDx.toMap(),
      'fromRotationCenterDy': fromRotationCenterDy.toMap(),
      'fromRotationDeg': fromRotationDeg.toMap(),
      'toXX': toXX.toMap(),
      'toYY': toYY.toMap(),
      'toRotationCenterDx': toRotationCenterDx.toMap(),
      'toRotationCenterDy': toRotationCenterDy.toMap(),
      'toRotationDeg': toRotationDeg.toMap(),
      'fromOriginalLineInTH2File': fromOriginalLineInTH2File,
      'toOriginalLineInTH2File': toOriginalLineInTH2File,
    });

    return map;
  }

  factory MPRotateImageInsertConfigCommand.fromMap(Map<String, dynamic> map) {
    return MPRotateImageInsertConfigCommand.forCWJM(
      imageMPID: map['imageMPID'],
      fromXX: THDoublePart.fromMap(map['fromXX']),
      fromYY: THDoublePart.fromMap(map['fromYY']),
      fromRotationCenterDx: THDoublePart.fromMap(map['fromRotationCenterDx']),
      fromRotationCenterDy: THDoublePart.fromMap(map['fromRotationCenterDy']),
      fromRotationDeg: THDoublePart.fromMap(map['fromRotationDeg']),
      toXX: THDoublePart.fromMap(map['toXX']),
      toYY: THDoublePart.fromMap(map['toYY']),
      toRotationCenterDx: THDoublePart.fromMap(map['toRotationCenterDx']),
      toRotationCenterDy: THDoublePart.fromMap(map['toRotationCenterDy']),
      toRotationDeg: THDoublePart.fromMap(map['toRotationDeg']),
      fromOriginalLineInTH2File: map['fromOriginalLineInTH2File'],
      toOriginalLineInTH2File: map['toOriginalLineInTH2File'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  @override
  MPRotateImageInsertConfigCommand copyWith({
    int? imageMPID,
    THDoublePart? fromXX,
    THDoublePart? fromYY,
    THDoublePart? fromRotationCenterDx,
    THDoublePart? fromRotationCenterDy,
    THDoublePart? fromRotationDeg,
    THDoublePart? toXX,
    THDoublePart? toYY,
    THDoublePart? toRotationCenterDx,
    THDoublePart? toRotationCenterDy,
    THDoublePart? toRotationDeg,
    String? fromOriginalLineInTH2File,
    String? toOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRotateImageInsertConfigCommand.forCWJM(
      imageMPID: imageMPID ?? this.imageMPID,
      fromXX: fromXX ?? this.fromXX,
      fromYY: fromYY ?? this.fromYY,
      fromRotationCenterDx: fromRotationCenterDx ?? this.fromRotationCenterDx,
      fromRotationCenterDy: fromRotationCenterDy ?? this.fromRotationCenterDy,
      fromRotationDeg: fromRotationDeg ?? this.fromRotationDeg,
      toXX: toXX ?? this.toXX,
      toYY: toYY ?? this.toYY,
      toRotationCenterDx: toRotationCenterDx ?? this.toRotationCenterDx,
      toRotationCenterDy: toRotationCenterDy ?? this.toRotationCenterDy,
      toRotationDeg: toRotationDeg ?? this.toRotationDeg,
      fromOriginalLineInTH2File:
          fromOriginalLineInTH2File ?? this.fromOriginalLineInTH2File,
      toOriginalLineInTH2File:
          toOriginalLineInTH2File ?? this.toOriginalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }
}
