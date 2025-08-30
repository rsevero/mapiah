import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_edit_element_aux.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_user_interaction_controller.g.dart';

/// This controller is responsible for handling user interactions. Its methods
/// are called by the widgets that are responsible for user interactions. These
/// methods should create and execute MPCommands.
class TH2FileEditUserInteractionController = TH2FileEditUserInteractionControllerBase
    with _$TH2FileEditUserInteractionController;

abstract class TH2FileEditUserInteractionControllerBase with Store {
  @readonly
  THFile _thFile;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditUserInteractionControllerBase(this._th2FileEditController)
    : _thFile = _th2FileEditController.thFile;

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
  }

  void _prepareSetOption(THCommandOption option) {
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final List<THElement> candidateElementsForNewOption = [];
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final Iterable<MPSelectedElement> selectedElements =
        _th2FileEditController.optionEditController.optionsEditForLineSegments
        ? selectionController.selectedEndControlPoints.values
        : selectionController.mpSelectedElementsLogical.values;

    for (final MPSelectedElement selectedElement in selectedElements) {
      candidateElementsForNewOption.add(selectedElement.originalElementClone);
    }

    if (candidateElementsForNewOption.isEmpty) {
      /// TODO: set per session option default values.
    } else if (candidateElementsForNewOption.length == 1) {
      final THElement selectedElement = candidateElementsForNewOption.first;

      if ((selectedElement is! THHasOptionsMixin) ||
          (!isCtrlPressed &&
              !MPCommandOptionAux.elementTypeSupportsOptionType(
                selectedElement,
                option.type,
              )) ||
          (selectedElement.hasOption(option.type) &&
              (option.type != THCommandOptionType.attr) &&
              selectedElement.optionByType(option.type) == option)) {
        return;
      }

      final MPCommand setOptionCommand =
          (option.type == THCommandOptionType.attr)
          ? MPSetAttrOptionToElementCommand(
              option:
                  option.copyWith(parentMPID: selectedElement.mpID)
                      as THAttrCommandOption,
              currentOriginalLineInTH2File:
                  selectedElement.originalLineInTH2File,
            )
          : MPSetOptionToElementCommand(
              option: option.copyWith(parentMPID: selectedElement.mpID),
              currentOriginalLineInTH2File:
                  selectedElement.originalLineInTH2File,
            );

      _th2FileEditController.execute(setOptionCommand);
    } else {
      final List<THElement> actualElementsForNewOption = [];

      for (final THElement element in candidateElementsForNewOption) {
        if ((element is THHasOptionsMixin) &&
            (isCtrlPressed ||
                MPCommandOptionAux.elementTypeSupportsOptionType(
                  element,
                  option.type,
                )) &&
            (!element.hasOption(option.type) ||
                element.optionByType(option.type) != option)) {
          actualElementsForNewOption.add(element);
        }
      }

      if (actualElementsForNewOption.isNotEmpty) {
        final MPCommand addOptionCommand =
            (option.type == THCommandOptionType.attr)
            ? MPCommandFactory.setAttrOptionOnElements(
                elements: actualElementsForNewOption,
                option: option as THAttrCommandOption,
                thFile: _th2FileEditController.thFile,
              )
            : MPCommandFactory.setOptionOnElements(
                elements: actualElementsForNewOption,
                option: option,
                thFile: _th2FileEditController.thFile,
              );

        _th2FileEditController.execute(addOptionCommand);
      }
    }
  }

  void prepareUnsetAttrOption({required String attrName}) {
    final List<THElement> candidateElementsForNewOption = [];
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final Iterable<MPSelectedElement> selectedElements =
        _th2FileEditController.optionEditController.optionsEditForLineSegments
        ? selectionController.selectedEndControlPoints.values
        : selectionController.mpSelectedElementsLogical.values;

    for (final selectedElement in selectedElements) {
      candidateElementsForNewOption.add(selectedElement.originalElementClone);
    }

    if (candidateElementsForNewOption.isEmpty) {
      return;
    } else if (candidateElementsForNewOption.length == 1) {
      final THElement selectedElement = candidateElementsForNewOption.first;

      if ((selectedElement is! THHasOptionsMixin) ||
          (!selectedElement.hasAttrOption(attrName))) {
        return;
      }

      final MPRemoveAttrOptionFromElementCommand removeOptionCommand =
          MPRemoveAttrOptionFromElementCommand(
            attrName: attrName,
            parentMPID: selectedElement.mpID,
            currentOriginalLineInTH2File: _thFile
                .elementByMPID(selectedElement.mpID)
                .originalLineInTH2File,
          );

      _th2FileEditController.execute(removeOptionCommand);
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
              thFile: _th2FileEditController.thFile,
            );

        _th2FileEditController.execute(removeOptionCommand);
      }
    }
  }

  void _prepareUnsetOption(THCommandOptionType optionType) {
    final List<THElement> candidateElementsForNewOption = [];
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final Iterable<MPSelectedElement> selectedElements =
        _th2FileEditController.optionEditController.optionsEditForLineSegments
        ? selectionController.selectedEndControlPoints.values
        : selectionController.mpSelectedElementsLogical.values;

    for (final selectedElement in selectedElements) {
      candidateElementsForNewOption.add(selectedElement.originalElementClone);
    }

    if (candidateElementsForNewOption.isEmpty) {
      /// TODO: set per session option default values.
    } else if (candidateElementsForNewOption.length == 1) {
      final THElement selectedElement = candidateElementsForNewOption.first;

      if ((selectedElement is! THHasOptionsMixin) ||
          (!selectedElement.hasOption(optionType))) {
        return;
      }

      final MPCommand removeOptionCommand = MPRemoveOptionFromElementCommand(
        optionType: optionType,
        parentMPID: selectedElement.mpID,
        currentOriginalLineInTH2File: _thFile
            .elementByMPID(selectedElement.mpID)
            .originalLineInTH2File,
      );

      _th2FileEditController.execute(removeOptionCommand);
    } else {
      final List<int> parentMPIDs = [];

      for (final element in candidateElementsForNewOption) {
        if ((element is THHasOptionsMixin) && element.hasOption(optionType)) {
          parentMPIDs.add(element.mpID);
        }
      }

      if (parentMPIDs.isNotEmpty) {
        final MPCommand removeOptionCommand =
            MPCommandFactory.removeOptionFromElements(
              optionType: optionType,
              parentMPIDs: parentMPIDs,
              thFile: _th2FileEditController.thFile,
            );

        _th2FileEditController.execute(removeOptionCommand);
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

    if (_th2FileEditController.optionEditController.optionsThatTriggerRedraw
        .contains(optionType)) {
      _th2FileEditController.selectionController
          .updateSelectableEndAndControlPoints();
      _th2FileEditController.triggerSelectedElementsRedraw();
      _th2FileEditController.triggerEditLineRedraw();
    }
  }

  void _prepareSetMultipleOptionChoice(
    THCommandOptionType optionType,
    String choice,
  ) {
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final Iterable<MPSelectedElement> mpSelectedElements =
        _th2FileEditController.overlayWindowController.isOverlayWindowShown
            .containsKey(MPWindowType.scrapOptions)
        ? {
            MPSelectedScrap(
              originalScrap: _thFile.scrapByMPID(
                _th2FileEditController.optionEditController.optionsScrapMPID,
              ),
            ),
          }
        : (_th2FileEditController
                  .optionEditController
                  .optionsEditForLineSegments
              ? selectionController.selectedEndControlPoints.values
              : selectionController.mpSelectedElementsLogical.values);

    List<MPCommand> addOptionCommands = [];

    if (mpSelectedElements.isEmpty) {
      /// TODO: set per session option default values.
    } else {
      final List<THElement> elements = [];

      for (final mpSelectedElement in mpSelectedElements) {
        final THElement element = mpSelectedElement.originalElementClone;

        if ((element is THHasOptionsMixin) &&
            (isCtrlPressed ||
                MPCommandOptionAux.elementTypeSupportsOptionType(
                  element,
                  optionType,
                )) &&
            (!element.hasOption(optionType) ||
                ((element.optionByType(optionType)!
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
            option: THCommandOption.byType(
              optionParent: elements.first as THHasOptionsMixin,
              type: optionType,
              value: choice,
            ),
            thFile: _thFile,
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
      }
    }
  }

  void _prepareUnsetMultipleOptionChoice(THCommandOptionType optionType) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final Iterable<MPSelectedElement> mpSelectedElements =
        _th2FileEditController.optionEditController.optionsEditForLineSegments
        ? selectionController.selectedEndControlPoints.values
        : selectionController.mpSelectedElementsLogical.values;

    if (mpSelectedElements.isEmpty) {
      /// TODO: set per session option default values.
    } else if (mpSelectedElements.length == 1) {
      final THElement selectedElement =
          mpSelectedElements.first.originalElementClone;

      if (selectedElement is! THHasOptionsMixin) {
        return;
      }

      if (selectedElement.hasOption(optionType)) {
        final MPCommand removeOptionCommand = MPRemoveOptionFromElementCommand(
          optionType: optionType,
          parentMPID: selectedElement.mpID,
          currentOriginalLineInTH2File: _thFile
              .elementByMPID(selectedElement.mpID)
              .originalLineInTH2File,
        );

        _th2FileEditController.execute(removeOptionCommand);
      }
    } else {
      final List<int> parentMPIDs = [];

      for (final mpSelectedElement in mpSelectedElements) {
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
              thFile: _th2FileEditController.thFile,
            );

        _th2FileEditController.execute(removeOptionCommand);
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

    final Iterable<MPSelectedEndControlPoint> selectedEndControlPoints =
        _th2FileEditController
            .selectionController
            .selectedEndControlPoints
            .values;
    final Set<THLineSegment> willChangeLineSegments = {};
    final THElementType elementType =
        selectedLineSegmentType ==
            MPSelectedLineSegmentType.bezierCurveLineSegment
        ? THElementType.bezierCurveLineSegment
        : THElementType.straightLineSegment;

    for (final MPSelectedEndControlPoint selectedEndControlPoint
        in selectedEndControlPoints) {
      final THLineSegment lineSegment = _th2FileEditController.thFile
          .lineSegmentByMPID(selectedEndControlPoint.mpID);

      if (lineSegment.elementType != elementType) {
        willChangeLineSegments.add(lineSegment);
      }
    }

    if (willChangeLineSegments.isEmpty) {
      return;
    }

    final List<THLineSegment> newLineSegments = [];

    switch (selectedLineSegmentType) {
      case MPSelectedLineSegmentType.bezierCurveLineSegment:
        final THFile thFile = _th2FileEditController.thFile;
        final THLine line = thFile.lineByMPID(
          willChangeLineSegments.first.parentMPID,
        );
        final int decimalPositions =
            _th2FileEditController.currentDecimalPositions;

        for (final THLineSegment currentLineSegment in willChangeLineSegments) {
          final THLineSegment? previousLineSegment = line
              .getPreviousLineSegment(currentLineSegment, thFile);

          if (previousLineSegment == null) {
            continue;
          }

          final THBezierCurveLineSegment newLineSegment =
              MPEditElementAux.getBezierCurveLineSegmentFromStraightLineSegment(
                start: previousLineSegment.endPoint.coordinates,
                straightLineSegment:
                    (currentLineSegment as THStraightLineSegment),
                decimalPositions: decimalPositions,
              );

          newLineSegments.add(newLineSegment);
        }
      case MPSelectedLineSegmentType.straightLineSegment:
        for (final THLineSegment currentLineSegment in willChangeLineSegments) {
          final THStraightLineSegment newLineSegment =
              THStraightLineSegment.forCWJM(
                mpID: currentLineSegment.mpID,
                parentMPID: currentLineSegment.parentMPID,
                endPoint: currentLineSegment.endPoint,
                optionsMap: currentLineSegment.optionsMap,
                attrOptionsMap: currentLineSegment.attrOptionsMap,
                originalLineInTH2File: '',
              );

          newLineSegments.add(newLineSegment);
        }
      default:
        return;
    }

    final MPCommand setLineSegmentTypeCommand;

    if (newLineSegments.length == 1) {
      final THLineSegment newLineSegment = newLineSegments.first;

      setLineSegmentTypeCommand = MPEditLineSegmentCommand(
        originalLineSegment: _th2FileEditController.thFile.lineSegmentByMPID(
          newLineSegment.mpID,
        ),
        newLineSegment: newLineSegment,
        descriptionType: MPCommandDescriptionType.editLineSegmentType,
      );
    } else {
      setLineSegmentTypeCommand = MPCommandFactory.editLinesSegmentType(
        thFile: _th2FileEditController.thFile,
        newLineSegments: newLineSegments,
      );

      _th2FileEditController.execute(setLineSegmentTypeCommand);
    }

    _th2FileEditController.execute(setLineSegmentTypeCommand);
    _th2FileEditController.selectionController.setSelectedEndPoints(
      newLineSegments,
    );
    _th2FileEditController.selectionController
        .updateSelectableEndAndControlPoints();
    _th2FileEditController.triggerEditLineRedraw();
    _th2FileEditController.triggerOptionsListRedraw();
  }

  @action
  void prepareSetPLAType({
    required THElementType plaType,
    required String newType,
  }) {
    final mpSelectedElements = _th2FileEditController
        .selectionController
        .mpSelectedElementsLogical
        .values;
    final TH2FileEditElementEditController elementEditController =
        _th2FileEditController.elementEditController;

    MPCommand setPLATypeCommand;
    List<int> mpIDs = [];

    switch (plaType) {
      case THElementType.area:
        for (final mpSelectedElement in mpSelectedElements) {
          if ((mpSelectedElement.originalElementClone is! THArea) ||
              (mpSelectedElement.originalElementClone as THArea)
                      .areaType
                      .name ==
                  newType) {
            continue;
          }
          mpIDs.add(mpSelectedElement.originalElementClone.mpID);
          elementEditController.setUsedAreaType(newType);
        }

        if (mpIDs.isEmpty) {
          return;
        }

        if (mpIDs.length == 1) {
          setPLATypeCommand = MPEditAreaTypeCommand(
            areaMPID: mpIDs.first,
            newAreaType: THAreaType.values.byName(newType),
          );
        } else {
          setPLATypeCommand = MPCommandFactory.editAreasType(
            newAreaType: THAreaType.values.byName(newType),
            areaMPIDs: mpIDs,
          );
        }
      case THElementType.line:
        for (final mpSelectedElement in mpSelectedElements) {
          if ((mpSelectedElement.originalElementClone is! THLine) ||
              (mpSelectedElement.originalElementClone as THLine)
                      .lineType
                      .name ==
                  newType) {
            continue;
          }
          mpIDs.add(mpSelectedElement.originalElementClone.mpID);
          elementEditController.setUsedLineType(newType);
        }

        if (mpIDs.isEmpty) {
          return;
        }

        if (mpIDs.length == 1) {
          setPLATypeCommand = MPEditLineTypeCommand(
            lineMPID: mpIDs.first,
            newLineType: THLineType.values.byName(newType),
          );
        } else {
          setPLATypeCommand = MPCommandFactory.editLinesType(
            newLineType: THLineType.values.byName(newType),
            lineMPIDs: mpIDs,
          );
        }
      case THElementType.point:
        for (final mpSelectedElement in mpSelectedElements) {
          if ((mpSelectedElement.originalElementClone is! THPoint) ||
              (mpSelectedElement.originalElementClone as THPoint)
                      .pointType
                      .name ==
                  newType) {
            continue;
          }
          mpIDs.add(mpSelectedElement.originalElementClone.mpID);
          elementEditController.setUsedPointType(newType);
        }

        if (mpIDs.isEmpty) {
          return;
        }

        if (mpIDs.length == 1) {
          setPLATypeCommand = MPEditPointTypeCommand(
            pointMPID: mpIDs.first,
            newPointType: THPointType.values.byName(newType),
          );
        } else {
          setPLATypeCommand = MPCommandFactory.editPointsType(
            newPointType: THPointType.values.byName(newType),
            pointMPIDs: mpIDs,
          );
        }
      default:
        return;
    }

    _th2FileEditController.execute(setPLATypeCommand);
    _th2FileEditController.triggerSelectedElementsRedraw();
  }
}
