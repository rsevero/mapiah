part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStatePan extends MPTH2FileEditState {
  MPTH2FileEditStatePan({required super.th2FileEditStore});

  @override
  void setVisualMode() {
    th2FileEditStore.setVisualMode(TH2FileEditMode.pan);
  }

  /// Moves the canvas
  @override
  void onPanUpdate(DragUpdateDetails details) {
    th2FileEditStore.onPanUpdatePanMode(details);
  }

  /// Changes to [MPTH2FileEditStateType.selectEmptySelection]
  @override
  void onSelectToolPressed() {
    th2FileEditStore.setState(MPTH2FileEditStateType.selectEmptySelection);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.pan;
}
