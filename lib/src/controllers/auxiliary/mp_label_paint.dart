// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/controllers/auxiliary/mp_label_data.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/types/th_label_size.dart';
import 'package:material_ui/material_ui.dart';

/// Carries everything [MPLabelPainter.drawTherionLabel] needs to render a
/// text-mode point's label: the resolved text/container [data], where to
/// anchor it, how big to draw it, and the paints for its background box and
/// glyphs. [anchorRadius] and [anchorFill] define the circle that identifies
/// the point's exact position. [backgroundFill] fills every mode's
/// container shape (box, circle, half-capsule, or capsule) purely for
/// on-canvas readability — Therion itself either draws plain labels without
/// any frame, or strokes the passage-height containers with a thin pen and
/// never fills them. [divider] supplies both the stroke color for the
/// passage-height container outlines and the line separating the plus/minus
/// halves of a [MPLabelMode.passageHeightPosNeg] container.
class MPLabelPaint {
  final MPLabelData data;
  final THOptionChoicesAlignType align;
  final THLabelSize size;
  final double anchorRadius;
  final Paint anchorFill;
  final Paint backgroundFill;
  final Paint divider;
  final Color textColor;

  const MPLabelPaint({
    required this.data,
    this.align = THOptionChoicesAlignType.center,
    this.size = THLabelSize.normal,
    required this.anchorRadius,
    required this.anchorFill,
    required this.backgroundFill,
    required this.divider,
    required this.textColor,
  });

  MPLabelPaint copyWith({
    MPLabelData? data,
    THOptionChoicesAlignType? align,
    THLabelSize? size,
    double? anchorRadius,
    Paint? anchorFill,
    Paint? backgroundFill,
    Paint? divider,
    Color? textColor,
  }) {
    return MPLabelPaint(
      data: data ?? this.data,
      align: align ?? this.align,
      size: size ?? this.size,
      anchorRadius: anchorRadius ?? this.anchorRadius,
      anchorFill: anchorFill ?? this.anchorFill,
      backgroundFill: backgroundFill ?? this.backgroundFill,
      divider: divider ?? this.divider,
      textColor: textColor ?? this.textColor,
    );
  }
}
