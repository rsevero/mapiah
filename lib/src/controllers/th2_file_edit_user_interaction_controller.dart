import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
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
  void prepareMultipleOptionChoiceToElement(
    THCommandOptionType optionType,
    String choice,
  ) {
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final mpSelectedElements =
        _th2FileEditController.selectionController.selectedElements.values;

    if (mpSelectedElements.isEmpty) {
      /// TODO: set per session option default values.
    } else if (mpSelectedElements.length == 1) {
      final THElement selectedElement =
          mpSelectedElements.first.originalElementClone;

      if (selectedElement is! THHasOptionsMixin) {
        return;
      }

      if (choice == mpMultipleChoiceUnsetID) {
        if (selectedElement.hasOption(optionType)) {
          final MPCommand removeOptionCommand =
              MPRemoveOptionFromElementCommand(
            optionType: optionType,
            parentMPID: selectedElement.mpID,
          );

          _th2FileEditController.execute(removeOptionCommand);
        }
      } else if (isCtrlPressed ||
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
          parentMPID: selectedElement.mpID,
        );

        _th2FileEditController.execute(addOptionCommand);
      }
    } else {
      /// TODO: implement multiple element option setting.
    }
  }
}
