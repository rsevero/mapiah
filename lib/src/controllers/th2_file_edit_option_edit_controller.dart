import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_option_edit_controller.g.dart';

class TH2FileEditOptionEditController = TH2FileEditOptionEditControllerBase
    with _$TH2FileEditOptionEditController;

abstract class TH2FileEditOptionEditControllerBase with Store {
  @readonly
  THFile _thFile;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditOptionEditControllerBase(this._th2FileEditController)
      : _thFile = _th2FileEditController.thFile;

  @readonly
  Map<THCommandOptionType, MPOptionInfo> _optionStateMap = {};

  @readonly
  THCommandOptionType? _currentOptionType;

  @readonly
  int _optionsScrapMPID = -1;

  @action
  void updateOptionStateMap() {
    final mpSelectedElements =
        _th2FileEditController.selectionController.selectedElements.values;
    final Set<THHasOptionsMixin> selectedElements = {};

    for (final MPSelectedElement mpSelectedElement in mpSelectedElements) {
      selectedElements
          .add(mpSelectedElement.originalElementClone as THHasOptionsMixin);
    }

    _optionStateMap = _getOptionStateMap(selectedElements);
    _th2FileEditController.triggerOptionsListRedraw();
  }

  void updateElementOptionMapByMPID(int mpID) {
    final THElement element = _thFile.elementByMPID(mpID);

    if (element is! THHasOptionsMixin) {
      throw Exception(
          'Element with MPID $mpID does not support options at TH2FileEditOptionEditController.getElementOptionMapByMPID()');
    }

    _optionStateMap = _getOptionStateMap({element});

    _th2FileEditController.triggerOptionsListRedraw();
  }

  Map<THCommandOptionType, MPOptionInfo> _getOptionStateMap(
    Set<THHasOptionsMixin> selectedElements,
  ) {
    final Map<THCommandOptionType, MPOptionInfo> optionsInfo = {};

    if (selectedElements.isEmpty) {
      for (final optionType in THCommandOptionType.values) {
        optionsInfo[optionType] = MPOptionInfo(
          type: optionType,
          state: MPOptionStateType.unset,
        );
      }
    } else {
      final List<THCommandOptionType> optionTypesList =
          MPCommandOptionAux.getSupportedOptionsForElements(
              selectedElements.toList());

      /// Defining the state of each shared option.
      for (final optionType in optionTypesList) {
        MPOptionStateType optionStateType = MPOptionStateType.unset;
        String? optionValue;
        THCommandOption? option;

        for (final THHasOptionsMixin selectedElement in selectedElements) {
          if (selectedElement.hasOption(optionType)) {
            switch (optionStateType) {
              case MPOptionStateType.unset:
                optionStateType = MPOptionStateType.set;
                option = selectedElement.optionByType(optionType)!;
                optionValue = option.specToFile();
              case MPOptionStateType.set:
                final String newOptionValue =
                    selectedElement.optionByType(optionType)!.specToFile();

                if (optionValue != newOptionValue) {
                  optionStateType = MPOptionStateType.setMixed;
                  option = null;
                  optionValue = null;
                }
              default:
            }
          } else if (optionStateType == MPOptionStateType.set) {
            optionStateType = MPOptionStateType.setMixed;
            option = null;
            optionValue = null;
          }

          if (optionStateType == MPOptionStateType.setMixed) {
            break;
          }
        }
        optionsInfo[optionType] = MPOptionInfo(
          type: optionType,
          state: optionStateType,
          defaultChoice: THCommandOption.getDefaultChoice(optionType),
          currentChoice: optionValue,
          option: option,
        );
      }

      /// Looking for set but unsupported options.
      for (final THHasOptionsMixin selectedElement in selectedElements) {
        for (final THCommandOptionType optionType
            in selectedElement.optionsMap.keys) {
          if (!optionsInfo.containsKey(optionType)) {
            optionsInfo[optionType] = MPOptionInfo(
              type: optionType,
              state: MPOptionStateType.setUnsupported,
              defaultChoice: THCommandOption.getDefaultChoice(optionType),
              currentChoice: null,
              option: null,
            );
          }
        }
      }
    }

    final List<THCommandOptionType> orderedOptionTypesList =
        MPCommandOptionAux.getOrderedList(optionsInfo.keys);
    final Map<THCommandOptionType, MPOptionInfo> optionStateMap = {};

    for (final optionType in orderedOptionTypesList) {
      optionStateMap[optionType] = optionsInfo[optionType]!;
    }

    return optionStateMap;
  }

  @action
  void setOptionsScrapMPID(int mpID) {
    _optionsScrapMPID = mpID;
  }

  @action
  void performToggleOptionShownStatus({
    required THCommandOptionType optionType,
    required Offset outerAnchorPosition,
  }) {
    if (_currentOptionType == optionType) {
      _th2FileEditController.overlayWindowController.setShowOverlayWindow(
        MPWindowType.optionChoices,
        false,
      );
      _currentOptionType = null;
    } else {
      if (_currentOptionType != null) {
        _th2FileEditController.overlayWindowController.setShowOverlayWindow(
          MPWindowType.optionChoices,
          false,
        );
      }
      _currentOptionType = optionType;
      final MPOptionInfo optionInfo = _optionStateMap[optionType]!;

      _th2FileEditController.overlayWindowController
          .showOptionChoicesOverlayWindow(
        outerAnchorPosition: outerAnchorPosition,
        optionInfo: optionInfo,
      );
    }
  }

  @action
  void clearCurrentOptionType() {
    _currentOptionType = null;
  }

  @action
  void showOptionsOverlayWindow() {
    updateOptionStateMap();
    _th2FileEditController.overlayWindowController
        .toggleOverlayWindow(MPWindowType.commandOptions);
  }
}

class MPOptionInfo {
  final THCommandOptionType type;
  final MPOptionStateType state;
  final THCommandOption? option;
  final dynamic currentChoice;
  final dynamic defaultChoice;

  MPOptionInfo({
    required this.type,
    required this.state,
    this.option,
    this.currentChoice,
    this.defaultChoice,
  });
}
