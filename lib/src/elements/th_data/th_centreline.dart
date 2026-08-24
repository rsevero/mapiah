// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_data/th_data_element.dart';

/// Represents an individual survey shot reading in a centreline block.
class THCentrelineShot {
  final String fromStation;

  final String toStation;

  final double length;

  final double? bearing;

  final double? gradient;

  final List<String> flags = <String>[];

  final String originalLine;

  THCentrelineShot({
    required this.fromStation,
    required this.toStation,
    required this.length,
    this.bearing,
    this.gradient,
    List<String>? flags,
    this.originalLine = '',
  }) {
    if (flags != null) {
      this.flags.addAll(flags);
    }
  }
}

/// Represents a  block in a .th file.
class THCentreline extends THDataElement {
  final String? id;

  final String? date;

  final List<String> team = <String>[];

  final List<THCentrelineShot> shots = <THCentrelineShot>[];

  final List<String> rawDataLines = <String>[];

  final Map<String, dynamic> parsedOptions = <String, dynamic>{};

  THCentreline({
    this.id,
    this.date,
    List<String>? team,
    List<THCentrelineShot>? shots,
    List<String>? rawDataLines,
    Map<String, dynamic>? parsedOptions,
    super.lineNumber,
    super.originalLine,
    super.isModified,
  }) {
    if (team != null) {
      this.team.addAll(team);
    }
    if (shots != null) {
      this.shots.addAll(shots);
    }
    if (rawDataLines != null) {
      this.rawDataLines.addAll(rawDataLines);
    }
    if (parsedOptions != null) {
      this.parsedOptions.addAll(parsedOptions);
    }
  }
}
