part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMoving extends MPTH2FileEditState {
  MPTH2FileEditStateMoving({required super.thFileEditStore});

  @override
  void setCursor() {}

  @override
  void onTapUp(TapUpDetails details) {
    /// Nada
  }

  @override
  void onPanStart(DragStartDetails details) {
    /// Nada.
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    /// Desloca todos os objetos selecionados pela distância indicada por [details].
  }

  @override
  void onPanEnd(DragEndDetails details) {
    /// 1. Grava um MPCommand que move toda a seleção pela distância indicada por [details].
    /// 2. Zera ponto de início do pan.
    /// 3. Muda para [MPTH2FileEditStateType.selectNonEmptySelection].
  }

  @override
  void onPanToolPressed() {
    /// Nada.
  }

  @override
  void onSelectToolPressed() {
    /// Nada.
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.moving;
}
