import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
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
    final mpSelectedElements =
        _th2FileEditController.selectionController.mpSelectedElements.values;

    if (mpSelectedElements.isEmpty) {
      /// TODO: set per session option default values.
    } else if (mpSelectedElements.length == 1) {
      final THElement selectedElement =
          mpSelectedElements.first.originalElementClone;

      if ((selectedElement is! THHasOptionsMixin) ||
          (!isCtrlPressed &&
              !MPCommandOptionAux.elementTypeSupportsOptionType(
                selectedElement,
                option.type,
              )) ||
          (selectedElement.hasOption(option.type) &&
              selectedElement.optionByType(option.type) == option)) {
        return;
      }

      final MPCommand setOptionCommand = MPSetOptionToElementCommand(
        option: option.copyWith(parentMPID: selectedElement.mpID),
      );

      _th2FileEditController.execute(setOptionCommand);
    } else {
      final List<THElement> elements = [];

      for (final mpSelectedElement in mpSelectedElements) {
        final THElement element = mpSelectedElement.originalElementClone;

        if ((element is THHasOptionsMixin) &&
            (isCtrlPressed ||
                MPCommandOptionAux.elementTypeSupportsOptionType(
                  element,
                  option.type,
                )) &&
            (!element.hasOption(option.type) ||
                element.optionByType(option.type) != option)) {
          elements.add(element);
        }
      }

      if (elements.isNotEmpty) {
        final MPMultipleElementsCommand addOptionCommand =
            MPMultipleElementsCommand.setOption(
          elements: elements,
          option: option,
        );

        _th2FileEditController.execute(addOptionCommand);
      }
    }
  }

  void _prepareUnsetOption(THCommandOptionType optionType) {
    final mpSelectedElements =
        _th2FileEditController.selectionController.mpSelectedElements.values;

    if (mpSelectedElements.isEmpty) {
      /// TODO: set per session option default values.
    } else if (mpSelectedElements.length == 1) {
      final THElement selectedElement =
          mpSelectedElements.first.originalElementClone;

      if ((selectedElement is! THHasOptionsMixin) ||
          (!selectedElement.hasOption(optionType))) {
        return;
      }

      final MPCommand removeOptionCommand = MPRemoveOptionFromElementCommand(
        optionType: optionType,
        parentMPID: selectedElement.mpID,
      );

      _th2FileEditController.execute(removeOptionCommand);
    } else {
      final List<int> parentMPIDs = [];

      for (final mpSelectedElement in mpSelectedElements) {
        final THElement element = mpSelectedElement.originalElementClone;

        if ((element is THHasOptionsMixin) && element.hasOption(optionType)) {
          parentMPIDs.add(element.mpID);
        }
      }

      if (parentMPIDs.isNotEmpty) {
        final MPMultipleElementsCommand removeOptionCommand =
            MPMultipleElementsCommand.removeOption(
          optionType: optionType,
          parentMPIDs: parentMPIDs,
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
  }

  void _prepareSetMultipleOptionChoice(
    THCommandOptionType optionType,
    String choice,
  ) {
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final mpSelectedElements =
        _th2FileEditController.selectionController.mpSelectedElements.values;

    if (mpSelectedElements.isEmpty) {
      /// TODO: set per session option default values.
    } else if (mpSelectedElements.length == 1) {
      final THElement selectedElement =
          mpSelectedElements.first.originalElementClone;

      if (selectedElement is! THHasOptionsMixin) {
        return;
      }

      if (isCtrlPressed ||
          MPCommandOptionAux.elementTypeSupportsOptionType(
            selectedElement,
            optionType,
          )) {
        final THCommandOption option = THCommandOption.byType(
          optionParent: selectedElement,
          type: optionType,
          value: choice,
        );
        final MPCommand addOptionCommand = MPSetOptionToElementCommand(
          option: option,
        );

        _th2FileEditController.execute(addOptionCommand);
      }
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
        }
      }

      if (elements.isNotEmpty) {
        final MPMultipleElementsCommand addOptionCommand =
            MPMultipleElementsCommand.setOption(
          elements: elements,
          option: THCommandOption.byType(
            optionParent: elements.first as THHasOptionsMixin,
            type: optionType,
            value: choice,
          ),
        );

        _th2FileEditController.execute(addOptionCommand);
      }
    }
  }

  void _prepareUnsetMultipleOptionChoice(THCommandOptionType optionType) {
    final mpSelectedElements =
        _th2FileEditController.selectionController.mpSelectedElements.values;

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
        final MPMultipleElementsCommand removeOptionCommand =
            MPMultipleElementsCommand.removeOption(
          optionType: optionType,
          parentMPIDs: parentMPIDs,
        );

        _th2FileEditController.execute(removeOptionCommand);
      }
    }
  }

  @action
  void prepareSetPLAType({
    required THElementType plaType,
    required String newType,
  }) {
    MPCommand setPLATypeCommand;
    List<int> mpIDs = [];
    final mpSelectedElements =
        _th2FileEditController.selectionController.mpSelectedElements.values;

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
        }

        if (mpIDs.isEmpty) {
          return;
        } else if (mpIDs.length == 1) {
          setPLATypeCommand = MPEditAreaTypeCommand(
            areaMPID: mpIDs.first,
            newAreaType: THAreaType.values.byName(newType),
          );
        } else {
          setPLATypeCommand = MPMultipleElementsCommand.editAreasType(
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
        }

        if (mpIDs.isEmpty) {
          return;
        } else if (mpIDs.length == 1) {
          setPLATypeCommand = MPEditLineTypeCommand(
            lineMPID: mpIDs.first,
            newLineType: THLineType.values.byName(newType),
          );
        } else {
          setPLATypeCommand = MPMultipleElementsCommand.editLinesType(
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
        }

        if (mpIDs.isEmpty) {
          return;
        } else if (mpIDs.length == 1) {
          setPLATypeCommand = MPEditPointTypeCommand(
            pointMPID: mpIDs.first,
            newPointType: THPointType.values.byName(newType),
          );
        } else {
          setPLATypeCommand = MPMultipleElementsCommand.editPointsType(
            newPointType: THPointType.values.byName(newType),
            pointMPIDs: mpIDs,
          );
        }
      default:
        return;
    }

    _th2FileEditController.execute(setPLATypeCommand);
  }
}
