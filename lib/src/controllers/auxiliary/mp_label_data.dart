// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// How a resolved label's text should be boxed. Mirrors Therion's
/// `p_label_mode_*` families: plain labels get a simple white background,
/// while `passage-height` points get one of four decorated containers
/// depending on which of the plus/minus values are present (see
/// `thpoint.cxx`'s `TT_POINT_TYPE_PASSAGE_HEIGHT` handling).
enum MPLabelMode {
  /// Plain text with a white background rectangle (label, remark, date,
  /// altitude, height, dimensions, station).
  plain,

  /// Positive-only passage height: top semicircular box
  /// (`process_uplabel`/`p_label_mode_passageheightpos`).
  passageHeightPos,

  /// Negative-only passage height: bottom semicircular box
  /// (`process_downlabel`/`p_label_mode_passageheightneg`).
  passageHeightNeg,

  /// Both positive and negative passage height: split oval box with a
  /// horizontal divider (`process_updownlabel`/
  /// `p_label_mode_passageheightposneg`).
  passageHeightPosNeg,

  /// Unsigned (distance-between-floor-and-ceiling) passage height: a single
  /// framed value, no curved container
  /// (`p_label_mode_passageheight`).
  passageHeightUnsigned,
}

/// Text resolved from a [THPoint]'s options, ready to hand to
/// `MPLabelPainter.drawTherionLabel`.
class MPLabelData {
  /// Line(s) of text to render. Used for every [mode] except the
  /// passage-height container modes, which use [plusText]/[minusText]
  /// instead.
  final List<String> lines;

  final MPLabelMode mode;

  /// Positive (ceiling) value text, for [MPLabelMode.passageHeightPos] and
  /// [MPLabelMode.passageHeightPosNeg].
  final String? plusText;

  /// Negative (floor) value text, for [MPLabelMode.passageHeightNeg] and
  /// [MPLabelMode.passageHeightPosNeg].
  final String? minusText;

  const MPLabelData.plain(this.lines)
    : mode = MPLabelMode.plain,
      plusText = null,
      minusText = null;

  const MPLabelData.passageHeight({
    required this.mode,
    this.plusText,
    this.minusText,
  }) : lines = const [];
}
