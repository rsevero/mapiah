// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/painting.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/types/mp_pla_type_subtype.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_user_interaction_controller.g.dart';

/// This controller is responsible for handling user interactions. Its methods
/// are called by the widgets that are responsible for user interactions. These
/// methods should create and execute MPCommands.
class TH2FileEditUserInteractionController = TH2FileEditUserInteractionControllerBase
    with _$TH2FileEditUserInteractionController;

abstract class TH2FileEditUserInteractionControllerBase with Store {
  @readonly
  TH2File _th2File;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditUserInteractionControllerBase(this._th2FileEditController)
    : _th2File = _th2FileEditController.th2File;

  Path _compassPath = Path();

  void setCompassPath(Path path) {
    _compassPath = path;
  }

  Path get compassPath => _compassPath;

  @action
  void prepareSetOption({
    required THCommandOption? option,
    required THCommandOptionType optionType,
  }) {
    if (option == null) {
      _prepareUnsetOption(optionType);
    } else {
      _prepareSetOption(option);
    }

    _th2FileEditController.stateController.state.updateStatusBarMessage();
    _th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.optionChoices,
      false,
    );
  }

  void _prepareSetOption(THCommandOption option) {
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final List<THElement> candidateElementsForNewOption = [];
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final bool isLineSegmentOption =
        _th2FileEditController.optionEditController.currentOptionElementsType ==
        MPOptionElementType.lineSegment;
    final Iterable<MPSelectedElement> selectedElements = isLineSegmentOption
        ? selectionController.selectedEndControlPoints.values
        : selectionController.mpSelectedElementsLogical.values;

    for (final MPSelectedElement selectedElement in selectedElements) {
      candidateElementsForNewOption.add(selectedElement.originalElementClone);
    }

    if (candidateElementsForNewOption.isEmpty) {
      if (_th2FileEditController.optionEditController.isDefaultOptionsMode) {
        final THElementType elementType = _th2FileEditController
            .optionEditController
            .defaultOptionsElementType;

        _th2FileEditController.defaultOptionsController.setDefault(
          elementType,
          option.copyWith(parentMPID: -1, originalLineInTH2File: ''),
        );
        _th2FileEditController.optionEditController
            .updateDefaultOptionsStateMap();
      }
    } else {
      final List<THElement> actualElementsForNewOption = [];

      option.setTH2File(_th2File);

      for (final THElement element in candidateElementsForNewOption) {
        element.setTH2File(_th2File);
        if ((element is THHasOptionsMixin) &&
            (isCtrlPressed ||
                MPCommandOptionAux.elementTypeSupportsOptionType(
                  element,
                  option.type,
                )) &&
            (!element.hasOption(option.type) ||
                element.getOption(option.type) != option)) {
          actualElementsForNewOption.add(element);

          if (option is THSubtypeCommandOption) {
            _setLastPLATypeSubtypeFromElementAndSubtype(
              element: element,
              subtype: option.subtype,
            );
          }
        }
      }

      if (actualElementsForNewOption.isNotEmpty) {
        final MPCommand addOptionCommand =
            (option.type == THCommandOptionType.attr)
            ? MPCommandFactory.setAttrOptionOnElements(
                elements: actualElementsForNewOption,
                toOption: option as THAttrCommandOption,
                th2File: _th2FileEditController.th2File,
              )
            : MPCommandFactory.setOptionOnElements(
                elements: actualElementsForNewOption,
                toOption: option,
                th2File: _th2FileEditController.th2File,
              );

        _th2FileEditController.execute(addOptionCommand);

        if (isLineSegmentOption) {
          _th2FileEditController.optionEditController
              .updateElementOptionMapForLineSegments();
        } else {
          _th2FileEditController.optionEditController.updateOptionStateMap();
        }
      }
    }
  }

  void _setLastPLATypeSubtypeFromElementAndSubtype({
    required THElement element,
    required String subtype,
  }) {
    if (element is! THHasPLATypeMixin) {
      return;
    }

    final TH2FileEditElementEditController elementEditController =
        _th2FileEditController.elementEditController;

    switch (element) {
      case THPoint point:
        elementEditController.setUsedPointType(
          pointType: point.pointType.name,
          pointSubtype: subtype,
        );
      case THLine line:
        elementEditController.setUsedLineType(
          lineType: line.lineType.name,
          lineSubtype: subtype,
        );
      case THArea area:
        elementEditController.setUsedAreaType(
          areaType: area.areaType.name,
          areaSubtype: subtype,
        );
    }
  }

  void prepareUnsetAttrOption({required String attrName}) {
    final List<THElement> candidateElementsForNewOption = [];
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final bool isLineSegmentOption =
        _th2FileEditController.optionEditController.currentOptionElementsType ==
        MPOptionElementType.lineSegment;
    final Iterable<MPSelectedElement> selectedElements = isLineSegmentOption
        ? selectionController.selectedEndControlPoints.values
        : selectionController.mpSelectedElementsLogical.values;

    for (final MPSelectedElement selectedElement in selectedElements) {
      candidateElementsForNewOption.add(selectedElement.originalElementClone);
    }

    if (candidateElementsForNewOption.isEmpty) {
      return;
    } else {
      final List<int> parentMPIDs = [];

      for (final element in candidateElementsForNewOption) {
        if ((element is THHasOptionsMixin) && element.hasAttrOption(attrName)) {
          parentMPIDs.add(element.mpID);
        }
      }

      if (parentMPIDs.isNotEmpty) {
        final MPCommand removeOptionCommand =
            MPCommandFactory.removeAttrOptionFromElements(
              attrName: attrName,
              parentMPIDs: parentMPIDs,
              th2File: _th2FileEditController.th2File,
            );

        _th2FileEditController.execute(removeOptionCommand);

        if (isLineSegmentOption) {
          _th2FileEditController.optionEditController
              .updateElementOptionMapForLineSegments();
        } else {
          _th2FileEditController.optionEditController.updateOptionStateMap();
        }
      }
    }
  }

  void _prepareUnsetOption(THCommandOptionType optionType) {
    final List<THElement> candidateElementsForNewOption = [];
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final bool isLineSegmentOption =
        _th2FileEditController.optionEditController.currentOptionElementsType ==
        MPOptionElementType.lineSegment;
    final Iterable<MPSelectedElement> selectedElements = isLineSegmentOption
        ? selectionController.selectedEndControlPoints.values
        : selectionController.mpSelectedElementsLogical.values;

    for (final MPSelectedElement selectedElement in selectedElements) {
      candidateElementsForNewOption.add(selectedElement.originalElementClone);
    }

    if (candidateElementsForNewOption.isEmpty) {
      if (_th2FileEditController.optionEditController.isDefaultOptionsMode) {
        final THElementType elementType = _th2FileEditController
            .optionEditController
            .defaultOptionsElementType;

        _th2FileEditController.defaultOptionsController.removeDefault(
          elementType,
          optionType,
        );
        _th2FileEditController.optionEditController
            .updateDefaultOptionsStateMap();
      }
    } else {
      final List<int> parentMPIDs = [];

      for (final element in candidateElementsForNewOption) {
        if ((element is THHasOptionsMixin) && element.hasOption(optionType)) {
          parentMPIDs.add(element.mpID);

          if (optionType is THSubtypeCommandOption) {
            _setLastPLATypeSubtypeFromElementAndSubtype(
              element: element,
              subtype: '',
            );
          }
        }
      }

      if (parentMPIDs.isNotEmpty) {
        final MPCommand removeOptionCommand =
            MPCommandFactory.removeOptionFromElements(
              optionType: optionType,
              parentMPIDs: parentMPIDs,
              th2File: _th2FileEditController.th2File,
            );

        _th2FileEditController.execute(removeOptionCommand);

        if (isLineSegmentOption) {
          _th2FileEditController.optionEditController
              .updateElementOptionMapForLineSegments();
        } else {
          _th2FileEditController.optionEditController.updateOptionStateMap();
        }
      }
    }
  }

  @action
  void prepareSetMultipleOptionChoice({
    required THCommandOptionType optionType,
    required String choice,
  }) {
    if (!THCommandOption.isMultipleChoiceOptions(optionType)) {
      return;
    }

    if (choice == mpUnsetOptionID) {
      _prepareUnsetMultipleOptionChoice(optionType);
    } else {
      _prepareSetMultipleOptionChoice(optionType, choice);
    }

    _th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.optionChoices,
      false,
    );
    _th2FileEditController.elementEditController
        .updateControllersAfterElementEditPartial();
    _th2FileEditController.triggerSelectedElementsRedraw();
    _th2FileEditController.triggerEditLineRedraw();
  }

  void _prepareSetMultipleOptionChoice(
    THCommandOptionType optionType,
    String choice,
  ) {
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final bool isLineSegmentOption =
        _th2FileEditController.optionEditController.currentOptionElementsType ==
        MPOptionElementType.lineSegment;
    final Iterable<MPSelectedElement> selectedElements = isLineSegmentOption
        ? selectionController.selectedEndControlPoints.values
        : selectionController.mpSelectedElementsLogical.values;

    List<MPCommand> addOptionCommands = [];

    if (selectedElements.isEmpty) {
      if (_th2FileEditController.optionEditController.isDefaultOptionsMode) {
        final THElementType elementType = _th2FileEditController
            .optionEditController
            .defaultOptionsElementType;
        final THCommandOption option = THCommandOption.byType(
          parentMPID: -1,
          type: optionType,
          value: choice,
        );

        _th2FileEditController.defaultOptionsController.setDefault(
          elementType,
          option.copyWith(originalLineInTH2File: ''),
        );
        _th2FileEditController.optionEditController
            .updateDefaultOptionsStateMap();
      }
    } else {
      final List<THElement> elements = [];

      for (final MPSelectedElement mpSelectedElement in selectedElements) {
        final THElement element = mpSelectedElement.originalElementClone;

        element.setTH2File(_th2File);

        if ((element is THHasOptionsMixin) &&
            (isCtrlPressed ||
                MPCommandOptionAux.elementTypeSupportsOptionType(
                  element,
                  optionType,
                )) &&
            (!element.hasOption(optionType) ||
                ((element.getOption(optionType)!
                            as THMultipleChoiceCommandOption)
                        .choice
                        .name !=
                    choice))) {
          elements.add(element);

          /// If the user is turning on the smooth option for some segments,
          /// they should be smoothed.
          if ((optionType == THCommandOptionType.smooth) &&
              (choice == 'on') &&
              (element is THLineSegment)) {
            final MPCommand? smoothCommand = _th2FileEditController
                .elementEditController
                .getSmoothLineSegmentsCommand(element);

            if (smoothCommand != null) {
              addOptionCommands.add(smoothCommand);
            }
          }
        }
      }

      if (elements.isNotEmpty) {
        addOptionCommands.insert(
          0,
          MPCommandFactory.setOptionOnElements(
            elements: elements,
            toOption: THCommandOption.byType(
              /// This parentMPID will be replaced in the command factory.
              parentMPID: _th2File.mpID,
              type: optionType,
              value: choice,
            ),
            th2File: _th2File,
          ),
        );
      }

      if (addOptionCommands.isNotEmpty) {
        final MPCommand addOptionFinalCommand = (addOptionCommands.length == 1)
            ? addOptionCommands.first
            : MPMultipleElementsCommand.forCWJM(
                commandsList: addOptionCommands,
                completionType:
                    MPMultipleElementsCommandCompletionType.optionsEdited,
                descriptionType: elements.length == 1
                    ? MPCommandDescriptionType.setOptionToElement
                    : MPCommandDescriptionType.setOptionToElements,
              );

        _th2FileEditController.execute(addOptionFinalCommand);

        if (isLineSegmentOption) {
          _th2FileEditController.optionEditController
              .updateElementOptionMapForLineSegments();
        } else {
          _th2FileEditController.optionEditController.updateOptionStateMap();
        }
      }
    }
  }

  void _prepareUnsetMultipleOptionChoice(THCommandOptionType optionType) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final bool isLineSegmentOption =
        _th2FileEditController.optionEditController.currentOptionElementsType ==
        MPOptionElementType.lineSegment;
    final Iterable<MPSelectedElement> selectedElements = isLineSegmentOption
        ? selectionController.selectedEndControlPoints.values
        : selectionController.mpSelectedElementsLogical.values;

    if (selectedElements.isEmpty) {
      if (_th2FileEditController.optionEditController.isDefaultOptionsMode) {
        final THElementType elementType = _th2FileEditController
            .optionEditController
            .defaultOptionsElementType;

        _th2FileEditController.defaultOptionsController.removeDefault(
          elementType,
          optionType,
        );
        _th2FileEditController.optionEditController
            .updateDefaultOptionsStateMap();
      }
    } else {
      final List<int> parentMPIDs = [];

      for (final mpSelectedElement in selectedElements) {
        final THElement element = mpSelectedElement.originalElementClone;

        if ((element is THHasOptionsMixin) && element.hasOption(optionType)) {
          parentMPIDs.add(element.mpID);
        }
      }

      if (parentMPIDs.isNotEmpty) {
        final MPCommand removeOptionCommand =
            MPCommandFactory.removeOptionFromElements(
              optionType: optionType,
              parentMPIDs: parentMPIDs,
              th2File: _th2FileEditController.th2File,
            );

        _th2FileEditController.execute(removeOptionCommand);

        if (isLineSegmentOption) {
          _th2FileEditController.optionEditController
              .updateElementOptionMapForLineSegments();
        } else {
          _th2FileEditController.optionEditController.updateOptionStateMap();
        }
      }
    }
  }

  @action
  void prepareSetLineSegmentType({
    required MPSelectedLineSegmentType selectedLineSegmentType,
  }) {
    if ((selectedLineSegmentType == MPSelectedLineSegmentType.mixed) ||
        (selectedLineSegmentType == MPSelectedLineSegmentType.none)) {
      return;
    }

    final TH2File th2File = _th2FileEditController.th2File;
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final Iterable<MPSelectedEndControlPoint> selectedEndControlPoints =
        selectionController.selectedEndControlPoints.values;

    if (selectedEndControlPoints.isEmpty) {
      return;
    }

    final THLine thLine = th2File.lineByMPID(
      selectedEndControlPoints.first.originalElementClone.parentMPID,
    );
    final Map<int, int> lineSegmentsPositionsByMPID = thLine
        .getLineSegmentPositionsByLineSegmentMPID(th2File);
    final List<THLineSegment> willChangeLineSegments = [];
    final THElementType elementType =
        selectedLineSegmentType ==
            MPSelectedLineSegmentType.bezierCurveLineSegment
        ? THElementType.bezierCurveLineSegment
        : THElementType.straightLineSegment;

    for (final MPSelectedEndControlPoint selectedEndControlPoint
        in selectedEndControlPoints) {
      final int lineSegmentMPID = selectedEndControlPoint.mpID;

      if (!lineSegmentsPositionsByMPID.containsKey(lineSegmentMPID) ||
          (lineSegmentsPositionsByMPID[lineSegmentMPID]! == 0)) {
        continue;
      }

      final THLineSegment lineSegment = th2File.lineSegmentByMPID(
        lineSegmentMPID,
      );

      if ((lineSegment.elementType == elementType) ||
          willChangeLineSegments.contains(lineSegment)) {
        continue;
      }

      willChangeLineSegments.add(lineSegment);
    }

    if (willChangeLineSegments.isEmpty) {
      return;
    }

    final MPCommand setLineSegmentsTypeCommand =
        MPCommandFactory.setLineSegmentsType(
          selectedLineSegmentType: selectedLineSegmentType,
          th2File: th2File,
          originalLineSegments: willChangeLineSegments,
        );

    _th2FileEditController.execute(setLineSegmentsTypeCommand);
    selectionController.setSelectedEndPointsByMPID(
      willChangeLineSegments.map((e) => e.mpID),
    );
    selectionController.updateSelectableEndAndControlPoints();
    _th2FileEditController.triggerEditLineRedraw();
    _th2FileEditController.triggerOptionsListRedraw();
  }

  void prepareConvertLineSegmentsType({
    required MPSelectedLineSegmentType selectedLineSegmentType,
  }) {
    if ((selectedLineSegmentType == MPSelectedLineSegmentType.mixed) ||
        (selectedLineSegmentType == MPSelectedLineSegmentType.none)) {
      return;
    }

    if (_th2FileEditController.isInEditSingleLineState) {
      prepareSetLineSegmentType(
        selectedLineSegmentType: selectedLineSegmentType,
      );

      return;
    }

    prepareSetSelectedLinesLineSegmentType(
      selectedLineSegmentType: selectedLineSegmentType,
    );
  }

  void prepareSetSelectedLinesLineSegmentType({
    required MPSelectedLineSegmentType selectedLineSegmentType,
  }) {
    if ((selectedLineSegmentType == MPSelectedLineSegmentType.mixed) ||
        (selectedLineSegmentType == MPSelectedLineSegmentType.none)) {
      return;
    }

    final THElementType targetElementType =
        selectedLineSegmentType ==
            MPSelectedLineSegmentType.bezierCurveLineSegment
        ? THElementType.bezierCurveLineSegment
        : THElementType.straightLineSegment;
    final List<MPCommand> conversionCommands = [];
    final Iterable<MPSelectedElement> selectedElements = _th2FileEditController
        .selectionController
        .mpSelectedElementsLogical
        .values;

    for (final MPSelectedElement selectedElement in selectedElements) {
      if (selectedElement is! MPSelectedLine) {
        continue;
      }

      final THLine line = _th2File.lineByMPID(selectedElement.mpID);
      final List<THLineSegment> lineSegments = line.getLineSegments(_th2File);
      final List<THLineSegment> lineSegmentsToConvert = [];

      for (final THLineSegment lineSegment in lineSegments.skip(1)) {
        if (lineSegment.elementType == targetElementType) {
          continue;
        }

        lineSegmentsToConvert.add(lineSegment);
      }

      if (lineSegmentsToConvert.isEmpty) {
        continue;
      }

      conversionCommands.add(
        MPCommandFactory.setLineSegmentsType(
          selectedLineSegmentType: selectedLineSegmentType,
          th2File: _th2File,
          originalLineSegments: lineSegmentsToConvert,
        ),
      );
    }

    if (conversionCommands.isEmpty) {
      return;
    }

    final MPCommand conversionCommand =
        MPCommandFactory.multipleCommandsFromList(
          commandsList: conversionCommands,
          descriptionType: MPCommandDescriptionType.editLineSegmentsType,
          completionType:
              MPMultipleElementsCommandCompletionType.lineSegmentsEdited,
        );

    _th2FileEditController.execute(conversionCommand);
    _th2FileEditController.triggerSelectedElementsRedraw();
    _th2FileEditController.triggerOptionsListRedraw();
  }

  @action
  void prepareSetPLAType({
    required THElementType elementType,
    required String newPLAType,
  }) {
    final Iterable<MPSelectedElement> mpSelectedElements =
        _th2FileEditController
            .selectionController
            .mpSelectedElementsLogical
            .values;
    final TH2FileEditElementEditController elementEditController =
        _th2FileEditController.elementEditController;
    final MPPLAType pla = switch (elementType) {
      THElementType.area => MPPLAType.area,
      THElementType.line => MPPLAType.line,
      THElementType.point => MPPLAType.point,
      _ => throw Exception(
        'Unsupported element type $elementType in TH2FileEditUserInteractionController.prepareSetPLAType().',
      ),
    };
    final MPPLATypeSubtype typeSubtype = MPCommandOptionAux.getPLATypeSubtype(
      pla: pla,
      typeSubtypeID: newPLAType,
    );

    MPCommand setPLATypeCommand;
    List<int> mpIDs = [];

    switch (elementType) {
      case THElementType.area:
        for (final MPSelectedElement mpSelectedElement in mpSelectedElements) {
          final THElement originalElementClone =
              mpSelectedElement.originalElementClone;

          if ((originalElementClone is! THArea) ||
              MPCommandOptionAux.isSamePLATypeSubtype(
                element: originalElementClone,
                plaTypeSubtype: newPLAType,
              )) {
            continue;
          }
          mpIDs.add(originalElementClone.mpID);
          elementEditController.setUsedAreaType(
            areaType: typeSubtype.type,
            areaSubtype: typeSubtype.subtype,
          );
        }

        if (mpIDs.isEmpty) {
          return;
        }

        setPLATypeCommand = MPCommandFactory.editAreasTypeSubtype(
          areaMPIDs: mpIDs,
          newAreaTypeSubtype: newPLAType,
          th2File: _th2File,
        );

      case THElementType.line:
        for (final MPSelectedElement mpSelectedElement in mpSelectedElements) {
          final THElement originalElementClone =
              mpSelectedElement.originalElementClone;

          if ((originalElementClone is! THLine) ||
              MPCommandOptionAux.isSamePLATypeSubtype(
                element: originalElementClone,
                plaTypeSubtype: newPLAType,
              )) {
            continue;
          }
          mpIDs.add(originalElementClone.mpID);
          elementEditController.setUsedLineType(
            lineType: typeSubtype.type,
            lineSubtype: typeSubtype.subtype,
          );
        }

        if (mpIDs.isEmpty) {
          return;
        }

        setPLATypeCommand = MPCommandFactory.editLinesTypeSubtype(
          lineMPIDs: mpIDs,
          newLineTypeSubtype: newPLAType,
          th2File: _th2File,
        );
      case THElementType.point:
        for (final MPSelectedElement mpSelectedElement in mpSelectedElements) {
          final THElement originalElementClone =
              mpSelectedElement.originalElementClone;

          if ((originalElementClone is! THPoint) ||
              MPCommandOptionAux.isSamePLATypeSubtype(
                element: originalElementClone,
                plaTypeSubtype: newPLAType,
              )) {
            continue;
          }
          mpIDs.add(originalElementClone.mpID);
          elementEditController.setUsedPointType(
            pointType: typeSubtype.type,
            pointSubtype: typeSubtype.subtype,
          );
        }

        if (mpIDs.isEmpty) {
          return;
        }

        setPLATypeCommand = MPCommandFactory.editPointsTypeSubtype(
          pointMPIDs: mpIDs,
          newPointTypeSubtype: newPLAType,
          th2File: _th2File,
        );

        final bool willSetStationNames =
            THPointType.fromString(typeSubtype.type) == THPointType.station;

        _th2FileEditController.execute(setPLATypeCommand);

        if (willSetStationNames) {
          final List<THStationNameCommandOption> stationNameOptions =
              elementEditController.getNextStationNameOptions(
                parentMPIDs: mpIDs,
              );
          final List<MPCommand> setStationNameCommands = [];

          for (final THStationNameCommandOption stationNameOption
              in stationNameOptions) {
            setStationNameCommands.add(
              MPSetOptionToElementCommand(toOption: stationNameOption),
            );
          }

          if (setStationNameCommands.isNotEmpty) {
            final MPCommand setStationNamesCommand =
                MPCommandFactory.multipleCommandsFromList(
                  commandsList: setStationNameCommands,
                  descriptionType: MPCommandDescriptionType.setOptionToElements,
                  completionType:
                      MPMultipleElementsCommandCompletionType.optionsEdited,
                );

            _th2FileEditController.execute(setStationNamesCommand);
          }
        }

        _th2FileEditController.optionEditController.updateOptionStateMap();
        _th2FileEditController.triggerSelectedElementsRedraw();

        return;
      default:
        return;
    }

    _th2FileEditController.execute(setPLATypeCommand);
    _th2FileEditController.optionEditController.updateOptionStateMap();
    _th2FileEditController.triggerSelectedElementsRedraw();
  }

  @action
  void prepareRemoveAreaBorderTHID(int areaBorderTHIDMPID) {
    final THAreaBorderTHID areaBorderTHID = _th2File.areaBorderTHIDByMPID(
      areaBorderTHIDMPID,
    );
    final int areaMPID = areaBorderTHID.parentMPID;
    final THArea area = _th2File.areaByMPID(areaMPID);
    final MPCommand removeAreaBorderTHIDCommand =
        (area.getAreaBorderTHIDMPIDs(_th2File).length == 1)
        ? MPCommandFactory.removeAreaFromExisting(
            existingAreaMPID: areaMPID,
            th2File: _th2File,
          )
        : MPCommandFactory.removeAreaBorderTHIDFromExisting(
            existingAreaBorderTHIDMPID: areaBorderTHIDMPID,
            th2File: _th2File,
          );

    _th2FileEditController.execute(removeAreaBorderTHIDCommand);
    _th2FileEditController.triggerAllElementsRedraw();
    _th2FileEditController.triggerOptionsListRedraw();
  }

  @action
  void prepareAddAreaBorderTHID() {
    _th2FileEditController.stateController.onButtonPressed(
      MPButtonType.addLineToArea,
    );
  }
}
