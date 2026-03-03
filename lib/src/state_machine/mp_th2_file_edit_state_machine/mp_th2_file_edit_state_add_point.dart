part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddPoint extends MPTH2FileEditState
    with MPTH2FileEditPageAltClickMixin, MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditStateAddPoint({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.setStatusBarMessage(
      mpLocator.appLocalizations.th2FileEditPageAddPointStatusBarMessage(
        elementEditController.lastUsedPointType,
      ),
    );
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    th2FileEditController.setStatusBarMessage('');
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) async {
    if (onAltPrimaryButtonClick(event)) {
      return Future.value();
    }

    final ({String type, String subtype}) typeSubtype = elementEditController
        .getLastUsedPointTypeAndSubtype();

    elementEditController.addPoint(
      newPointScreenPosition: event.localPosition,
      pointTypeString: typeSubtype.type,
      pointSubtypeString: typeSubtype.subtype,
    );

    return Future.value();
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addPoint;
}
