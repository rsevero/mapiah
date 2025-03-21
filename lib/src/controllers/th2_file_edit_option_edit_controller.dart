import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
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
  ObservableMap<THCommandOptionType, Observable<MPOptionStateType>>
      _optionStateMap = ObservableMap();

  @readonly
  THCommandOptionType? _openedOptionType;

  @action
  void updateOptionStateMap() {
    final Map<THCommandOptionType, MPOptionStateType> optionStateMap = {};
    final mpSelectedElements =
        _th2FileEditController.selectionController.selectedElements.values;

    if (mpSelectedElements.isEmpty) {
      for (final optionType in THCommandOptionType.values) {
        optionStateMap[optionType] = MPOptionStateType.unset;
      }
    } else {
      final Set<THHasOptionsMixin> selectedElements = {};

      for (final MPSelectedElement mpSelectedElement in mpSelectedElements) {
        selectedElements
            .add(mpSelectedElement.originalElementClone as THHasOptionsMixin);
      }

      final List<THCommandOptionType> optionTypesList =
          MPCommandOptionAux.getSupportedOptionsForElements(
              selectedElements.toList());

      /// Defining the state of each shared option.
      for (final optionType in optionTypesList) {
        MPOptionStateType optionStateType = MPOptionStateType.unset;
        String? optionValue;

        for (final THHasOptionsMixin selectedElement in selectedElements) {
          if (selectedElement.hasOption(optionType)) {
            switch (optionStateType) {
              case MPOptionStateType.unset:
                optionStateType = MPOptionStateType.set;
                optionValue =
                    selectedElement.optionByType(optionType)!.specToFile();
              case MPOptionStateType.set:
                final String newOptionValue =
                    selectedElement.optionByType(optionType)!.specToFile();
                if (optionValue != newOptionValue) {
                  optionStateType = MPOptionStateType.setMixed;
                }
              default:
            }
          } else if (optionStateType == MPOptionStateType.set) {
            optionStateType = MPOptionStateType.setMixed;
          }

          if (optionStateType == MPOptionStateType.setMixed) {
            break;
          }
        }
        optionStateMap[optionType] = optionStateType;
      }

      /// Looking for set but unsupported options.
      for (final THHasOptionsMixin selectedElement in selectedElements) {
        for (final THCommandOptionType optionType
            in selectedElement.optionsMap.keys) {
          if (!optionStateMap.containsKey(optionType)) {
            optionStateMap[optionType] = MPOptionStateType.setUnsupported;
          }
        }
      }
    }

    final List<THCommandOptionType> orderedOptionTypesList =
        MPCommandOptionAux.getOrderedList(optionStateMap.keys);

    _optionStateMap.clear();
    for (final optionType in orderedOptionTypesList) {
      _optionStateMap[optionType] = Observable(optionStateMap[optionType]!);
    }
  }

  @action
  void toggleOptionShownStatus(
    THCommandOptionType optionType,
    Offset position,
  ) {
    if (_openedOptionType == optionType) {
      _th2FileEditController.overlayWindowController.setShowOverlayWindow(
        MPOverlayWindowType.optionChoices,
        false,
      );
      _openedOptionType = null;
    } else {
      if (_openedOptionType != null) {
        _th2FileEditController.overlayWindowController.setShowOverlayWindow(
          MPOverlayWindowType.optionChoices,
          false,
        );
      }
      _openedOptionType = optionType;
      _th2FileEditController.overlayWindowController.setShowOverlayWindow(
        MPOverlayWindowType.optionChoices,
        true,
        position: position,
      );
    }
  }

  @action
  void showOptionsOverlayWindow() {
    updateOptionStateMap();
    _th2FileEditController.overlayWindowController
        .toggleOverlayWindow(MPOverlayWindowType.commandOptions);
  }
}
