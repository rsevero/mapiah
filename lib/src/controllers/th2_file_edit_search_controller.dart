// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_search_select_criteria.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_search_controller.g.dart';

class TH2FileEditSearchController = TH2FileEditSearchControllerBase
    with _$TH2FileEditSearchController;

abstract class TH2FileEditSearchControllerBase with Store {
  @readonly
  TH2File _th2File;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditSearchControllerBase(this._th2FileEditController)
    : _th2File = _th2FileEditController.th2File;

  final MPSearchSelectCriteria criteria = MPSearchSelectCriteria();

  @readonly
  int _matchingCount = 0;

  void resetCriteria() {
    criteria.reset();
    _matchingCount = 0;
  }

  void updateMatchingCount() {
    final List<THElement> matching = getMatchingElements();

    _matchingCount = matching.length;
  }

  List<THElement> getMatchingElements() {
    if (_th2FileEditController.activeScrapID <= 0) {
      return [];
    }

    final THScrap scrap = _th2File.scrapByMPID(
      _th2FileEditController.activeScrapID,
    );
    final List<THElement> result = [];

    if (criteria.points.enabled) {
      final Iterable<THPoint> points = scrap.getPoints(_th2File);

      result.addAll(_filterPoints(points, criteria.points));
    }

    if (criteria.lines.enabled) {
      final Iterable<THLine> lines = scrap.getLines(_th2File);

      result.addAll(_filterLines(lines, criteria.lines));
    }

    if (criteria.areas.enabled) {
      final Iterable<THArea> areas = scrap.getAreas(_th2File);

      result.addAll(_filterAreas(areas, criteria.areas));
    }

    return result;
  }

  List<THPoint> _filterPoints(
    Iterable<THPoint> points,
    MPSearchSelectSectionCriteria section,
  ) {
    if (section.selectAll) {
      return points.toList();
    }

    final List<THPoint> result = [];

    for (final THPoint point in points) {
      if (_matchesPoint(point, section)) {
        result.add(point);
      }
    }

    return result;
  }

  List<THLine> _filterLines(
    Iterable<THLine> lines,
    MPSearchSelectSectionCriteria section,
  ) {
    if (section.selectAll) {
      return lines.toList();
    }

    final List<THLine> result = [];

    for (final THLine line in lines) {
      if (_matchesLine(line, section)) {
        result.add(line);
      }
    }

    return result;
  }

  List<THArea> _filterAreas(
    Iterable<THArea> areas,
    MPSearchSelectSectionCriteria section,
  ) {
    if (section.selectAll) {
      return areas.toList();
    }

    final List<THArea> result = [];

    for (final THArea area in areas) {
      if (_matchesArea(area, section)) {
        result.add(area);
      }
    }

    return result;
  }

  bool _matchesPoint(THPoint point, MPSearchSelectSectionCriteria section) {
    bool hasAnyCriteria = false;

    if (section.byType) {
      hasAnyCriteria = true;

      final bool matchesKnownType = section.selectedPointTypes.contains(
        point.pointType,
      );
      final bool matchesUnknownType =
          (point.unknownPLAType.isNotEmpty) &&
          section.selectedUnknownTypes.contains(point.unknownPLAType);

      if (!matchesKnownType && !matchesUnknownType) {
        return false;
      }
    }

    if (section.byID) {
      hasAnyCriteria = true;

      if (!_matchesID(point, section.idSearchText)) {
        return false;
      }
    }

    if (section.bySubtype) {
      hasAnyCriteria = true;

      if (!_matchesSubtype(point, section)) {
        return false;
      }
    }

    if (section.byOption) {
      hasAnyCriteria = true;

      if (!_matchesOptions(point, section)) {
        return false;
      }
    }

    return hasAnyCriteria;
  }

  bool _matchesLine(THLine line, MPSearchSelectSectionCriteria section) {
    bool hasAnyCriteria = false;

    if (section.byType) {
      hasAnyCriteria = true;

      final bool matchesKnownType = section.selectedLineTypes.contains(
        line.lineType,
      );
      final bool matchesUnknownType =
          (line.unknownPLAType.isNotEmpty) &&
          section.selectedUnknownTypes.contains(line.unknownPLAType);

      if (!matchesKnownType && !matchesUnknownType) {
        return false;
      }
    }

    if (section.byID) {
      hasAnyCriteria = true;

      if (!_matchesID(line, section.idSearchText)) {
        return false;
      }
    }

    if (section.bySubtype) {
      hasAnyCriteria = true;

      if (!_matchesSubtype(line, section)) {
        return false;
      }
    }

    if (section.byOption) {
      hasAnyCriteria = true;

      if (!_matchesOptions(line, section)) {
        return false;
      }
    }

    if (section.byLineSegmentOption) {
      hasAnyCriteria = true;

      if (!_matchesLineSegmentOptions(line, section)) {
        return false;
      }
    }

    return hasAnyCriteria;
  }

  bool _matchesArea(THArea area, MPSearchSelectSectionCriteria section) {
    bool hasAnyCriteria = false;

    if (section.byType) {
      hasAnyCriteria = true;

      final bool matchesKnownType = section.selectedAreaTypes.contains(
        area.areaType,
      );
      final bool matchesUnknownType =
          (area.unknownPLAType.isNotEmpty) &&
          section.selectedUnknownTypes.contains(area.unknownPLAType);

      if (!matchesKnownType && !matchesUnknownType) {
        return false;
      }
    }

    if (section.byID) {
      hasAnyCriteria = true;

      if (!_matchesID(area, section.idSearchText)) {
        return false;
      }
    }

    if (section.bySubtype) {
      hasAnyCriteria = true;

      if (!_matchesSubtype(area, section)) {
        return false;
      }
    }

    if (section.byOption) {
      hasAnyCriteria = true;

      if (!_matchesOptions(area, section)) {
        return false;
      }
    }

    return hasAnyCriteria;
  }

  bool _matchesID(THElement element, String searchText) {
    if (searchText.isEmpty) {
      return true;
    }

    final String? elementID = MPCommandOptionAux.getID(element);

    if (elementID == null) {
      return false;
    }

    return elementID.toLowerCase().contains(searchText.toLowerCase());
  }

  bool _matchesSubtype(
    THElement element,
    MPSearchSelectSectionCriteria section,
  ) {
    final String? elementSubtype = MPCommandOptionAux.getSubtype(element);

    if (section.selectedSubtypes.isNotEmpty) {
      if (elementSubtype == null) {
        if (section.subtypeSearchText.isEmpty) {
          return false;
        }
      } else if (!section.selectedSubtypes.contains(elementSubtype)) {
        if (section.subtypeSearchText.isEmpty) {
          return false;
        }
      } else {
        return true;
      }
    }

    if (section.subtypeSearchText.isNotEmpty) {
      if (elementSubtype == null) {
        return false;
      }

      return elementSubtype.toLowerCase().contains(
        section.subtypeSearchText.toLowerCase(),
      );
    }

    return true;
  }

  bool _matchesLineSegmentOptions(
    THLine line,
    MPSearchSelectSectionCriteria section,
  ) {
    final List<THLineSegment> segments = line.getLineSegments(_th2File);

    for (final MapEntry<THCommandOptionType, MPOptionSearchState> entry
        in section.lineSegmentOptionStates.entries) {
      if (entry.value == MPOptionSearchState.undefined) {
        continue;
      }

      final bool anySegmentHasOption = segments.any(
        (THLineSegment segment) => segment.hasOption(entry.key),
      );

      if (entry.value == MPOptionSearchState.set) {
        if (!anySegmentHasOption) {
          return false;
        }
      } else if (entry.value == MPOptionSearchState.unset) {
        if (anySegmentHasOption) {
          return false;
        }
      }
    }

    return true;
  }

  bool _matchesOptions(
    THElement element,
    MPSearchSelectSectionCriteria section,
  ) {
    if (element is! THHasOptionsMixin) {
      return false;
    }

    for (final MapEntry<THCommandOptionType, MPOptionSearchState> entry
        in section.optionStates.entries) {
      if (entry.value == MPOptionSearchState.undefined) {
        continue;
      }

      final bool elementHasOption = element.hasOption(entry.key);

      if (entry.value == MPOptionSearchState.set) {
        if (!elementHasOption) {
          return false;
        }
      } else if (entry.value == MPOptionSearchState.unset) {
        if (elementHasOption) {
          return false;
        }
      }
    }

    return true;
  }

  Set<String> getUnknownPointTypesInScrap() {
    if (_th2FileEditController.activeScrapID <= 0) {
      return {};
    }

    final THScrap scrap = _th2File.scrapByMPID(
      _th2FileEditController.activeScrapID,
    );
    final Set<String> unknownTypes = {};

    for (final THPoint point in scrap.getPoints(_th2File)) {
      if (point.unknownPLAType.isNotEmpty) {
        unknownTypes.add(point.unknownPLAType);
      }
    }

    return unknownTypes;
  }

  Set<String> getUnknownLineTypesInScrap() {
    if (_th2FileEditController.activeScrapID <= 0) {
      return {};
    }

    final THScrap scrap = _th2File.scrapByMPID(
      _th2FileEditController.activeScrapID,
    );
    final Set<String> unknownTypes = {};

    for (final THLine line in scrap.getLines(_th2File)) {
      if (line.unknownPLAType.isNotEmpty) {
        unknownTypes.add(line.unknownPLAType);
      }
    }

    return unknownTypes;
  }

  Set<String> getUnknownAreaTypesInScrap() {
    if (_th2FileEditController.activeScrapID <= 0) {
      return {};
    }

    final THScrap scrap = _th2File.scrapByMPID(
      _th2FileEditController.activeScrapID,
    );
    final Set<String> unknownTypes = {};

    for (final THArea area in scrap.getAreas(_th2File)) {
      if (area.unknownPLAType.isNotEmpty) {
        unknownTypes.add(area.unknownPLAType);
      }
    }

    return unknownTypes;
  }

  void setSelection() {
    final List<THElement> matching = getMatchingElements();

    _th2FileEditController.selectionController.setSelectedElements(
      matching,
      setState: true,
    );
  }

  void addToSelection() {
    final List<THElement> matching = getMatchingElements();

    _th2FileEditController.selectionController.addSelectedElements(
      matching,
      setState: true,
    );
  }

  void removeFromSelection() {
    final List<THElement> matching = getMatchingElements();

    _th2FileEditController.selectionController.removeSelectedElementsByElements(
      matching,
    );
    _th2FileEditController.selectionController.setSelectionState();
  }
}
