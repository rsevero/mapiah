// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of '../th_element.dart';

mixin MPRuntimeImageInsertConfigMixin on THElement {
  String get filename;

  String get format;

  bool get isVisible;

  set isVisible(bool isVisible);

  bool get isXVI => format == mpImageInsertFormatXVI;

  MPRuntimeXVIImageInsertConfigMixin? get asXVIImage => null;

  MPRuntimeRasterImageInsertConfigMixin? get asRasterImage => null;
}

mixin MPRuntimeXVIImageInsertConfigMixin on MPRuntimeImageInsertConfigMixin {
  XVIFile? getXVIFile(TH2FileEditController th2FileEditController);

  String get xviRoot;

  double get xviRootedXX;

  double get xviRootedYY;

  bool get isGridVisible;

  set isGridVisible(bool isGridVisible);
}

mixin MPRuntimeRasterImageInsertConfigMixin on MPRuntimeImageInsertConfigMixin {
  THDoublePart get xx;

  THDoublePart get yy;

  Future<ui.Image>? getRasterImageFrameInfo(
    TH2FileEditController th2FileEditController,
  );
}
