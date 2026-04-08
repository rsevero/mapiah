// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_command.dart';

class MPScaleImageInsertConfigCommand extends MPCommand {
  final int imageMPID;
  final THDoublePart fromXX;
  final THDoublePart fromYY;
  final THDoublePart fromXScale;
  final THDoublePart fromYScale;
  final THDoublePart toXX;
  final THDoublePart toYY;
  final THDoublePart toXScale;
  final THDoublePart toYScale;
  final String fromOriginalLineInTH2File;
  final String toOriginalLineInTH2File;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.moveElements;

  MPScaleImageInsertConfigCommand.forCWJM({
    required this.imageMPID,
    required this.fromXX,
    required this.fromYY,
    required this.fromXScale,
    required this.fromYScale,
    required this.toXX,
    required this.toYY,
    required this.toXScale,
    required this.toYScale,
    required this.fromOriginalLineInTH2File,
    required this.toOriginalLineInTH2File,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM();

  @override
  MPCommandType get type => MPCommandType.scaleImageInsertConfig;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;
    final MPRuntimeImageInsertConfigMixin originalImage = th2FileEditController
        .th2File
        .imageByMPID(imageMPID);

    if (originalImage is! MPImageInsertConfig) {
      throw ArgumentError(
        'MPScaleImageInsertConfigCommand only supports MPImageInsertConfig instances.',
      );
    }

    final MPImageInsertConfig modifiedImage = originalImage
        .copyWithImageTransform(
          xx: toXX,
          yy: toYY,
          xScale: toXScale,
          yScale: toYScale,
          originalLineInTH2File: toOriginalLineInTH2File,
        );

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
    final MPScaleImageInsertConfigCommand oppositeCommand =
        MPScaleImageInsertConfigCommand.forCWJM(
          imageMPID: imageMPID,
          fromXX: toXX,
          fromYY: toYY,
          fromXScale: toXScale,
          fromYScale: toYScale,
          toXX: fromXX,
          toYY: fromYY,
          toXScale: fromXScale,
          toYScale: fromYScale,
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
      'fromXScale': fromXScale.toMap(),
      'fromYScale': fromYScale.toMap(),
      'toXX': toXX.toMap(),
      'toYY': toYY.toMap(),
      'toXScale': toXScale.toMap(),
      'toYScale': toYScale.toMap(),
      'fromOriginalLineInTH2File': fromOriginalLineInTH2File,
      'toOriginalLineInTH2File': toOriginalLineInTH2File,
    });

    return map;
  }

  factory MPScaleImageInsertConfigCommand.fromMap(Map<String, dynamic> map) {
    return MPScaleImageInsertConfigCommand.forCWJM(
      imageMPID: map['imageMPID'],
      fromXX: THDoublePart.fromMap(map['fromXX']),
      fromYY: THDoublePart.fromMap(map['fromYY']),
      fromXScale: THDoublePart.fromMap(map['fromXScale']),
      fromYScale: THDoublePart.fromMap(map['fromYScale']),
      toXX: THDoublePart.fromMap(map['toXX']),
      toYY: THDoublePart.fromMap(map['toYY']),
      toXScale: THDoublePart.fromMap(map['toXScale']),
      toYScale: THDoublePart.fromMap(map['toYScale']),
      fromOriginalLineInTH2File: map['fromOriginalLineInTH2File'],
      toOriginalLineInTH2File: map['toOriginalLineInTH2File'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  @override
  MPScaleImageInsertConfigCommand copyWith({
    int? imageMPID,
    THDoublePart? fromXX,
    THDoublePart? fromYY,
    THDoublePart? fromXScale,
    THDoublePart? fromYScale,
    THDoublePart? toXX,
    THDoublePart? toYY,
    THDoublePart? toXScale,
    THDoublePart? toYScale,
    String? fromOriginalLineInTH2File,
    String? toOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPScaleImageInsertConfigCommand.forCWJM(
      imageMPID: imageMPID ?? this.imageMPID,
      fromXX: fromXX ?? this.fromXX,
      fromYY: fromYY ?? this.fromYY,
      fromXScale: fromXScale ?? this.fromXScale,
      fromYScale: fromYScale ?? this.fromYScale,
      toXX: toXX ?? this.toXX,
      toYY: toYY ?? this.toYY,
      toXScale: toXScale ?? this.toXScale,
      toYScale: toYScale ?? this.toYScale,
      fromOriginalLineInTH2File:
          fromOriginalLineInTH2File ?? this.fromOriginalLineInTH2File,
      toOriginalLineInTH2File:
          toOriginalLineInTH2File ?? this.toOriginalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }
}
