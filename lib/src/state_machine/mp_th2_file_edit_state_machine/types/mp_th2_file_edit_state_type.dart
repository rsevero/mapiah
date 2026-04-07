// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of '../mp_th2_file_edit_state.dart';

enum MPTH2FileEditStateType {
  addArea,
  addLine,
  addLineToArea,
  addPoint,
  editSingleLine,
  imageMove,
  imageRotate,
  imageScale,
  movingElements,
  movingEndControlPoints,
  movingSingleControlPoint,
  selectEmptySelection,
  selectionWindowZoom,
  selectNonEmptySelection,
}
