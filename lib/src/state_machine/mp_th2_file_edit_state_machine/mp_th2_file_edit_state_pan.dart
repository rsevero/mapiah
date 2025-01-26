part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStatePan extends MPTH2FileEditState {
  MPTH2FileEditStatePan({required super.th2FileEditStore});

  @override
  void onPanUpdate(DragUpdateDetails details) {
    /// Moves the canvas
    th2FileEditStore.onPanUpdatePanMode(details);
  }

  @override
  void onSelectToolPressed() {
    /// Changes to [MPTH2FileEditStateType.selectEmptySelection]
    th2FileEditStore.setNewState(MPTH2FileEditStateType.selectEmptySelection);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.pan;
}
