// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/mp_element_edit_aux.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/auxiliary/mp_simplify_bezier_to_bezier.dart';
import 'package:mapiah/src/auxiliary/mp_simplify_straight_to_bezier.dart';
import 'package:mapiah/src/auxiliary/mp_straight_line_simplification_aux.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/mp_bounding_box_mixin.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/types/mp_pla_type_subtype.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/mp_add_scrap_dialog_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/mp_modal_overlay_widget.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_element_edit_controller.g.dart';

class TH2FileEditElementEditController = TH2FileEditElementEditControllerBase
    with _$TH2FileEditElementEditController;

abstract class TH2FileEditElementEditControllerBase with Store {
  @readonly
  TH2File _th2File;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditElementEditControllerBase(this._th2FileEditController)
    : _th2File = _th2FileEditController.th2File;

  @readonly
  THScrap? _newScrap;

  TH2File? _originalFileForLineSimplification;

  final Set<int> _lineSegmentsWithOptionsToPreserveSimplification = {};

  bool _isFirstLineSimplification = true;

  @readonly
  double _lineSimplifyEpsilonOnCanvas = mpLineSimplifyEpsilonOnScreen;

  @readonly
  MPLineSimplificationMethod _lineSimplificationMethod =
      MPLineSimplificationMethod.keepOriginalTypes;

  int _interactiveLineSimplificationIntensity =
      mpInteractiveLineSimplificationInitialIntensity;

  MPLineSimplificationMethod _interactiveLineSimplificationMethod =
      MPLineSimplificationMethod.keepOriginalTypes;

  int? _interactiveLineSimplificationUndoCountAtStart;

  @readonly
  double? _linePointOrientation;

  @readonly
  double? _linePointLSize;

  @readonly
  String _lastUsedStationName = '';

  MPPLATypeSubtype? _plaTypeSubtypeForNewElement;

  THCommandOptionType? _currentOptionTypeBeingEdited;

  final Set<int> _mpIDsOutdatedNonLineSegmentClones = {};
  final Set<int> _mpIDsOutdatedLineSegmentClones = {};

  bool _allImagesVisibility = true;

  final ObservableList<MPPLATypeSubtype> _lastUsedAreaTypes =
      ObservableList<MPPLATypeSubtype>();
  final ObservableList<MPPLATypeSubtype> _lastUsedAreaLineTypes =
      ObservableList<MPPLATypeSubtype>();
  final ObservableList<MPPLATypeSubtype> _lastUsedLineTypes =
      ObservableList<MPPLATypeSubtype>();
  final ObservableList<MPPLATypeSubtype> _lastUsedPointTypes =
      ObservableList<MPPLATypeSubtype>();
  final Map<MPPLATypeSubtype, MPTypeUsed> _mostUsedAreaTypes = {};
  final Map<MPPLATypeSubtype, MPTypeUsed> _mostUsedLineTypes = {};
  final Map<MPPLATypeSubtype, MPTypeUsed> _mostUsedPointTypes = {};

  final Set<THLineSegment> _addedLineSegmentsToIncludeInSelectedEndPoints = {};

  bool _lastLinePointSmoothOption = false;

  List<MPPLATypeSubtype> get lastUsedAreaTypes => _lastUsedAreaTypes;

  List<MPPLATypeSubtype> get lastUsedAreaLineTypes => _lastUsedAreaLineTypes;

  List<MPPLATypeSubtype> get lastUsedLineTypes => _lastUsedLineTypes;

  List<MPPLATypeSubtype> get lastUsedPointTypes => _lastUsedPointTypes;

  List<MPPLATypeSubtype> get mostUsedAreaTypes {
    return _getMostUsedTypes(_mostUsedAreaTypes);
  }

  List<MPPLATypeSubtype> get mostUsedLineTypes {
    return _getMostUsedTypes(_mostUsedLineTypes);
  }

  List<MPPLATypeSubtype> get mostUsedPointTypes {
    return _getMostUsedTypes(_mostUsedPointTypes);
  }

  int get interactiveLineSimplificationIntensity {
    return _interactiveLineSimplificationIntensity;
  }

  void initializeUsedTypes() {
    final Iterable<THElement> elements = _th2File.elements.values;

    for (final THElement element in elements) {
      switch (element) {
        case THArea _:
          setUsedAreaType(
            areaType: element.areaType.name,
            areaSubtype: MPCommandOptionAux.getSubtype(element) ?? '',
          );
        case THLine _:
          setUsedLineType(
            lineType: element.lineType.name,
            lineSubtype: MPCommandOptionAux.getSubtype(element) ?? '',
          );
        case THPoint _:
          setUsedPointType(
            pointType: element.pointType.name,
            pointSubtype: MPCommandOptionAux.getSubtype(element) ?? '',
          );

          final String? stationName = MPCommandOptionAux.getName(element);

          if (stationName != null) {
            _lastUsedStationName = stationName;
          }
        default:
      }
    }

    setUsedAreaType(areaType: thDefaultAreaType.name, areaSubtype: '');
    setUsedLineType(lineType: thDefaultLineType.name, lineSubtype: '');
    setUsedPointType(pointType: thDefaultPointType.name, pointSubtype: '');
  }

  List<MPPLATypeSubtype> _getMostUsedTypes(
    Map<MPPLATypeSubtype, MPTypeUsed> mostUsedTypesMap,
  ) {
    final List<MPPLATypeSubtype> mostUsedTypes = [];
    final List<MapEntry<MPPLATypeSubtype, MPTypeUsed>> entries =
        mostUsedTypesMap.entries.toList();

    entries.sort((a, b) {
      final int countComparison = b.value.count.compareTo(a.value.count);

      if (countComparison != 0) {
        return countComparison;
      }

      return b.value.lastUsed.compareTo(a.value.lastUsed);
    });

    for (final MapEntry<MPPLATypeSubtype, MPTypeUsed> entry in entries) {
      mostUsedTypes.add(entry.key);
    }

    return mostUsedTypes;
  }

  void setUsedAreaType({
    required String areaType,
    required String areaSubtype,
  }) {
    setPLATypeSubtypeForNewElement(null);

    final MPPLATypeSubtype areaTypeSubtype = MPPLATypeSubtype(
      pla: MPPLAType.area,
      type: areaType,
      subtype: areaSubtype,
    );

    if (_lastUsedAreaTypes.contains(areaTypeSubtype)) {
      _lastUsedAreaTypes.remove(areaTypeSubtype);
    }

    _lastUsedAreaTypes.insert(0, areaTypeSubtype);
    _setLastUsedAreaLineType(typeSubtype: areaTypeSubtype);

    _setMostUsedAreaType(areaType: areaType, areaSubtype: areaSubtype);
  }

  void _setMostUsedAreaType({
    required String areaType,
    required String areaSubtype,
  }) {
    final MPPLATypeSubtype areaTypeSubtype = MPPLATypeSubtype(
      pla: MPPLAType.area,
      type: areaType,
      subtype: areaSubtype,
    );

    if (_mostUsedAreaTypes.containsKey(areaTypeSubtype)) {
      _mostUsedAreaTypes[areaTypeSubtype]!.incrementUse();
    } else {
      _mostUsedAreaTypes[areaTypeSubtype] = MPTypeUsed(areaTypeSubtype);
    }
  }

  void setUsedLineType({
    required String lineType,
    required String lineSubtype,
  }) {
    setPLATypeSubtypeForNewElement(null);

    final MPPLATypeSubtype lineTypeSubtype = MPPLATypeSubtype(
      pla: MPPLAType.line,
      type: lineType,
      subtype: lineSubtype,
    );

    if (_lastUsedLineTypes.contains(lineTypeSubtype)) {
      _lastUsedLineTypes.remove(lineTypeSubtype);
    }

    _lastUsedLineTypes.insert(0, lineTypeSubtype);
    _setLastUsedAreaLineType(typeSubtype: lineTypeSubtype);

    _setMostUsedLineType(lineType: lineType, lineSubtype: lineSubtype);
  }

  void _setLastUsedAreaLineType({required MPPLATypeSubtype typeSubtype}) {
    if (_lastUsedAreaLineTypes.contains(typeSubtype)) {
      _lastUsedAreaLineTypes.remove(typeSubtype);
    }

    _lastUsedAreaLineTypes.insert(0, typeSubtype);
  }

  void _setMostUsedLineType({
    required String lineType,
    required String lineSubtype,
  }) {
    final MPPLATypeSubtype lineTypeSubtype = MPPLATypeSubtype(
      pla: MPPLAType.line,
      type: lineType,
      subtype: lineSubtype,
    );

    if (_mostUsedLineTypes.containsKey(lineTypeSubtype)) {
      _mostUsedLineTypes[lineTypeSubtype]!.incrementUse();
    } else {
      _mostUsedLineTypes[lineTypeSubtype] = MPTypeUsed(lineTypeSubtype);
    }
  }

  void setUsedPointType({
    required String pointType,
    required String pointSubtype,
  }) {
    setPLATypeSubtypeForNewElement(null);

    final MPPLATypeSubtype pointTypeSubtype = MPPLATypeSubtype(
      pla: MPPLAType.point,
      type: pointType,
      subtype: pointSubtype,
    );

    if (_lastUsedPointTypes.contains(pointTypeSubtype)) {
      _lastUsedPointTypes.remove(pointTypeSubtype);
    }

    _lastUsedPointTypes.insert(0, pointTypeSubtype);

    _setMostUsedPointType(pointType: pointType, pointSubtype: pointSubtype);
  }

  void _setMostUsedPointType({
    required String pointType,
    required String pointSubtype,
  }) {
    final MPPLATypeSubtype pointTypeSubtype = MPPLATypeSubtype(
      pla: MPPLAType.point,
      type: pointType,
      subtype: pointSubtype,
    );

    if (_mostUsedPointTypes.containsKey(pointTypeSubtype)) {
      _mostUsedPointTypes[pointTypeSubtype]!.incrementUse();
    } else {
      _mostUsedPointTypes[pointTypeSubtype] = MPTypeUsed(pointTypeSubtype);
    }
  }

  void setPLATypeSubtypeForNewElement(MPPLATypeSubtype? plaTypeSubtype) {
    _plaTypeSubtypeForNewElement = plaTypeSubtype;
  }

  void activatePLATypeSubtypeForNewElement(MPPLATypeSubtype plaTypeSubtype) {
    setPLATypeSubtypeForNewElement(plaTypeSubtype);

    switch (plaTypeSubtype.pla) {
      case MPPLAType.area:
        _th2FileEditController.stateController.onButtonPressed(
          MPButtonType.addArea,
        );
      case MPPLAType.line:
        _th2FileEditController.stateController.onButtonPressed(
          MPButtonType.addLine,
        );
      case MPPLAType.point:
        _th2FileEditController.stateController.onButtonPressed(
          MPButtonType.addPoint,
        );
    }
  }

  MPPLATypeSubtype getPointTypeAndSubtypeForNewPoint() {
    if ((_plaTypeSubtypeForNewElement != null) &&
        (_plaTypeSubtypeForNewElement!.pla == MPPLAType.point)) {
      return _plaTypeSubtypeForNewElement!;
    }

    return MPCommandOptionAux.getPLATypeSubtype(
      pla: MPPLAType.point,
      typeSubtypeID: _lastUsedPointType(),
    );
  }

  MPPLATypeSubtype getLineTypeAndSubtypeForNewLine() {
    if ((_plaTypeSubtypeForNewElement != null) &&
        (_plaTypeSubtypeForNewElement!.pla == MPPLAType.line)) {
      return _plaTypeSubtypeForNewElement!;
    }

    return MPCommandOptionAux.getPLATypeSubtype(
      pla: MPPLAType.line,
      typeSubtypeID: _lastUsedLineType(),
    );
  }

  MPPLATypeSubtype getAreaTypeAndSubtypeForNewArea() {
    if ((_plaTypeSubtypeForNewElement != null) &&
        (_plaTypeSubtypeForNewElement!.pla == MPPLAType.area)) {
      return _plaTypeSubtypeForNewElement!;
    }

    return MPCommandOptionAux.getPLATypeSubtype(
      pla: MPPLAType.area,
      typeSubtypeID: _lastUsedAreaType(),
    );
  }

  String _lastUsedAreaType() {
    if (_lastUsedAreaTypes.isEmpty) {
      return thDefaultAreaType.name;
    }

    final String lastUsedAreaType = _lastUsedAreaTypes.first.typeSubtypeID;

    return lastUsedAreaType;
  }

  String _lastUsedLineType() {
    if (_lastUsedLineTypes.isEmpty) {
      return thDefaultLineType.name;
    }

    final String lastUsedLineType = _lastUsedLineTypes.first.typeSubtypeID;

    return lastUsedLineType;
  }

  String _lastUsedPointType() {
    if (_lastUsedPointTypes.isEmpty) {
      return thDefaultPointType.name;
    }

    final String lastUsedPointType = _lastUsedPointTypes.first.typeSubtypeID;

    return lastUsedPointType;
  }

  String getAndReserveNextAvailableStationName() {
    final Set<String> usedStationNames = _getUsedStationNamesInActiveScrap();
    final int maxIterations = usedStationNames.length + 1;

    String nextStationName = _lastUsedStationName;

    for (int i = 0; i < maxIterations; i++) {
      nextStationName = MPElementEditAux.createNextStationName(nextStationName);

      if (!usedStationNames.contains(nextStationName)) {
        _lastUsedStationName = nextStationName;

        return nextStationName;
      }
    }

    throw Exception(
      'Unable to find an unused station name in the active scrap at TH2FileEditElementEditController.getNextStationName().',
    );
  }

  Set<String> _getUsedStationNamesInActiveScrap() {
    if (_th2FileEditController.activeScrapID <= 0) {
      return <String>{};
    }

    final THScrap activeScrap = _th2FileEditController.getActiveScrap();
    final Set<String> usedStationNames = <String>{};

    for (final int childMPID in activeScrap.childrenMPIDs) {
      final THElement childElement = _th2File.elementByMPID(childMPID);

      if (childElement is! THPoint) {
        continue;
      }

      if (childElement.pointType != THPointType.station) {
        continue;
      }

      final String? stationName = MPCommandOptionAux.getName(childElement);

      if (stationName != null) {
        usedStationNames.add(stationName);
      }
    }

    return usedStationNames;
  }

  List<THStationNameCommandOption> getNextStationNameOptions({
    required Iterable<int> parentMPIDs,
  }) {
    final List<THStationNameCommandOption> stationNameOptions = [];

    for (final int parentMPID in parentMPIDs) {
      stationNameOptions.add(
        THStationNameCommandOption.fromStringWithParentMPID(
          parentMPID: parentMPID,
          name: getAndReserveNextAvailableStationName(),
        ),
      );
    }

    return stationNameOptions;
  }

  List<THLineSegment> getLineSegmentsList({
    required THLine line,
    required bool clone,
  }) {
    final List<THLineSegment> lineSegments = <THLineSegment>[];
    final List<int> lineSegmentMPIDs = line.childrenMPIDs;

    for (final int lineSegmentMPID in lineSegmentMPIDs) {
      final THElement lineSegment = _th2File.elementByMPID(lineSegmentMPID);

      if (lineSegment is THLineSegment) {
        lineSegments.add(clone ? lineSegment.copyWith() : lineSegment);
      }
    }

    return lineSegments;
  }

  LinkedHashMap<int, THLineSegment> getLineSegmentsMap(THLine line) {
    final LinkedHashMap<int, THLineSegment> lineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();
    final List<int> lineSegmentMPIDs = line.childrenMPIDs;

    for (final int lineSegmentMPID in lineSegmentMPIDs) {
      final THElement lineSegment = _th2File.elementByMPID(lineSegmentMPID);

      if (lineSegment is THLineSegment) {
        lineSegmentsMap[lineSegment.mpID] = lineSegment;
      }
    }

    return lineSegmentsMap;
  }

  void substituteElement(THElement modifiedElement) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final THElement? originalElement = _th2File.tryElementByMPID(
      modifiedElement.mpID,
    );

    _th2File.substituteElement(modifiedElement);
    _markStationCacheDirtyForSubstitutedElements(
      originalElement: originalElement,
      modifiedElement: modifiedElement,
    );
    selectionController.addUpdateSelectableElement(modifiedElement);

    if (modifiedElement is THLineSegment) {
      final THLine parentLine =
          modifiedElement.parent(th2File: _th2File) as THLine;

      selectionController.updateSelectedElementLogicalClone(
        modifiedElement.parentMPID,
      );
      selectionController.updateSelectedLineSegment(modifiedElement);
      parentLine.resetLineSegmentsLists();
    } else {
      selectionController.updateSelectedElementLogicalClone(
        modifiedElement.mpID,
      );
    }
  }

  void substituteElementWithoutAddSelectableElement(THElement modifiedElement) {
    _th2File.substituteElement(modifiedElement);
  }

  void substituteLineSegments(
    LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap,
  ) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;

    for (final THLineSegment lineSegment in modifiedLineSegmentsMap.values) {
      _th2File.substituteElement(lineSegment);
      selectionController.addUpdateSelectableElement(lineSegment);
    }

    final THLine line = _th2File.lineByMPID(
      modifiedLineSegmentsMap.values.first.parentMPID,
    );

    line.resetLineSegmentsLists();
  }

  @action
  void executeReplaceLineLineSegments(
    int lineMPID,
    List<({int lineSegmentPosition, THLineSegment lineSegment})>
    newLineSegments,
  ) {
    final TH2FileEditElementEditController elementEditController =
        _th2FileEditController.elementEditController;
    final THLine line = _th2File.lineByMPID(lineMPID);
    final List<int> originalLineSegmentMPIDs = line
        .getLineSegmentMPIDs(_th2File)
        .toList();

    for (final int originalLineSegmentMPID in originalLineSegmentMPIDs) {
      final THLineSegment originalLineSegment = _th2File.lineSegmentByMPID(
        originalLineSegmentMPID,
      );

      _th2File.removeElement(originalLineSegment);
      elementEditController.addOutdatedLineSegmentCloneMPID(
        originalLineSegmentMPID,
      );
    }

    for (final ({int lineSegmentPosition, THLineSegment lineSegment})
        newLineSegment
        in newLineSegments) {
      final THLineSegment lineSegment = newLineSegment.lineSegment;

      _th2File.addElement(lineSegment);
      line.addElementToParent(
        lineSegment,
        elementPositionInParent: newLineSegment.lineSegmentPosition,
      );
      elementEditController.addOutdatedLineSegmentCloneMPID(lineSegment.mpID);
    }

    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;

    selectionController.updateSelectableEndAndControlPoints();
    elementEditController.updateControllersAfterElementEditPartial();
    selectionController.clearSelectedEndControlPoints();
    _th2FileEditController.triggerNewLineRedraw();
    _th2FileEditController.triggerEditLineRedraw();
    _th2FileEditController.triggerSelectedElementsRedraw();
  }

  @action
  void executeAddLineSegment({
    required THLineSegment newLineSegment,
    required int lineSegmentPositionInParent,
  }) {
    executeAddElement(
      newElement: newLineSegment,
      childPositionInParent: lineSegmentPositionInParent,
    );
    addOutdatedLineSegmentCloneMPID(newLineSegment.mpID);
    addLineSegmentToIncludeInSelectedEndPoints(newLineSegment);
  }

  @action
  void executeAddElement({
    required THElement newElement,
    THIsParentMixin? parent,
    int childPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
  }) {
    final int parentMPID;
    final THIsParentMixin parentElement;

    if (parent == null) {
      parentMPID = newElement.parentMPID;
      parentElement = (parentMPID < 0)
          ? _th2File
          : _th2File.parentByMPID(parentMPID);
    } else {
      parentMPID = parent.mpID;
      parentElement = parent;
    }

    _th2File.addElement(newElement);

    parentElement.addElementToParent(
      newElement,
      elementPositionInParent: childPositionInParent,
    );

    _markStationCacheDirtyForAddedElement(newElement);
  }

  @action
  void removeElement(THElement element, {bool setState = false}) {
    _removeElement(element, setState: setState);
  }

  void _removeElement(THElement element, {bool setState = false}) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final int elementMPID = element.mpID;

    if (element is THIsParentMixin) {
      final List<int> childrenMPIDList = (element as THIsParentMixin)
          .childrenMPIDs
          .toList();

      for (final int childMPID in childrenMPIDList) {
        final THElement child = _th2File.elementByMPID(childMPID);

        _removeElement(child);
      }
    }

    _markStationCacheDirtyForRemovedElement(element);

    selectionController.removeElementFromSelectable(elementMPID);
    selectionController.removeElementFromSelectedLogical(
      elementMPID,
      setState: setState,
    );
    _th2File.removeElement(element);

    switch (element) {
      case THLineSegment _:
        selectionController.removeSelectedLineSegment(elementMPID);
      case THScrap _:
        _th2FileEditController.updateHasMultipleScraps();
      case THArea _:
        if ((_th2FileEditController.areaLineCreationController.newArea !=
                null) &&
            (_th2FileEditController.areaLineCreationController.newArea!.mpID ==
                elementMPID)) {
          _th2FileEditController.areaLineCreationController.clearNewArea();
        }
    }

    final int parentMPID = element.parentMPID;

    if (parentMPID > 0) {
      final THIsParentMixin parent = _th2File.parentByMPID(parentMPID);

      if (parent is THElement) {
        selectionController.updateSelectedElementLogicalClone(parentMPID);
      }

      if (element is THLineSegment) {
        (parent as THLine).resetLineSegmentsLists();
      }
    }
  }

  void executeRemoveElementByMPID(int mpID, {bool setState = false}) {
    final THElement element = _th2File.elementByMPID(mpID);

    removeElement(element, setState: setState);
  }

  @action
  void applyRemoveElements(List<int> mpIDs) {
    for (final int mpID in mpIDs) {
      executeRemoveElementByMPID(mpID);
    }
  }

  @action
  void registerElementWithTHID(THElement element, String thID) {
    _th2File.registerElementWithTHID(element, thID);
  }

  @action
  void createScrap({
    required String thID,
    List<THElement>? scrapChildren,
    List<THCommandOption>? scrapOptions,
  }) {
    final MPCommand addScrapCommand = MPCommandFactory.addScrap(
      thID: thID,
      th2File: _th2File,
      scrapChildren: scrapChildren,
      scrapOptions: scrapOptions,
    );

    _th2FileEditController.execute(addScrapCommand);
  }

  @action
  void executeAddScrap({
    required THScrap newScrap,
    required int scrapPositionAtParent,
  }) {
    newScrap.childrenMPIDs.clear();
    executeAddElement(
      newElement: newScrap,
      childPositionInParent: scrapPositionAtParent,
    );
  }

  void afterAddScrap(THScrap newScrap) {
    newScrap.clearBoundingBox();
    _th2FileEditController.setActiveScrap(newScrap.mpID);
    _th2FileEditController.updateHasMultipleScraps();
    afterAddElement(newScrap);
  }

  @action
  void addPoint({
    required Offset newPointScreenPosition,
    required String pointTypeString,
    required String pointSubtypeString,
  }) {
    final MPCommand command = MPCommandFactory.addPoint(
      screenPosition: newPointScreenPosition,
      pointTypeString: pointTypeString,
      pointSubtypeString: pointSubtypeString,
      th2FileEditController: _th2FileEditController,
    );

    _th2FileEditController.execute(command);
    setUsedPointType(
      pointType: pointTypeString,
      pointSubtype: pointSubtypeString,
    );
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }

  void afterAddElement(THElement newElement) {
    _th2FileEditController.setActiveScrapByChildElement(newElement);
    _th2FileEditController.selectionController.updateAfterAddElement(
      newElement,
    );
    _th2FileEditController.triggerAllElementsRedraw();
  }

  @action
  void executeSetOptionToElement({
    required THCommandOption option,
    required String plaOriginalLineInTH2File,
  }) {
    if (option is THStationNameCommandOption) {
      _lastUsedStationName = option.name;
      _markTherionStationPointNameCoordinateCacheDirty();
    }

    final int parentMPID = option.parentMPID;
    final THElement parentElement =
        _th2File
            .elementByMPID(parentMPID)
            .copyWith(originalLineInTH2File: plaOriginalLineInTH2File)
          ..setTH2File(_th2File);

    if (parentElement is! THHasOptionsMixin) {
      throw Exception(
        'Error: parentElement is not THHasOptionsMixin at TH2FileEditElementEditController.executeSetOptionToElement().',
      );
    }

    parentElement.addUpdateOption(option);

    if (parentMPID >= 0) {
      _th2File.substituteElement(parentElement);
    }

    if (parentElement is THLineSegment) {
      _th2FileEditController.elementEditController
          .addOutdatedLineSegmentCloneMPID(parentMPID);
    } else {
      _th2FileEditController.elementEditController.addOutdatedCloneMPID(
        parentMPID,
      );
    }
  }

  @action
  void executeRemoveOptionFromElement({
    required THCommandOptionType optionType,
    required int parentMPID,
    required String newOriginalLineInTH2File,
  }) {
    final THHasOptionsMixin parentElement = _th2File.hasOptionByMPID(
      parentMPID,
    );

    if (optionType == THCommandOptionType.id) {
      _th2File.unregisterElementTHIDByMPID(parentMPID);
    }

    final THHasOptionsMixin newParentElement =
        (parentElement.copyWith(originalLineInTH2File: newOriginalLineInTH2File)
              as THHasOptionsMixin)
          ..setTH2File(_th2File);

    newParentElement.removeOption(optionType);
    _th2File.substituteElement(newParentElement);

    if (optionType == THCommandOptionType.station) {
      _markTherionStationPointNameCoordinateCacheDirty();
    }

    if (parentElement is THLineSegment) {
      _th2FileEditController.elementEditController
          .addOutdatedLineSegmentCloneMPID(parentMPID);
    } else {
      _th2FileEditController.elementEditController.addOutdatedCloneMPID(
        parentMPID,
      );
    }
  }

  @action
  void executeRemoveAttrOptionFromElement({
    required String attrName,
    required int parentMPID,
    required String newOriginalLineInTH2File,
  }) {
    final THHasOptionsMixin parentElement = _th2FileEditController.th2File
        .hasOptionByMPID(parentMPID);

    final THHasOptionsMixin newParentElement =
        parentElement.copyWith(originalLineInTH2File: newOriginalLineInTH2File)
            as THHasOptionsMixin;

    newParentElement.removeAttrOption(attrName);
    _th2File.substituteElement(newParentElement);
    if (parentElement is THLineSegment) {
      _th2FileEditController.elementEditController
          .addOutdatedLineSegmentCloneMPID(parentMPID);
    } else {
      _th2FileEditController.elementEditController.addOutdatedCloneMPID(
        parentMPID,
      );
    }
  }

  @action
  void applyRemoveSelectedLineSegments() {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final Iterable<int> selectedLineSegmentMPIDs = selectionController
        .selectedEndControlPoints
        .keys
        .toList();

    if (selectedLineSegmentMPIDs.isEmpty) {
      return;
    }

    final int parentLineMPID = _th2File
        .lineSegmentByMPID(selectedLineSegmentMPIDs.first)
        .parentMPID;
    final List<MPCommand> removeLineSegmentCommands = [];

    bool lineRemoved = false;

    for (final int lineSegmentMPID in selectedLineSegmentMPIDs) {
      addOutdatedLineSegmentCloneMPID(lineSegmentMPID);

      final MPCommand removeLineSegmentCommand =
          MPCommandFactory.removeLineSegmentFromExisting(
            toRemoveLineSegmentMPID: lineSegmentMPID,
            th2File: _th2File,
          );

      removeLineSegmentCommand.execute(_th2FileEditController);
      removeLineSegmentCommands.add(removeLineSegmentCommand);

      if (!_th2File.hasElementByMPID(parentLineMPID)) {
        lineRemoved = true;
      }
    }

    final MPCommand removeCommand = MPCommandFactory.multipleCommandsFromList(
      commandsList: removeLineSegmentCommands,
      completionType:
          MPMultipleElementsCommandCompletionType.lineSegmentsEdited,
      descriptionType: MPCommandDescriptionType.removeLineSegment,
    );

    /// Checking if there is more than one command in removeLineSegmentCommands
    /// and not directly checking if removeCommand is MPMultipleElementsCommand
    /// because the latter may not be true if there is only one line segment to
    /// remove and the single remove command is a MPMultipleElementsCommand
    /// itself.
    if (removeLineSegmentCommands.length > 1) {
      (removeCommand as MPMultipleElementsCommand).prepareUndoRedoInfo(
        _th2FileEditController,
      );
    }

    _th2FileEditController.undoRedoController.add(removeCommand);
    updateControllersAfterElementEditPartial();
    updateControllersAfterElementEditFinal();
    _th2FileEditController.updateUndoRedoStatus();
    if (lineRemoved) {
      _th2FileEditController.stateController.setState(
        MPTH2FileEditStateType.selectEmptySelection,
      );
    } else {
      _th2FileEditController.stateController.updateStatusBarMessage();
    }
  }

  void clearMPIDsOutdatedClones() {
    _mpIDsOutdatedNonLineSegmentClones.clear();
    _mpIDsOutdatedLineSegmentClones.clear();
  }

  void addOutdatedCloneMPID(int mpID) {
    _mpIDsOutdatedNonLineSegmentClones.add(mpID);

    final THElement? element = _th2File.tryElementByMPID(mpID);

    if (element != null) {
      if (element is THAreaBorderTHID) {
        _mpIDsOutdatedNonLineSegmentClones.add(element.parentMPID);
      } else if (element is THLineSegment) {
        throw Exception(
          'Error: element is THLineSegment at TH2FileEditElementEditController.addOutdatedCloneMPID().',
        );
      }
    }
  }

  void addOutdatedLineSegmentCloneMPID(int mpID) {
    _mpIDsOutdatedLineSegmentClones.add(mpID);

    final THElement? element = _th2File.tryElementByMPID(mpID);

    if (element != null) {
      if (element is THLineSegment) {
        _mpIDsOutdatedNonLineSegmentClones.add(element.parentMPID);
      } else {
        throw Exception(
          'Error: element is not THLineSegment at TH2FileEditElementEditController.addOutdatedLineSegmentCloneMPID().',
        );
      }
    }
  }

  Set<int> get mpIDsOutdatedNonLineSegmentClones =>
      _mpIDsOutdatedNonLineSegmentClones;

  Set<int> get mpIDsOutdatedLineSegmentClones =>
      _mpIDsOutdatedLineSegmentClones;

  @action
  /// Updates the selection and selectable elements in the controllers
  /// after an element has been edited. It only updates the elements that
  /// have been marked as having outdated clones, i.e., that have been modified.
  /// This method can be called several times during some action (e.g., during
  /// a drag) because it only affects the elements that have been marked as
  /// outdated.
  /// The updateControllersAfterElementEditFinal() should be
  /// called only once at the end of the action to finalize the updates as it
  /// affects objects related to all elements (e.g., snap targets).
  void updateControllersAfterElementEditPartial() {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;

    for (final int nonLineSegmentMPID in mpIDsOutdatedNonLineSegmentClones) {
      final THElement? element = _th2File.tryElementByMPID(nonLineSegmentMPID);

      if (element == null) {
        selectionController.removeElementFromSelectable(nonLineSegmentMPID);
        selectionController.removeElementFromSelectedLogical(
          nonLineSegmentMPID,
        );
      } else {
        if (element is THLine) {
          element.resetLineSegmentsLists();
        }

        if (element is MPBoundingBoxMixin) {
          (element as MPBoundingBoxMixin).clearBoundingBox();
        }

        selectionController.addUpdateSelectableElement(element);
        selectionController.updateSelectedElementLogicalClone(
          nonLineSegmentMPID,
        );
      }
    }

    for (final int lineSegmentMPID in mpIDsOutdatedLineSegmentClones) {
      final THElement? lineSegment = _th2File.tryElementByMPID(lineSegmentMPID);

      if (lineSegment == null) {
        selectionController.removeElementFromSelectable(lineSegmentMPID);
        selectionController.removeSelectedLineSegment(lineSegmentMPID);
      } else {
        if (lineSegment is! THLineSegment) {
          throw Exception(
            'Error: lineSegment is not THLineSegment at TH2FileEditElementEditController.updateControllersAfterElementEditPartial().',
          );
        }

        lineSegment.clearBoundingBox();

        selectionController.addUpdateSelectableElement(lineSegment);
        selectionController.updateSelectedElementLogicalClone(lineSegmentMPID);
        selectionController.updateSelectedLineSegment(lineSegment);
      }
    }

    clearMPIDsOutdatedClones();
  }

  @action
  /// Finalizes the updates in the controllers after elements have been
  /// edited. This method should be called only once at the end of the action
  /// that modified the elements (e.g., at the end of a drag) as it affects
  /// objects related to all elements (e.g., snap targets).
  void updateControllersAfterElementEditFinal() {
    _th2FileEditController.selectionController
        .updateSelectableEndAndControlPoints();

    _th2FileEditController.snapController.updateSnapTargets();

    _th2FileEditController.updateEnableSelectButton();
    _th2FileEditController.triggerEditLineRedraw();
    _th2FileEditController.triggerSelectedElementsRedraw();
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }

  void clearAddedLineSegmentsToIncludeInSelectedEndPoints() {
    _addedLineSegmentsToIncludeInSelectedEndPoints.clear();
  }

  void addLineSegmentToIncludeInSelectedEndPoints(THLineSegment lineSegment) {
    _addedLineSegmentsToIncludeInSelectedEndPoints.add(lineSegment);
  }

  @action
  void applyAddLineSegmentsBetweenSelectedLineSegments() {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final Map<int, MPSelectedEndControlPoint> selectedEndControlPoints =
        selectionController.selectedEndControlPoints;

    clearAddedLineSegmentsToIncludeInSelectedEndPoints();

    if (selectedEndControlPoints.length < 2) {
      return;
    }

    final THLine line = _th2File.lineByMPID(
      selectedEndControlPoints.values.first.originalLineSegmentClone.parentMPID,
    );
    final MPCommand? addLineSegmentsCommand = getAddLineSegmentsCommand(
      line: line,
      selectedEndControlPoints: selectedEndControlPoints.values,
    );

    if (addLineSegmentsCommand == null) {
      return;
    }

    _th2FileEditController.execute(addLineSegmentsCommand);
    selectionController.addSelectedEndPoints(
      _addedLineSegmentsToIncludeInSelectedEndPoints,
    );
    clearAddedLineSegmentsToIncludeInSelectedEndPoints();
    selectionController.updateSelectableEndAndControlPoints();
    _th2FileEditController.triggerEditLineRedraw();
  }

  MPCommand? getAddLineSegmentsCommand({
    required THLine line,
    required Iterable<MPSelectedEndControlPoint> selectedEndControlPoints,
  }) {
    final List<int> lineSegmentMPIDs = line.getLineSegmentMPIDs(_th2File);
    final Map<int, THLineSegment> selectedLineSegmentsPosMap = {};
    final List<MPCommand> addLineSegmentsCommands = [];

    for (final MPSelectedEndControlPoint endControlPoint
        in selectedEndControlPoints) {
      final THLineSegment lineSegment =
          endControlPoint.originalLineSegmentClone;
      final int lineSegmentPos = lineSegmentMPIDs.indexOf(lineSegment.mpID);

      selectedLineSegmentsPosMap[lineSegmentPos] = lineSegment;
    }

    final Iterable<int> selectedLineSegmentsPos =
        selectedLineSegmentsPosMap.keys.toList()..sort();

    int? previousLineSegmentPos;

    for (final int lineSegmentPos in selectedLineSegmentsPos) {
      if ((previousLineSegmentPos != null) &&
          (lineSegmentPos == previousLineSegmentPos + 1)) {
        final THLineSegment lineSegment =
            selectedLineSegmentsPosMap[lineSegmentPos]!;
        final THLineSegment previousLineSegment =
            selectedLineSegmentsPosMap[previousLineSegmentPos]!;

        if (lineSegment is THStraightLineSegment) {
          final Offset newLineSegmentEndPoint =
              (previousLineSegment.endPoint.coordinates +
                  lineSegment.endPoint.coordinates) /
              2;
          final THStraightLineSegment newLineSegment = THStraightLineSegment(
            parentMPID: lineSegment.parentMPID,
            endPoint: THPositionPart(coordinates: newLineSegmentEndPoint),
          );

          addLineSegmentsCommands.add(
            MPAddLineSegmentCommand.atExistingLineSegmentPosition(
              newLineSegment: newLineSegment,
              existingLineSegmentMPID: lineSegment.mpID,
              posCommand: null,
            ),
          );
        } else {
          final List<THBezierCurveLineSegment> newLineSegments =
              MPNumericAux.splitBezierCurveAtPart(
                startPoint: previousLineSegment.endPoint.coordinates,
                lineSegment: lineSegment as THBezierCurveLineSegment,
                part: mpHalfBezierArcPart,
              );

          if (newLineSegments.length != 2) {
            throw Exception(
              'Error: newLineSegments.length != 2 at TH2FileEditElementEditController.applyAddLineSegmentsBetweenSelectedLineSegments(). Length: ${newLineSegments.length}',
            );
          }

          addLineSegmentsCommands.add(
            MPAddLineSegmentCommand.atExistingLineSegmentPosition(
              newLineSegment: newLineSegments[0],
              existingLineSegmentMPID: lineSegment.mpID,
              posCommand: null,
            ),
          );
          addLineSegmentsCommands.add(
            MPEditLineSegmentCommand(
              originalLineSegment: lineSegment,
              newLineSegment: newLineSegments[1],
            ),
          );
        }
      }

      previousLineSegmentPos = lineSegmentPos;
    }

    if (addLineSegmentsCommands.isEmpty) {
      return null;
    }

    final MPCommand addLineSegmentsCommand =
        MPCommandFactory.multipleCommandsFromList(
          commandsList: addLineSegmentsCommands,
          descriptionType: MPCommandDescriptionType.addLineSegment,
          completionType:
              MPMultipleElementsCommandCompletionType.lineSegmentsEdited,
        );

    return addLineSegmentsCommand;
  }

  void addScrap() {
    final BuildContext? currentContext = _th2FileEditController
        .getTH2FileWidgetGlobalKey()
        .currentContext;

    if (currentContext == null) {
      return;
    }

    final String filename = MPElementEditAux.getFilenameFromPath(
      _th2File.filename,
    );
    final String normalizedFilename = MPElementEditAux.normalizeToTHID(
      filename,
    );
    final String thIDPrefix = '$normalizedFilename-scrap';
    final String initialScrapTHID = _th2File.getNewTHID(prefix: thIDPrefix);

    MPModalOverlayWidget.show(
      context: currentContext,
      childBuilder: (onPressedClose) => MPAddScrapDialogOverlayWindowWidget(
        initialScrapTHID: initialScrapTHID,
        onPressedClose: onPressedClose,
        th2FileEditController: _th2FileEditController,
      ),
    );
  }

  Future<void> addImage() async {
    final BuildContext? currentContext = _th2FileEditController
        .overlayWindowController
        .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType.changeImageButton]!
        .currentContext;

    if (currentContext == null) {
      return;
    }

    final PickImageFileReturn imageResult = await MPDialogAux.pickImageFile(
      currentContext,
    );

    if (imageResult.type == PickImageFileReturnType.empty) {
      return;
    }

    final MPAddImageInsertConfigCommand addImageCommand =
        MPCommandFactory.addImageInsertConfig(
          imageFilename: imageResult.filename!,
          th2FileEditController: _th2FileEditController,
          svgIntrinsicSizeInfo: imageResult.svgIntrinsicSizeInfo,
        );

    await _warmAddedImageBounds(addImageCommand.newImageInsertConfig);

    _th2FileEditController.execute(addImageCommand);
    _th2FileEditController.triggerImagesRedraw();
  }

  Future<void> _warmAddedImageBounds(THElement newImageInsertConfig) async {
    if (newImageInsertConfig is! MPRuntimeRasterImageInsertConfigMixin) {
      return;
    }

    await newImageInsertConfig.getRasterImageFrameInfo(_th2FileEditController);
  }

  void removeImage(int mpID) {
    final MPRemoveImageInsertConfigCommand removeImageCommand =
        MPCommandFactory.removeImageInsertConfigFromExisting(
          existingImageInsertConfigMPID: mpID,
          th2File: _th2FileEditController.th2File,
        );

    _th2FileEditController.execute(removeImageCommand);
    _th2FileEditController.triggerImagesRedraw();
  }

  /// Ensures [imageMPID] is backed by an [MPImageInsertConfig] before any
  /// Mapiah-only image transform workflow starts.
  ///
  /// Phase 5 keeps regular image insertion in the legacy
  /// `THXTherionImageInsertConfig` format for compatibility, but future
  /// Mapiah-only operations such as scale, move, and rotate need the richer
  /// [MPImageInsertConfig] runtime model. This method performs that lazy
  /// migration on demand:
  ///
  void reorderImages({required int oldIndex, required int newIndex}) {
    final MPReorderImagesCommand reorderImagesCommand =
        MPCommandFactory.reorderImages(oldIndex: oldIndex, newIndex: newIndex);

    _th2FileEditController.execute(reorderImagesCommand);
  }

  @action
  void executeReorderImages({required int oldIndex, required int newIndex}) {
    _th2File.reorderImageMPIDs(oldIndex: oldIndex, newIndex: newIndex);
    _th2FileEditController.triggerImagesRedraw();
  }

  void reorderScraps({required int oldIndex, required int newIndex}) {
    final MPReorderScrapsCommand reorderScrapsCommand =
        MPCommandFactory.reorderScraps(oldIndex: oldIndex, newIndex: newIndex);

    _th2FileEditController.execute(reorderScrapsCommand);
  }

  @action
  void executeReorderScraps({required int oldIndex, required int newIndex}) {
    _th2File.reorderScrapMPIDs(oldIndex: oldIndex, newIndex: newIndex);
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }

  @action
  void removeScrap(int scrapMPID) {
    final MPRemoveScrapCommand removeScrapCommand =
        MPCommandFactory.removeScrapFromExisting(
          existingScrapMPID: scrapMPID,
          th2File: _th2FileEditController.th2File,
        );

    _th2FileEditController.setActiveScrapForScrapRemoval(scrapMPID);
    _th2FileEditController.execute(removeScrapCommand);
  }

  MPCommand? getSmoothLineSegmentsCommand(THLineSegment lineSegment) {
    final bool isLineSegmentBezier =
        lineSegment.elementType == THElementType.bezierCurveLineSegment;
    final TH2File th2File = _th2FileEditController.th2File;
    final THLine line = th2File.lineByMPID(lineSegment.parentMPID);
    final THLineSegment? nextLineSegment = line.getNextLineSegment(
      lineSegment,
      th2File,
    );
    final bool isNextLineSegmentBezier =
        nextLineSegment?.elementType == THElementType.bezierCurveLineSegment;

    if ((isLineSegmentBezier || isNextLineSegmentBezier) &&
        (nextLineSegment != null) &&
        (!line.isFirstLineSegment(lineSegment, th2File))) {
      if (isLineSegmentBezier && isNextLineSegmentBezier) {
        final List<THBezierCurveLineSegment> smoothedBezierSegments =
            MPElementEditAux.getSmoothedBezierLineSegments(
              lineSegment: lineSegment as THBezierCurveLineSegment,
              nextLineSegment: nextLineSegment as THBezierCurveLineSegment,
              th2File: th2File,
            );

        if (smoothedBezierSegments.isNotEmpty) {
          final Map<int, THLineSegment> fromLineSegmentsMap = {
            lineSegment.mpID: lineSegment,
            nextLineSegment.mpID: nextLineSegment,
          };
          final Map<int, THLineSegment> smoothedSegmentsMap = {
            for (final segment in smoothedBezierSegments) segment.mpID: segment,
          };

          return MPMoveLineCommand(
            lineMPID: line.mpID,
            fromLineSegmentsMap: fromLineSegmentsMap,
            toLineSegmentsMap: smoothedSegmentsMap,
          );
        }
      } else {
        final THBezierCurveLineSegment unalignedBezierLineSegment;
        final THBezierCurveLineSegment alignedBezierLineSegment;

        if (isLineSegmentBezier) {
          unalignedBezierLineSegment = lineSegment as THBezierCurveLineSegment;

          final Offset? alignedControlPoint =
              MPElementEditAux.getControlPointAlignedToStraight(
                controlPoint: lineSegment.controlPoint2.coordinates,
                junction: lineSegment.endPoint.coordinates,
                startStraightLineSegment: nextLineSegment.endPoint.coordinates,
                th2File: th2File,
              );

          if (alignedControlPoint == null) {
            return null;
          }
          alignedBezierLineSegment = lineSegment.copyWith(
            controlPoint2: THPositionPart(coordinates: alignedControlPoint),
            originalLineInTH2File: '',
          );
        } else {
          final THLineSegment? previousLineSegment = line
              .getPreviousLineSegment(lineSegment, th2File);

          if (previousLineSegment == null) {
            return null;
          }

          unalignedBezierLineSegment =
              nextLineSegment as THBezierCurveLineSegment;

          final Offset? alignedControlPoint =
              MPElementEditAux.getControlPointAlignedToStraight(
                controlPoint: nextLineSegment.controlPoint1.coordinates,
                junction: lineSegment.endPoint.coordinates,
                startStraightLineSegment:
                    previousLineSegment.endPoint.coordinates,
                th2File: th2File,
              );

          if (alignedControlPoint == null) {
            return null;
          }
          alignedBezierLineSegment = nextLineSegment.copyWith(
            controlPoint1: THPositionPart(coordinates: alignedControlPoint),
            originalLineInTH2File: '',
          );
        }

        return MPMoveBezierLineSegmentCommand.fromLineSegments(
          fromLineSegment: unalignedBezierLineSegment,
          toLineSegment: alignedBezierLineSegment,
        );
      }
    }

    return null;
  }

  @action
  void toggleSelectedLinesReverseOption() {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final TH2File th2File = _th2FileEditController.th2File;
    final List<MPCommand> toggleCommands = [];

    for (final MPSelectedElement selectedElement
        in selectionController.mpSelectedElementsLogical.values) {
      if (selectedElement is! MPSelectedLine) {
        continue;
      }
      final int lineMPID = selectedElement.mpID;
      final THLine currentLine = th2File.lineByMPID(lineMPID);
      final THReverseCommandOption? reverseOption =
          MPCommandOptionAux.isReversed(currentLine)
          ? null
          : THReverseCommandOption(
              parentMPID: lineMPID,
              choice: THOptionChoicesOnOffType.on,
            );
      final MPCommand toggleCommand = (reverseOption == null)
          ? MPRemoveOptionFromElementCommand(
              optionType: THCommandOptionType.reverse,
              parentMPID: lineMPID,
              descriptionType: MPCommandDescriptionType.toggleReverseOption,
            )
          : MPSetOptionToElementCommand(
              toOption: reverseOption,
              descriptionType: MPCommandDescriptionType.toggleReverseOption,
            );

      toggleCommands.add(toggleCommand);
    }

    if (toggleCommands.isEmpty) {
      return;
    }

    final MPCommand toggleAllCommand =
        MPCommandFactory.multipleCommandsFromList(
          commandsList: toggleCommands,
          completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
          descriptionType: MPCommandDescriptionType.toggleReverseOption,
        );

    _th2FileEditController.execute(toggleAllCommand);
    _th2FileEditController.triggerSelectedElementsRedraw();
    _th2FileEditController.triggerEditLineRedraw();
  }

  @action
  void toggleSelectedLinesSmoothOption() {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final List<MPCommand> toggleCommands = [];
    final bool toggleOn = getNextToggleOn();

    for (final MPSelectedElement selectedElement
        in selectionController.mpSelectedElementsLogical.values) {
      if (selectedElement is! MPSelectedLine) {
        continue;
      }

      final MPCommand? toggleCommand =
          getToggleSelectedLinePointsSmoothOptionCommand(
            toggleOn,
            selectedElement.originalLineSegmentsMapClone.keys,
          );

      if (toggleCommand != null) {
        toggleCommands.add(toggleCommand);
      }
    }

    if (toggleCommands.isEmpty) {
      return;
    }

    final MPCommand toggleAllCommand =
        MPCommandFactory.multipleCommandsFromList(
          commandsList: toggleCommands,
          completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
          descriptionType: MPCommandDescriptionType.toggleSmoothOption,
        );

    _th2FileEditController.execute(toggleAllCommand);
    _th2FileEditController.triggerSelectedElementsRedraw();
    _th2FileEditController.triggerEditLineRedraw();
  }

  @action
  bool getNextToggleOn() {
    final bool toggleOn = !_lastLinePointSmoothOption;

    _lastLinePointSmoothOption = toggleOn;

    return toggleOn;
  }

  @action
  void toggleAllImagesVisibility() {
    final bool newVisibilitySetting = !getCurrentAllImagesVisibility();
    final Iterable<MPRuntimeImageInsertConfigMixin> allImages = _th2File
        .getImages();

    for (final MPRuntimeImageInsertConfigMixin image in allImages) {
      image.isVisible = newVisibilitySetting;
    }

    _allImagesVisibility = newVisibilitySetting;
    _th2FileEditController.triggerImagesRedraw();
  }

  /// If all XVI image grids are visible, hides all grids.
  /// If any XVI image grid is hidden, makes all grids visible.
  @action
  void toggleAllGridsVisibility() {
    final List<MPRuntimeXVIImageInsertConfigMixin> xviImages = _th2File
        .getImages()
        .map((MPRuntimeImageInsertConfigMixin image) => image.asXVIImage)
        .nonNulls
        .toList();

    final bool allGridsVisible = xviImages.every(
      (MPRuntimeXVIImageInsertConfigMixin image) => image.isGridVisible,
    );

    for (final MPRuntimeXVIImageInsertConfigMixin image in xviImages) {
      image.isGridVisible = !allGridsVisible;
    }

    _th2FileEditController.triggerImagesRedraw();
  }

  @action
  void toggleSelectedLinePointsSmoothOption() {
    final Iterable<int> selectedLineSegmentMPIDs = _th2FileEditController
        .selectionController
        .selectedEndControlPoints
        .keys
        .toList();

    if (selectedLineSegmentMPIDs.isEmpty) {
      return;
    }

    final bool toggleOn = getNextToggleOn();
    final MPCommand? toggleCommand =
        getToggleSelectedLinePointsSmoothOptionCommand(
          toggleOn,
          selectedLineSegmentMPIDs,
        );

    if (toggleCommand == null) {
      return;
    }

    _th2FileEditController.execute(toggleCommand);
    updateControllersAfterElementEditPartial();
    updateControllersAfterElementEditFinal();
  }

  @action
  MPCommand? getToggleSelectedLinePointsSmoothOptionCommand(
    bool toggleOn,
    Iterable<int> selectedLineSegmentMPIDs,
  ) {
    final List<MPCommand> toggleCommands = [];

    for (final int selectedLineSegmentMPID in selectedLineSegmentMPIDs) {
      final THLineSegment lineSegment = _th2File.lineSegmentByMPID(
        selectedLineSegmentMPID,
      );
      final bool isSmooth = MPCommandOptionAux.isSmooth(lineSegment);
      final THSmoothCommandOption? smoothOption = (toggleOn && !isSmooth)
          ? THSmoothCommandOption(
              parentMPID: selectedLineSegmentMPID,
              choice: THOptionChoicesOnOffAutoType.on,
            )
          : null;
      final MPCommand? smoothOptionCommand = (toggleOn == isSmooth)
          ? null
          : ((smoothOption == null)
                ? MPRemoveOptionFromElementCommand(
                    optionType: THCommandOptionType.smooth,
                    parentMPID: selectedLineSegmentMPID,
                    descriptionType:
                        MPCommandDescriptionType.toggleSmoothOption,
                  )
                : MPSetOptionToElementCommand(
                    toOption: smoothOption,
                    descriptionType:
                        MPCommandDescriptionType.toggleSmoothOption,
                  ));

      if (smoothOptionCommand != null) {
        toggleCommands.add(smoothOptionCommand);
      }

      if (smoothOption != null) {
        final MPCommand? smoothLineSegmentsCommand = _th2FileEditController
            .elementEditController
            .getSmoothLineSegmentsCommand(lineSegment);

        if (smoothLineSegmentsCommand != null) {
          toggleCommands.add(smoothLineSegmentsCommand);
        }
      }

      addOutdatedLineSegmentCloneMPID(selectedLineSegmentMPID);
    }

    if (toggleCommands.isEmpty) {
      return null;
    }

    final MPCommand toggleAllCommand =
        MPCommandFactory.multipleCommandsFromList(
          commandsList: toggleCommands,
          completionType:
              MPMultipleElementsCommandCompletionType.lineSegmentsEdited,
          descriptionType: MPCommandDescriptionType.toggleSmoothOption,
        );

    return toggleAllCommand;
  }

  @action
  void simplifySelectedLines() {
    prepareLineSimplificationInfo();

    _simplifySelectedLinesWithParameters(
      lineSimplificationMethod: _lineSimplificationMethod,
      lineSimplifyEpsilonOnCanvas: _lineSimplifyEpsilonOnCanvas,
    );
  }

  void startInteractiveLineSimplification() {
    _originalFileForLineSimplification = _th2File.copyWith();
    _isFirstLineSimplification = true;
    _interactiveLineSimplificationUndoCountAtStart =
        _th2FileEditController.undoCount;

    previewInteractiveLineSimplification(
      lineSimplificationMethod: _lineSimplificationMethod,
      intensity: _interactiveLineSimplificationIntensity,
    );
  }

  void previewInteractiveLineSimplification({
    required MPLineSimplificationMethod lineSimplificationMethod,
    required int intensity,
  }) {
    assert(
      _interactiveLineSimplificationUndoCountAtStart != null,
      'Interactive line simplification must be started before preview.',
    );

    _interactiveLineSimplificationMethod = lineSimplificationMethod;
    _interactiveLineSimplificationIntensity = intensity;

    final double lineSimplifyEpsilonOnCanvas =
        getLineSimplifyEpsilonOnCanvasIncrease() * intensity;
    final bool didApplyPreview = _simplifySelectedLinesWithParameters(
      lineSimplificationMethod: lineSimplificationMethod,
      lineSimplifyEpsilonOnCanvas: lineSimplifyEpsilonOnCanvas,
    );
    final int undoCountAtStart =
        _interactiveLineSimplificationUndoCountAtStart!;
    final bool hasPreviewUndo =
        _th2FileEditController.undoCount > undoCountAtStart;

    if (!didApplyPreview && hasPreviewUndo) {
      _th2FileEditController.revertLastUndoWithoutRedo();
      _isFirstLineSimplification = true;
      _th2FileEditController.stateController.state.updateStatusBarMessage();
    }
  }

  void commitInteractiveLineSimplification() {
    _lineSimplificationMethod = _interactiveLineSimplificationMethod;
    _originalFileForLineSimplification = _th2File.copyWith();
    _interactiveLineSimplificationUndoCountAtStart =
        _th2FileEditController.undoCount;
    _isFirstLineSimplification = true;
  }

  void finishInteractiveLineSimplification() {
    _lineSimplificationMethod = _interactiveLineSimplificationMethod;
    _interactiveLineSimplificationUndoCountAtStart = null;
    resetOriginalFileForLineSimplification();
  }

  void cancelInteractiveLineSimplification() {
    final int? undoCountAtStart =
        _interactiveLineSimplificationUndoCountAtStart;

    if ((undoCountAtStart != null) &&
        (_th2FileEditController.undoCount > undoCountAtStart)) {
      _th2FileEditController.revertLastUndoWithoutRedo();
    }

    _interactiveLineSimplificationUndoCountAtStart = null;
    resetOriginalFileForLineSimplification();
    _th2FileEditController.stateController.state.updateStatusBarMessage();
  }

  bool _simplifySelectedLinesWithParameters({
    required MPLineSimplificationMethod lineSimplificationMethod,
    required double lineSimplifyEpsilonOnCanvas,
  }) {
    final List<MPCommand> simplifyCommands = [];
    final Iterable<MPSelectedElement> mpSelectedElements =
        _th2FileEditController
            .selectionController
            .mpSelectedElementsLogical
            .values;
    final int currentDecimalPositions =
        _th2FileEditController.currentDecimalPositions;

    int lineCount = 0;

    for (final MPSelectedElement mpSelectedElement in mpSelectedElements) {
      if (mpSelectedElement is! MPSelectedLine) {
        continue;
      }

      final THLine originalLine = _originalFileForLineSimplification!
          .lineByMPID(mpSelectedElement.mpID);
      final List<THLineSegment> originalLineSegmentsList = originalLine
          .getLineSegments(_originalFileForLineSimplification!);

      if (originalLineSegmentsList.length < 3) {
        continue;
      }

      lineCount++;

      _lineSegmentsWithOptionsToPreserveSimplification.clear();

      /// Forcing the first and last line segments to be preserved to avoid so
      /// their original decimal positions settings are preserved.
      _lineSegmentsWithOptionsToPreserveSimplification.add(
        originalLineSegmentsList.first.mpID,
      );
      _lineSegmentsWithOptionsToPreserveSimplification.add(
        originalLineSegmentsList.last.mpID,
      );

      for (final THLineSegment lineSegment in originalLineSegmentsList) {
        if (lineSegment.optionsMap.isNotEmpty ||
            lineSegment.attrOptionsMap.isNotEmpty) {
          _lineSegmentsWithOptionsToPreserveSimplification.add(
            lineSegment.mpID,
          );
        }
      }

      final List<MPSingleTypeLineSegmentList> perTypeLineSegments =
          groupLineSegmentsForSimplification(
            line: originalLine,
            th2File: _originalFileForLineSimplification!,
          );
      final THLineSegment firstLineSegment =
          perTypeLineSegments.first.lineSegments.first;
      final List<THLineSegment> simplifiedLineSegmentsCompleteList = [
        firstLineSegment is THStraightLineSegment
            ? firstLineSegment
            : THStraightLineSegment(
                parentMPID: firstLineSegment.parentMPID,
                endPoint: firstLineSegment.endPoint,
              ),
      ];

      for (final MPSingleTypeLineSegmentList typeLineSegments
          in perTypeLineSegments) {
        final List<THLineSegment> simplifiedLineSegmentsList;
        final List<THLineSegment> originalPerTypeLineSegmentsList =
            typeLineSegments.lineSegments;

        bool onlyUseSimplifiedSegmentsIfReducedAmountOfSegments = true;

        switch (typeLineSegments.type) {
          case THElementType.bezierCurveLineSegment:
            if (lineSimplificationMethod ==
                MPLineSimplificationMethod.forceStraight) {
              simplifiedLineSegmentsList =
                  MPElementEditAux.mpSimplifyBezierCurveLineSegmentsToStraightLineSegments(
                    th2File: _originalFileForLineSimplification!,
                    originalLine: originalLine,
                    originalLineSegmentsList: originalPerTypeLineSegmentsList,
                    convertToStraightRefTolerance:
                        getLineSimplifyEpsilonOnCanvasIncrease(),
                    accuracy: lineSimplifyEpsilonOnCanvas,
                    decimalPositions: currentDecimalPositions,
                  );

              /// When forcing straight lines, it's expected to have a higher
              /// amount of line segments after conversion + simplification.
              onlyUseSimplifiedSegmentsIfReducedAmountOfSegments = false;
            } else {
              simplifiedLineSegmentsList = mpSimplifyTHBezierLineSegments(
                originalPerTypeLineSegmentsList,
                accuracy: lineSimplifyEpsilonOnCanvas,
                decimalPositions: currentDecimalPositions,
              );
            }
          case THElementType.straightLineSegment:
            if (lineSimplificationMethod ==
                MPLineSimplificationMethod.forceBezier) {
              simplifiedLineSegmentsList =
                  mpConvertTHStraightToTHBezierLineSegments(
                    originalStraightLineSegmentsList:
                        originalPerTypeLineSegmentsList,
                    accuracy: lineSimplifyEpsilonOnCanvas,
                    decimalPositions: currentDecimalPositions,
                  );

              /// When forcing Bézier curves, it's expected to have a higher
              /// amount of line segments after conversion + simplification.
              onlyUseSimplifiedSegmentsIfReducedAmountOfSegments = false;
            } else {
              simplifiedLineSegmentsList =
                  MPStraightLineSimplificationAux.raumerDouglasPeuckerIterative(
                    originalStraightLineSegments:
                        originalPerTypeLineSegmentsList,
                    accuracy: lineSimplifyEpsilonOnCanvas,
                  );
            }
          default:
            throw Exception(
              'Error: Unsupported line segment type in mixed line at TH2FileEditElementEditController.simplifySelectedLines(). Type: ${typeLineSegments.type}',
            );
        }

        final List<THLineSegment> simplifiedLineSegmentsToAdd =
            (onlyUseSimplifiedSegmentsIfReducedAmountOfSegments &&
                (simplifiedLineSegmentsList.length >=
                    originalPerTypeLineSegmentsList.length))
            ? originalPerTypeLineSegmentsList
            : simplifiedLineSegmentsList;

        simplifiedLineSegmentsCompleteList.addAll(
          simplifiedLineSegmentsToAdd.skip(1).toList(),
        );

        final bool isForceConversion =
            (lineSimplificationMethod ==
                MPLineSimplificationMethod.forceBezier) ||
            (lineSimplificationMethod ==
                MPLineSimplificationMethod.forceStraight);

        if (isForceConversion ||
            (simplifiedLineSegmentsCompleteList.length <
                originalLineSegmentsList.length)) {
          final MPCommand simplifyCommand =
              MPElementEditAux.getReplaceLineSegmentsCommand(
                originalLine: originalLine,
                th2File: _originalFileForLineSimplification!,
                newLineSegmentsList: simplifiedLineSegmentsCompleteList,
                descriptionType: (lineCount == 1)
                    ? MPCommandDescriptionType.simplifyLine
                    : MPCommandDescriptionType.simplifyLines,
              );

          simplifyCommands.add(simplifyCommand);
        }
      }

      addOutdatedCloneMPID(originalLine.mpID);
    }

    if (simplifyCommands.isNotEmpty) {
      final MPCommand simplifyCommand =
          MPCommandFactory.multipleCommandsFromList(
            commandsList: simplifyCommands,
            descriptionType: lineCount == 1
                ? MPCommandDescriptionType.simplifyLine
                : MPCommandDescriptionType.simplifyLines,
            completionType:
                MPMultipleElementsCommandCompletionType.lineSegmentsEdited,
          );

      if (_isFirstLineSimplification) {
        _th2FileEditController.execute(simplifyCommand);
        _isFirstLineSimplification = false;
      } else {
        _th2FileEditController.executeSubstitutingLastUndo(simplifyCommand);
      }
    }

    updateControllersAfterElementEditPartial();
    updateControllersAfterElementEditFinal();

    _th2FileEditController.stateController.state.updateStatusBarMessage();

    return simplifyCommands.isNotEmpty;
  }

  List<MPSingleTypeLineSegmentList> groupLineSegmentsForSimplification({
    required THLine line,
    required TH2File th2File,
  }) {
    final List<MPSingleTypeLineSegmentList> segmentsByType = [];
    final List<THLineSegment> lineSegmentsComplete = line.getLineSegments(
      th2File,
    );

    if (lineSegmentsComplete.length <= 2) {
      return segmentsByType;
    }

    final Iterable<THLineSegment> lineSegmentsSkipFirst = lineSegmentsComplete
        .skip(1);

    THLineSegment lastLineSegment = lineSegmentsComplete.first;
    List<THLineSegment> currentTypeSegments = [lastLineSegment];
    THElementType? currentType = lineSegmentsSkipFirst.first.elementType;

    for (final THLineSegment segment in lineSegmentsSkipFirst) {
      final THElementType segmentType = segment.elementType;

      currentType ??= segmentType;

      if (segmentType != currentType) {
        segmentsByType.add(
          MPSingleTypeLineSegmentList(
            type: currentType,
            lineSegments: currentTypeSegments,
          ),
        );
        currentTypeSegments = [lastLineSegment];
        currentType = segmentType;
      } else if (_lineSegmentsWithOptionsToPreserveSimplification.contains(
        segment.mpID,
      )) {
        currentTypeSegments.add(segment);
        segmentsByType.add(
          MPSingleTypeLineSegmentList(
            type: currentType,
            lineSegments: currentTypeSegments,
          ),
        );
        currentTypeSegments = [];
        currentType = null;
      }

      currentTypeSegments.add(segment);
      lastLineSegment = segment;
    }

    if (currentTypeSegments.length > 1) {
      segmentsByType.add(
        MPSingleTypeLineSegmentList(
          type: currentType!,
          lineSegments: currentTypeSegments,
        ),
      );
    }

    return segmentsByType;
  }

  void resetOriginalFileForLineSimplification() {
    _originalFileForLineSimplification = null;
    _isFirstLineSimplification = true;
  }

  ({
    int beforeTotal,
    int beforeBezier,
    int beforeStraight,
    int afterTotal,
    int afterBezier,
    int afterStraight,
  })?
  getInteractiveLineSimplificationCounts() {
    if (_originalFileForLineSimplification == null) {
      return null;
    }

    int beforeTotal = 0;
    int beforeBezier = 0;
    int beforeStraight = 0;
    int afterTotal = 0;
    int afterBezier = 0;
    int afterStraight = 0;

    for (final MPSelectedElement selectedElement
        in _th2FileEditController
            .selectionController
            .mpSelectedElementsLogical
            .values) {
      if (selectedElement is! MPSelectedLine) {
        continue;
      }

      final int lineMPID = selectedElement.mpID;

      if (_originalFileForLineSimplification!.hasElementByMPID(lineMPID)) {
        final THLine originalLine = _originalFileForLineSimplification!
            .lineByMPID(lineMPID);
        final Iterable<THLineSegment> originalSegments = originalLine
            .getLineSegments(_originalFileForLineSimplification!)
            .skip(1);

        for (final THLineSegment seg in originalSegments) {
          beforeTotal++;

          if (seg is THBezierCurveLineSegment) {
            beforeBezier++;
          } else if (seg is THStraightLineSegment) {
            beforeStraight++;
          }
        }
      }

      if (_th2File.hasElementByMPID(lineMPID)) {
        final THLine currentLine = _th2File.lineByMPID(lineMPID);
        final Iterable<THLineSegment> currentSegments = currentLine
            .getLineSegments(_th2File)
            .skip(1);

        for (final THLineSegment seg in currentSegments) {
          afterTotal++;

          if (seg is THBezierCurveLineSegment) {
            afterBezier++;
          } else if (seg is THStraightLineSegment) {
            afterStraight++;
          }
        }
      }
    }

    return (
      beforeTotal: beforeTotal,
      beforeBezier: beforeBezier,
      beforeStraight: beforeStraight,
      afterTotal: afterTotal,
      afterBezier: afterBezier,
      afterStraight: afterStraight,
    );
  }

  double getLineSimplifyEpsilonOnCanvasIncrease() {
    return mpLineSimplifyEpsilonOnScreen / _th2FileEditController.canvasScale;
  }

  void _markStationCacheDirtyForAddedElement(THElement newElement) {
    if (_isVisibleTherionStationPoint(newElement)) {
      _markTherionStationPointNameCoordinateCacheDirty();
    }
  }

  void _markStationCacheDirtyForRemovedElement(THElement removedElement) {
    if (_isVisibleTherionStationPoint(removedElement)) {
      _markTherionStationPointNameCoordinateCacheDirty();
    }
  }

  void _markStationCacheDirtyForSubstitutedElements({
    required THElement? originalElement,
    required THElement modifiedElement,
  }) {
    if (_isVisibleTherionStationPoint(originalElement) ||
        _isVisibleTherionStationPoint(modifiedElement)) {
      _markTherionStationPointNameCoordinateCacheDirty();
    }

    final MPRuntimeXVIImageInsertConfigMixin? originalXVIImage =
        (originalElement is MPRuntimeXVIImageInsertConfigMixin)
        ? originalElement
        : null;
    final MPRuntimeXVIImageInsertConfigMixin? modifiedXVIImage =
        (modifiedElement is MPRuntimeXVIImageInsertConfigMixin)
        ? modifiedElement
        : null;

    if ((originalXVIImage != null) || (modifiedXVIImage != null)) {
      _markXVIStationPointNameCoordinateCacheDirty();
    }
  }

  bool _isVisibleTherionStationPoint(THElement? element) {
    if (element == null) {
      return false;
    }

    if (element is! THPoint) {
      return false;
    }

    if (element.pointType != THPointType.station) {
      return false;
    }

    final String? stationName = MPCommandOptionAux.getName(element);

    if ((stationName == null) || stationName.isEmpty) {
      return false;
    }

    if (!_th2FileEditController.hideElementController.isElementVisible(
      element.mpID,
    )) {
      return false;
    }

    if (!_th2FileEditController.hideElementController.isScrapVisible(
      element.parentMPID,
    )) {
      return false;
    }

    return true;
  }

  void _markTherionStationPointNameCoordinateCacheDirty() {
    _th2FileEditController.userInteractionController
        .markTherionStationPointNameCoordinateCacheDirty();
  }

  void _markXVIStationPointNameCoordinateCacheDirty() {
    _th2FileEditController.userInteractionController
        .markXVIStationPointNameCoordinateCacheDirty();
  }

  void prepareLineSimplificationInfo() {
    final double lineSimplifyEpsilonOnCanvasIncrease =
        getLineSimplifyEpsilonOnCanvasIncrease();

    if (_originalFileForLineSimplification == null) {
      _originalFileForLineSimplification = _th2File.copyWith();
      _lineSimplifyEpsilonOnCanvas = lineSimplifyEpsilonOnCanvasIncrease;
      _isFirstLineSimplification = true;
    } else {
      _lineSimplifyEpsilonOnCanvas += lineSimplifyEpsilonOnCanvasIncrease;
    }
  }

  void setLineSimplificationMethod(MPLineSimplificationMethod newMethod) {
    if (_lineSimplificationMethod == newMethod) {
      return;
    }

    _lineSimplificationMethod = newMethod;
    resetOriginalFileForLineSimplification();
  }

  @action
  void applySetLinePointOrientationLSize({
    required double? orientation,
    required double? lSize,
  }) {
    final List<MPCommand> setCommands = [];
    final Iterable<MPSelectedEndControlPoint> selectedEndPoints =
        _th2FileEditController
            .selectionController
            .selectedEndControlPoints
            .values;

    for (final MPSelectedEndControlPoint selectedEndPoint
        in selectedEndPoints) {
      final THLineSegment lineSegment = selectedEndPoint.originalElementClone;
      final int lineSegmentMPID = lineSegment.mpID;

      if (lSize != null) {
        final THLSizeCommandOption lsizeOption =
            THLSizeCommandOption.fromString(
              parentMPID: lineSegmentMPID,
              number: lSize.toStringAsFixed(mpLSizeOptionDecimalPlaces),
            );

        setCommands.add(MPSetOptionToElementCommand(toOption: lsizeOption));
      }

      if (orientation != null) {
        final THOrientationCommandOption orientationOption =
            THOrientationCommandOption.fromString(
              parentMPID: lineSegmentMPID,
              azimuth: orientation.toStringAsFixed(
                mpOrientationOptionDecimalPlaces,
              ),
            );

        setCommands.add(
          MPSetOptionToElementCommand(toOption: orientationOption),
        );
      }
    }

    if (setCommands.isEmpty) {
      return;
    }

    final MPCommand setAllCommand = MPCommandFactory.multipleCommandsFromList(
      commandsList: setCommands,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
      descriptionType: MPCommandDescriptionType.setOptionToElements,
    );

    _th2FileEditController.execute(setAllCommand);
    updateControllersAfterElementEditPartial();
    updateControllersAfterElementEditFinal();
    _th2FileEditController.triggerEditLineRedraw();
  }

  @action
  void setLinePointOrientationValue(double? orientation) {
    if ((_linePointOrientation != null) &&
        (orientation != null) &&
        MPNumericAux.nearlyEqual(_linePointOrientation!, orientation)) {
      return;
    }

    _linePointOrientation = orientation;
  }

  @action
  void setLinePointLSizeValue(double? lSize) {
    if ((_linePointLSize != null) &&
        (lSize != null) &&
        MPNumericAux.nearlyEqual(_linePointLSize!, lSize)) {
      return;
    }

    _linePointLSize = lSize;
  }

  @action
  void setLinePointLSizeAndOrientation({
    required double? orientation,
    required double? lSize,
  }) {
    if ((_linePointLSize != null) &&
        (lSize != null) &&
        MPNumericAux.nearlyEqual(_linePointLSize!, lSize) &&
        (_linePointOrientation != null) &&
        (orientation != null) &&
        MPNumericAux.nearlyEqual(_linePointOrientation!, orientation)) {
      return;
    }

    _linePointOrientation = orientation;
    _linePointLSize = lSize;
  }

  void setCommandOptionTypeBeingEdited(THCommandOptionType? value) {
    if (_currentOptionTypeBeingEdited == value) {
      return;
    }

    final THCommandOptionType? previousOptionType =
        _currentOptionTypeBeingEdited;

    _currentOptionTypeBeingEdited = value;

    _th2FileEditController.stateController.state
        .onChangeCommandOptionTypeEdited(
          newOptionType: _currentOptionTypeBeingEdited,
          previousOptionType: previousOptionType,
        );
  }

  bool getCurrentAllImagesVisibility() {
    final Iterable<MPRuntimeImageInsertConfigMixin> allImages = _th2File
        .getImages();

    bool? currentVisibility;

    for (final MPRuntimeImageInsertConfigMixin image in allImages) {
      if (currentVisibility == null) {
        currentVisibility = image.isVisible;
      } else if (image.isVisible != currentVisibility) {
        return _allImagesVisibility;
      }
    }

    return currentVisibility ?? _allImagesVisibility;
  }

  THCommandOptionType? get currentOptionTypeBeingEdited {
    return _currentOptionTypeBeingEdited;
  }
}

class MPTypeUsed {
  final MPPLATypeSubtype type;

  int count = 1;
  DateTime lastUsed = DateTime.now();

  MPTypeUsed(this.type);

  void incrementUse() {
    count++;
    lastUsed = DateTime.now();
  }
}

enum MPLineTypePerLineSegmentType { bezierCurve, mixed, straight }

enum MPLineSimplificationMethod {
  forceStraight,
  forceBezier,
  keepOriginalTypes,
}
