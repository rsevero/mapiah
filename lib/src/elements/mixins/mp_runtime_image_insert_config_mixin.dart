// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of '../th_element.dart';

mixin MPRuntimeImageInsertConfigMixin on THElement, MPBoundingBoxMixin {
  String get filename;

  String get format;

  THDoublePart get xx;

  THDoublePart get yy;

  bool get isVisible;

  set isVisible(bool isVisible);

  @override
  Rect? getBoundingBox(TH2FileEditController th2FileEditController);

  MPRuntimeImageInsertConfigMixin copyWithImageInsertConfigBase({
    String? filename,
    THDoublePart? xx,
    THDoublePart? yy,
    bool? isVisible,
    String? originalLineInTH2File,
  });

  bool get isXVI => format == mpImageInsertFormatXVI;

  MPRuntimeXVIImageInsertConfigMixin? get asXVIImage => null;

  MPRuntimeRasterImageInsertConfigMixin? get asRasterImage => null;

  void copyRuntimeImageCacheTo({
    required MPRuntimeImageInsertConfigMixin targetImage,
    required TH2FileEditController th2FileEditController,
  }) {
    final MPRuntimeXVIImageInsertConfigMixin? sourceXVIImage = asXVIImage;
    final MPRuntimeXVIImageInsertConfigMixin? targetXVIImage =
        targetImage.asXVIImage;

    if ((sourceXVIImage != null) && (targetXVIImage != null)) {
      targetXVIImage.setXVIFile(
        sourceXVIImage.getXVIFile(th2FileEditController),
      );
    }

    final MPRuntimeRasterImageInsertConfigMixin? sourceRasterImage =
        asRasterImage;
    final MPRuntimeRasterImageInsertConfigMixin? targetRasterImage =
        targetImage.asRasterImage;

    if ((sourceRasterImage != null) && (targetRasterImage != null)) {
      targetRasterImage.setRasterImage(sourceRasterImage.decodedRasterImage);
    }
  }
}

mixin MPRuntimeXVIImageInsertConfigMixin on MPRuntimeImageInsertConfigMixin {
  XVIFile? getXVIFile(TH2FileEditController th2FileEditController);

  void setXVIFile(XVIFile? xviFile);

  String get xviRoot;

  double get xviRootedXX;

  double get xviRootedYY;

  bool get isGridVisible;

  set isGridVisible(bool isGridVisible);
}

mixin MPRuntimeRasterImageInsertConfigMixin on MPRuntimeImageInsertConfigMixin {
  Future<ui.Image>? getRasterImageFrameInfo(
    TH2FileEditController th2FileEditController,
  );

  ui.Image? get decodedRasterImage;

  void setRasterImage(ui.Image? image);
}
