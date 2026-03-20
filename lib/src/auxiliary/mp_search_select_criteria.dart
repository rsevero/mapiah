// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';

enum MPOptionSearchState { undefined, set, unset }

class MPSearchSelectSectionCriteria {
  bool enabled = false;
  bool selectAll = false;
  bool byID = false;
  bool bySubtype = false;
  bool byType = false;
  bool byOption = false;
  bool byLineSegmentOption = false;

  String idSearchText = '';
  String subtypeSearchText = '';

  final Set<THPointType> selectedPointTypes = {};
  final Set<THLineType> selectedLineTypes = {};
  final Set<THAreaType> selectedAreaTypes = {};
  final Set<String> selectedUnknownTypes = {};
  final Set<String> selectedSubtypes = {};
  final Map<THCommandOptionType, MPOptionSearchState> optionStates = {};
  final Map<THCommandOptionType, MPOptionSearchState> lineSegmentOptionStates =
      {};

  void reset() {
    enabled = false;
    selectAll = false;
    byID = false;
    bySubtype = false;
    byType = false;
    byOption = false;
    byLineSegmentOption = false;
    idSearchText = '';
    subtypeSearchText = '';
    selectedPointTypes.clear();
    selectedLineTypes.clear();
    selectedAreaTypes.clear();
    selectedUnknownTypes.clear();
    selectedSubtypes.clear();
    optionStates.clear();
    lineSegmentOptionStates.clear();
  }

  void setAllEnabled() {
    selectAll = true;
    byID = false;
    bySubtype = false;
    byType = false;
    byOption = false;
    byLineSegmentOption = false;
  }

  void disableAll() {
    selectAll = false;
  }
}

class MPSearchSelectCriteria {
  final MPSearchSelectSectionCriteria points = MPSearchSelectSectionCriteria();
  final MPSearchSelectSectionCriteria lines = MPSearchSelectSectionCriteria();
  final MPSearchSelectSectionCriteria areas = MPSearchSelectSectionCriteria();

  void reset() {
    points.reset();
    lines.reset();
    areas.reset();
  }
}
