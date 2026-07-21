// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/auxiliary/mp_label_data.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/types/th_label_size.dart';

/// Carries everything [MPLabelPainter.drawTherionLabel] needs to render a
/// text-mode point's label: the resolved text/container [data], where to
/// anchor it, how big to draw it, and the paints for its background box and
/// glyphs.
class MPLabelPaint {
  final MPLabelData data;
  final THOptionChoicesAlignType align;
  final THLabelSize size;
  final Paint backgroundFill;
  final Paint backgroundBorder;
  final Color textColor;

  const MPLabelPaint({
    required this.data,
    this.align = THOptionChoicesAlignType.center,
    this.size = THLabelSize.normal,
    required this.backgroundFill,
    required this.backgroundBorder,
    required this.textColor,
  });

  MPLabelPaint copyWith({
    MPLabelData? data,
    THOptionChoicesAlignType? align,
    THLabelSize? size,
    Paint? backgroundFill,
    Paint? backgroundBorder,
    Color? textColor,
  }) {
    return MPLabelPaint(
      data: data ?? this.data,
      align: align ?? this.align,
      size: size ?? this.size,
      backgroundFill: backgroundFill ?? this.backgroundFill,
      backgroundBorder: backgroundBorder ?? this.backgroundBorder,
      textColor: textColor ?? this.textColor,
    );
  }
}
