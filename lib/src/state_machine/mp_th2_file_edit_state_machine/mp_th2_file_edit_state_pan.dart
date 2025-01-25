part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStatePan extends MPTH2FileEditState {
  MPTH2FileEditStatePan({required super.thFileEditStore});

  @override
  void onPanUpdate(DragUpdateDetails details) {
    /// Moves the canvas
    thFileEditStore.onPanUpdatePanMode(details);
  }

  @override
  void onSelectToolPressed() {
    /// Changes to [MPTH2FileEditStateType.selectEmptySelection]
    thFileEditStore.setNewState(MPTH2FileEditStateType.selectEmptySelection);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.pan;
}
