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
  Map<String, MPOptionInfo> _optionAttrStateMap = {};

  @readonly
  THCommandOptionType? _currentOptionType;

  @readonly
  int _optionsScrapMPID = -1;

  MPOptionElementType _currentOptionElementsType = MPOptionElementType.pla;

  final Set<THCommandOptionType> optionsThatTriggerRedraw = {
    THCommandOptionType.reverse,
    THCommandOptionType.smooth,
  };

  @action
  void updateOptionStateMap() {
    final Iterable<MPSelectedElement> mpSelectedElements =
        _th2FileEditController
            .selectionController
            .mpSelectedElementsLogical
            .values;
    final Set<THHasOptionsMixin> selectedElements = {};

    for (final MPSelectedElement mpSelectedElement in mpSelectedElements) {
      selectedElements.add(
        mpSelectedElement.originalElementClone as THHasOptionsMixin,
      );
    }

    _updateOptionsStateMaps(selectedElements);
    _th2FileEditController.triggerOptionsListRedraw();
  }

  void updateElementOptionMapByMPID(int mpID) {
    final THElement element = _thFile.elementByMPID(mpID);

    if (element is! THHasOptionsMixin) {
      throw Exception(
        'Element with MPID $mpID does not support options at TH2FileEditOptionEditController.getElementOptionMapByMPID()',
      );
    }

    _updateOptionsStateMaps([element]);

    _th2FileEditController.triggerOptionsListRedraw();
  }

  void updateElementOptionMapForLineSegments() {
    final Iterable<MPSelectedEndControlPoint> selectedEndControlPoints =
        _th2FileEditController
            .selectionController
            .selectedEndControlPoints
            .values;
    final List<THLineSegment> selectedLineSegments = [];

    for (final MPSelectedEndControlPoint selectedEndControlPoint
        in selectedEndControlPoints) {
      final THLineSegment lineSegment = _thFile.lineSegmentByMPID(
        selectedEndControlPoint.mpID,
      );

      selectedLineSegments.add(lineSegment);
    }

    _updateOptionsStateMaps(selectedLineSegments);

    _th2FileEditController.triggerOptionsListRedraw();
  }

  void _updateOptionsStateMaps(Iterable<THHasOptionsMixin> selectedElements) {
    final Map<THCommandOptionType, MPOptionInfo> optionsInfo = {};
    final Map<String, MPOptionInfo> optionsAttrInfo = {};

    if (selectedElements.isEmpty) {
      for (final optionType in THCommandOptionType.values) {
        optionsInfo[optionType] = MPOptionInfo(
          type: optionType,
          state: MPOptionStateType.unset,
        );
      }
    } else {
      final Iterable<THCommandOptionType> optionTypesList =
          MPCommandOptionAux.getSupportedOptionsForElements(selectedElements);

      /// Defining the state of each shared option.
      for (final THCommandOptionType optionType in optionTypesList) {
        if (optionType == THCommandOptionType.attr) {
          continue;
        }

        MPOptionStateType optionStateType = MPOptionStateType.unset;
        String? optionValue;
        THCommandOption? option;
        bool isFirst = true;

        for (final THHasOptionsMixin selectedElement in selectedElements) {
          if (selectedElement.hasOption(optionType)) {
            switch (optionStateType) {
              case MPOptionStateType.unset:
                if (isFirst) {
                  optionStateType = MPOptionStateType.set;
                  option = selectedElement.getOption(optionType)!;
                  optionValue = option.specToFile();
                } else {
                  optionStateType = MPOptionStateType.setMixed;
                }
              case MPOptionStateType.set:
                final String newOptionValue = selectedElement
                    .getOption(optionType)!
                    .specToFile();

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

          isFirst = false;

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

      /// Removing ID option if more than one element is selected as there is
      /// no reason to set the same ID for more than one element.
      if ((selectedElements.length > 1) &&
          optionsInfo.containsKey(THCommandOptionType.id)) {
        optionsInfo.remove(THCommandOptionType.id);
      }

      /// Looking for attr options.
      final Set<String> selectedElementsAttrNames = getSetAttrNames(
        selectedElements,
      );

      for (final THHasOptionsMixin selectedElement in selectedElements) {
        final Iterable<String> attrNames = selectedElement
            .getSetAttrOptionNames();

        for (final String attrName in selectedElementsAttrNames) {
          if (!attrNames.contains(attrName)) {
            optionsAttrInfo[attrName] = MPOptionInfo(
              type: THCommandOptionType.attr,
              state: MPOptionStateType.setMixed,
              defaultChoice: null,
              currentChoice: null,
              option: null,
            );
          } else if (optionsAttrInfo.containsKey(attrName)) {
            if (optionsAttrInfo[attrName]!.state == MPOptionStateType.set) {
              final String thisAttrValue = selectedElement.getAttrOptionValue(
                attrName,
              )!;

              if (optionsAttrInfo[attrName]!.currentChoice != thisAttrValue) {
                optionsAttrInfo[attrName] = MPOptionInfo(
                  type: THCommandOptionType.attr,
                  state: MPOptionStateType.setMixed,
                  defaultChoice: null,
                  currentChoice: null,
                  option: null,
                );
              }
            }
          } else {
            optionsAttrInfo[attrName] = MPOptionInfo(
              type: THCommandOptionType.attr,
              state: MPOptionStateType.set,
              defaultChoice: null,
              currentChoice: selectedElement.getAttrOptionValue(attrName),
              option: selectedElement.getAttrOption(attrName),
            );
          }
        }
      }

      MPOptionStateType attrState = MPOptionStateType.unset;
      for (final optionAttrInfo in optionsAttrInfo.values) {
        if (attrState == MPOptionStateType.unset) {
          if (optionAttrInfo.state == MPOptionStateType.set) {
            attrState = MPOptionStateType.set;
          } else if (optionAttrInfo.state == MPOptionStateType.setMixed) {
            attrState = MPOptionStateType.setMixed;
          }
        } else if (attrState == MPOptionStateType.set) {
          if (optionAttrInfo.state == MPOptionStateType.setMixed) {
            attrState = MPOptionStateType.setMixed;
          }
        }
      }
      optionsInfo[THCommandOptionType.attr] = MPOptionInfo(
        type: THCommandOptionType.attr,
        state: attrState,
        defaultChoice: null,
        currentChoice: null,
        option: null,
      );
    }

    final List<THCommandOptionType> orderedOptionTypesList =
        MPCommandOptionAux.getTHCommandOptionTypeOrderedList(optionsInfo.keys);

    _optionStateMap.clear();
    for (final optionType in orderedOptionTypesList) {
      _optionStateMap[optionType] = optionsInfo[optionType]!;
    }

    final List<String> orderedAttrNamesList =
        MPCommandOptionAux.getStringOrderedList(optionsAttrInfo.keys);

    _optionAttrStateMap.clear();
    for (final attrName in orderedAttrNamesList) {
      _optionAttrStateMap[attrName] = optionsAttrInfo[attrName]!;
    }
  }

  Set<String> getSetAttrNames(Iterable<THHasOptionsMixin> selectedElements) {
    final Set<String> attrNames = {};

    for (final THHasOptionsMixin selectedElement in selectedElements) {
      attrNames.addAll(selectedElement.getSetAttrOptionNames());
    }

    return attrNames;
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
    _th2FileEditController.overlayWindowController.toggleOverlayWindow(
      MPWindowType.commandOptions,
    );
  }

  void setOptionElementsType(MPOptionElementType type) {
    _currentOptionElementsType = type;
  }

  MPOptionElementType get currentOptionElementsType =>
      _currentOptionElementsType;
}

class MPOptionInfo {
  final THCommandOptionType type;
  final MPOptionStateType state;

  /// The default choice is set for just a few options that actually have a
  /// default choice.
  final dynamic defaultChoice;

  /// These parameters are only used for MPOptionStateType.set
  final THCommandOption? option;
  final dynamic currentChoice;

  MPOptionInfo({
    required this.type,
    required this.state,
    this.option,
    this.currentChoice,
    this.defaultChoice,
  });
}

enum MPOptionElementType { lineSegment, pla, scrap }
