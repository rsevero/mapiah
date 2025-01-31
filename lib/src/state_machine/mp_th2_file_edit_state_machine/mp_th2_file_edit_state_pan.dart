part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStatePan extends MPTH2FileEditState {
  MPTH2FileEditStatePan({required super.th2FileEditStore});

  @override
  void setVisualMode() {
    th2FileEditStore.setVisualMode(TH2FileEditMode.pan);
  }

  /// Moves the canvas
  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditStore.onPanUpdatePanMode(event);
  }

  @override
  void onMiddleButtonScroll(PointerScrollEvent event) {
    if (event.scrollDelta.dy < 0) {
      th2FileEditStore.zoomIn(fineZoom: true);
    } else if (event.scrollDelta.dy > 0) {
      th2FileEditStore.zoomOut(fineZoom: true);
    }
  }

  @override
  void onChangeActiveScrapToolPressed() {
    final int nextAvailableScrapID = th2FileEditStore.getNextAvailableScrapID();
    th2FileEditStore.setActiveScrap(nextAvailableScrapID);
    th2FileEditStore.updateSelectableElements();
    th2FileEditStore.triggerAllElementsRedraw();
  }

  /// Changes to [MPTH2FileEditStateType.selectEmptySelection]
  @override
  void onSelectToolPressed() {
    th2FileEditStore.setState(MPTH2FileEditStateType.selectEmptySelection);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.pan;
}
