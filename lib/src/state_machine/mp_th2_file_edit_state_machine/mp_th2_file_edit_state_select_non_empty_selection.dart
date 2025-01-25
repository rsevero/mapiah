part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateSelectNonEmptySelection extends MPTH2FileEditState {
  MPTH2FileEditStateSelectNonEmptySelection({required super.thFileEditStore});

  @override
  void onTapUp(TapUpDetails details) {
    /// 1. Clicou em algum objecto?
    /// 1.1. Sim. Objeto já estava selecionado?
    /// 1.1.1. Sim. Shift pressionado?
    /// 1.1.1.1. Sim. Remove o objeto da seleção. Resta algum objeto na seleção?
    /// 1.1.1.1.1. Sim. Não faz nada;
    /// 1.1.1.1.2. Não. Muda para [MPTH2FileEditStateType.selectEmptySelection];
    /// 1.1.1.2. Não. Não faz nada.
    /// 1.1.2. Não. Shift está pressionado?
    /// 1.1.2.1. Sim. Adiciona objeto à seleção;
    /// 1.1.2.2. Não. Substitui seleção atual por objeto clicado.
    /// 1.2. Não. Shift está pressionado?
    /// 1.2.1. Sim. Não faz nada;
    /// 1.2.2. Não. Limpa seleção. Muda para [MPTH2FileEditStateType.selectEmptySelection];
  }

  @override
  void onPanStart(DragStartDetails details) {
    /// 1. Marca ponto de início do pan.
    /// 2. Início do pan clicou em algum objecto?
    /// 2.1. Sim. Shift pressionado?
    /// 2.1.1. Sim. Não faz nada.
    /// 2.1.2. Não. Objeto já estava selecionado?
    /// 2.1.2.1. Sim. Muda para [MPTH2FileEditStateType.moving];
    /// 2.1.2.2. Não. Limpa seleção atual; inclui objeto clicado na seleção. Muda para [MPTH2FileEditStateType.moving];
    /// 2.2. Não. Não faz nada.
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    /// Desenha janela de seleção.
  }

  @override
  void onPanEnd(DragEndDetails details) {
    /// 1. Monta lista de objetos dentro da janela de seleção.
    /// 1.1. Se shift pressionado, inclui objetos ainda não selecionados na seleção;
    /// 1.2. Se shift não pressionado, limpa seleçaõ atual. Lista de objetos dentro da janela de seleção está vazia?
    /// 1.2.1. Sim. Muda para [MPTH2FileEditStateType.selectEmptySelection];
    /// 1.2.2. Não. Inclui objectos da lista de objetos dentro da janela de seleção na seleção atual.
    /// 2. Zera ponto de início do pan.
  }

  @override
  void onPanToolPressed() {
    /// 1. Limpa seleção.
    /// 2. Muda para [MPTH2FileEditStateType.pan];
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.selectNonEmptySelection;
}
