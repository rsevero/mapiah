// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_data/th_centreline.dart';
import 'package:mapiah/src/elements/th_data/th_data_element.dart';
import 'package:mapiah/src/elements/th_data/th_data_input.dart';
import 'package:mapiah/src/elements/th_data/th_equate.dart';
import 'package:mapiah/src/elements/th_data/th_import.dart';
import 'package:mapiah/src/elements/th_data/th_inline_scrap.dart';
import 'package:mapiah/src/elements/th_data/th_join.dart';
import 'package:mapiah/src/elements/th_data/th_map.dart';
import 'package:mapiah/src/elements/th_data/th_surface.dart';
import 'package:mapiah/src/elements/th_data/th_survey.dart';

/// Root model representing a parsed Therion survey data (.th) file.
class THDataFile {
  String filename = '';

  String encoding = mpDefaultEncoding;

  String lineEnding = MPDirectoryAux.getDefaultLineEnding();

  final List<THDataElement> elements = <THDataElement>[];

  final List<String> parseErrors = <String>[];

  THDataFile({
    this.filename = '',
    this.encoding = mpDefaultEncoding,
    String? lineEnding,
    List<THDataElement>? elements,
    List<String>? parseErrors,
  }) {
    if (lineEnding != null) {
      this.lineEnding = lineEnding;
    }
    if (elements != null) {
      this.elements.addAll(elements);
    }
    if (parseErrors != null) {
      this.parseErrors.addAll(parseErrors);
    }
  }

  /// All top-level surveys.
  List<THSurvey> get surveys =>
      elements.whereType<THSurvey>().toList();

  /// All input directives.
  List<THDataInput> get inputs =>
      elements.whereType<THDataInput>().toList();

  /// All top-level centrelines.
  List<THCentreline> get centrelines =>
      elements.whereType<THCentreline>().toList();

  /// All top-level maps.
  List<THMap> get maps =>
      elements.whereType<THMap>().toList();

  /// All top-level equates.
  List<THEquate> get equates =>
      elements.whereType<THEquate>().toList();

  /// All top-level joins.
  List<THJoin> get joins =>
      elements.whereType<THJoin>().toList();

  /// All top-level imports.
  List<THImport> get imports =>
      elements.whereType<THImport>().toList();

  /// All top-level surfaces.
  List<THSurface> get surfaces =>
      elements.whereType<THSurface>().toList();

  /// All top-level inline scraps.
  List<THInlineScrap> get inlineScraps =>
      elements.whereType<THInlineScrap>().toList();

  /// Whether any element has been modified.
  bool get isDirty => elements.any((THDataElement e) => e.isModified);
}
