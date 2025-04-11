import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/interfaces/mp_actuator_interface.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_state_controller.g.dart';

class TH2FileEditStateController = TH2FileEditStateControllerBase
    with _$TH2FileEditStateController;

abstract class TH2FileEditStateControllerBase
    with Store
    implements MPActuatorInterface {
  @readonly
  TH2FileEditController _th2FileEditController;

  @readonly
  MPTH2FileEditState _state;

  TH2FileEditStateControllerBase(this._th2FileEditController)
      : _state = MPTH2FileEditState.getState(
          type: MPTH2FileEditStateType.selectEmptySelection,
          th2FileEditController: _th2FileEditController,
        );

  @action
  bool setState(MPTH2FileEditStateType type) {
    if (_state.type == type) {
      return false;
    }

    final MPTH2FileEditState previousState = _state;

    _state = MPTH2FileEditState.getState(
      type: type,
      th2FileEditController: _th2FileEditController,
    );

    previousState.onStateExit(_state);

    _state.onStateEnter(previousState);
    _state.setCursor();
    _state.setStatusBarMessage();

    return true;
  }

  @override
  Future<void> onPrimaryButtonDragStart(PointerDownEvent event) {
    _state.onPrimaryButtonDragStart(event);

    return Future.value();
  }

  @override
  void onSecondaryButtonDragStart(PointerDownEvent event) {
    _state.onSecondaryButtonDragStart(event);
  }

  @override
  void onTertiaryButtonDragStart(PointerDownEvent event) {
    _state.onTertiaryButtonDragStart(event);
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    _state.onPrimaryButtonDragUpdate(event);
  }

  @override
  void onSecondaryButtonDragUpdate(PointerMoveEvent event) {
    _state.onSecondaryButtonDragUpdate(event);
  }

  @override
  void onTertiaryButtonDragUpdate(PointerMoveEvent event) {
    _state.onTertiaryButtonDragUpdate(event);
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    _state.onPrimaryButtonDragEnd(event);
  }

  @override
  void onSecondaryButtonDragEnd(PointerUpEvent event) {
    _state.onSecondaryButtonDragEnd(event);
  }

  @override
  void onTertiaryButtonDragEnd(PointerUpEvent event) {
    _state.onTertiaryButtonDragEnd(event);
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) async {
    await _state.onPrimaryButtonClick(event);
  }

  @override
  void onSecondaryButtonClick(PointerUpEvent event) {
    _state.onSecondaryButtonClick(event);
  }

  @override
  void onTertiaryButtonClick(PointerUpEvent event) {
    _state.onTertiaryButtonClick(event);
  }

  @override
  void onTertiaryButtonScroll(PointerScrollEvent event) {
    _state.onTertiaryButtonScroll(event);
  }

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    _state.onKeyDownEvent(event);
  }

  @override
  void onKeyRepeatEvent(KeyRepeatEvent event) {
    _state.onKeyRepeatEvent(event);
  }

  @override
  void onKeyUpEvent(KeyUpEvent event) {
    _state.onKeyUpEvent(event);
  }

  void onButtonPressed(MPButtonType buttonType) {
    _state.onButtonPressed(buttonType);
  }
}
