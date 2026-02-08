Aqui é onde toda a edição de arquivos TH2 é feita.

## Índice
- [Índice](#índice)
- [Barra superior](#barra-superior)
- [Croquis](#croquis)
- [Desenhando linhas](#desenhando-linhas)
- [Janela de edição](#janela-de-edição)
  - [Canto superior direito](#canto-superior-direito)
  - [Canto inferior direito](#canto-inferior-direito)
- [Opções do elemento](#opções-do-elemento)
- [Salvar](#salvar)
  - [Formato original do arquivo](#formato-original-do-arquivo)
  - [Versões web](#versões-web)
- [Simplificar linhas](#simplificar-linhas)
  - [Métodos de simplificação](#métodos-de-simplificação)
  - [Segmentos de linha em curva Bézier](#segmentos-de-linha-em-curva-bézier)
  - [Segmentos de linha mistos](#segmentos-de-linha-mistos)
  - [Segmentos de linha reta](#segmentos-de-linha-reta)
- [Snap](#snap)
- [Zoom e pan](#zoom-e-pan)

## Barra superior
* À esquerda:
    * ![Ícone voltar](assets/help/images/iconBack.png "Voltar")  _Voltar_: retorna para a janela principal sem salvar o conteúdo.
* À direita:
  * ![Ícone salvar](assets/help/images/iconSave.png "Salvar")  _Salvar_: salva as alterações no mesmo arquivo. Só fica habilitado se houver alterações a serem salvas. (Ctrl+S)
  * ![Ícone salvar como](assets/help/images/iconSaveAs.png "Salvar como")  _Salvar como_: salva as alterações em um novo arquivo. (Shift+Ctrl+S)
  * ![Ícone ajuda](assets/help/images/iconHelp.png "Ajuda") _Ajuda_: mostra esta caixa de diálogo.
  * ![Ícone fechar](assets/help/images/iconClose.png "Fechar") _Fechar_: fecha a janela de edição do arquivo TH2 sem salvar alterações.

## Croquis
Só é possível trabalhar em um croqui por vez. Para trocar o croqui atual, clique no botão de seleção de croquis ![Botão Croquis](assets/help/images/buttonScraps.png "Scraps") no canto inferior direito e escolha o croqui desejado na caixa de diálogo apresentada.

Você também pode _Alt+clicar_ em um croqui inativo para torná-lo o croqui atual.

## Desenhando linhas
Ao desenhar linhas, cada novo segmento é inicialmente criado como um segmento de linha reta. Para convertê-lo em um segmento de curva Bézier, não solte o botão do mouse e arraste. A posição do mouse será tratada como a posição do único ponto de controle de uma curva Bézier quadrática.

Curvas Bézier no Therion (e no Mapiah) são curvas cúbicas, isto é, têm 2 pontos de controle para cada segmento. Apenas durante a criação do segmento, o Mapiah finge que a curva Bézier sendo criada é uma Bézier quadrática (com apenas um ponto de controle) para dar flexibilidade ao usuário na criação do segmento.

Observe que, apesar de o Mapiah simular a existência de apenas um ponto de controle, uma curva Bézier cúbica real é criada com dois pontos de controle, como esperado.

## Janela de edição

### Canto superior direito
* ![Botão Snap](assets/help/images/buttonSnap.png "Snap")  _Snap_: alterna a janela de snap, onde são apresentadas as opções de snap. (Ctrl+L)
* ![Botão deletar](assets/help/images/buttonDelete.png "Deletar")  _Deletar_: apaga os elementos atualmente selecionados. Só fica habilitado se houver pelo menos um elemento selecionado. (Delete/Backspace)
* ![Botão desfazer](assets/help/images/buttonUndo.png "Desfazer")  _Desfazer_: desfaz a última operação de edição executada. Só fica habilitado se houver pelo menos uma operação a desfazer. (Ctrl+Z)
* ![Botão refazer](assets/help/images/buttonRedo.png "Refazer")  _Refazer_: refaz a última operação desfeita. Só fica habilitado se houver pelo menos uma operação a refazer. (Ctrl+Y)

Caso existam operações no stack de refazer e uma nova operação de edição seja executada, o stack de refazer é migrado para o stack de desfazer, mantendo os “refazer” acessíveis.

### Canto inferior direito
* ![Botão imagens](assets/help/images/buttonImages.png "Imagens")  _Imagens_: abre a janela de opções de imagens (overlay). Mostra todas as imagens inseridas no arquivo atual. Apresenta um botão “Delete” para cada imagem e um botão “Add Image (I)”. (Alt+I)
* ![Botão scraps](assets/help/images/buttonScraps.png "Scraps")  _Scraps_: abre uma caixa de diálogo para mudar o scrap atual, excluir um scrap existente e adicionar um novo. A caixa de diálogo mostra todos os scraps disponíveis e permite selecionar um deles. A janela de opções do scrap (overlay) é apresentada ao clicar com o botão direito no scrap desejado. (Alt+C)
* ![Botão selecionar elemento](assets/help/images/buttonSelectElement.png "Selecionar elemento")  _Selecionar elemento_: permite selecionar elementos no arquivo TH2. (C)
* ![Botão editar linha](assets/help/images/buttonLineEdit.png "Editar linha")  _Editar linha_: permite editar linhas individuais no arquivo TH2. (N)
* ![Botão adicionar elemento](assets/help/images/buttonAddElement.png "Adicionar elemento")  _Adicionar elemento_: permite adicionar novos elementos ao arquivo TH2. Ao passar o mouse, os botões abaixo são mostrados:
  * ![Botão adicionar ponto](assets/help/images/buttonAddPoint.png "Adicionar ponto")  _Adicionar ponto_: adiciona um novo ponto ao arquivo TH2. (P)
  * ![Botão adicionar linha](assets/help/images/buttonAddLine.png "Adicionar linha")  _Adicionar linha_: adiciona uma nova linha ao arquivo TH2. (L)
  * ![Botão adicionar área](assets/help/images/buttonAddArea.png "Adicionar área")  _Adicionar área_: adiciona uma nova área ao arquivo TH2. (A)
* ![Botão opções de zoom](assets/help/images/buttonZoomOptions.png "Opções de zoom")  _Opções de zoom_: apresenta as opções de zoom. Ao passar o mouse, os botões abaixo são mostrados:
  * ![Botão zoom in](assets/help/images/buttonZoomIn.png "Aproximar")  _Aproximar_: dá zoom in na visualização do arquivo TH2. (+)
  * ![Botão zoom 1:1](assets/help/images/buttonZoomOneToOne.png "Zoom 1:1")  _Zoom 1:1_: ajusta a visualização para mostrar os elementos no tamanho original, isto é, cada ponto TH2 corresponde a um pixel de tela. (1)
  * ![Botão zoom na seleção](assets/help/images/buttonZoomSelection.png "Zoom na seleção")  _Zoom na seleção_: ajusta a visualização para mostrar os elementos atualmente selecionados. (2)
  * ![Botão zoom na janela de seleção](assets/help/images/buttonZoomSelectionWindow.png "Zoom na janela de seleção")  _Zoom na janela de seleção_: ajusta a visualização para mostrar a área selecionada pelo usuário com um arrasto do mouse. (5)
  * ![Botão zoom no arquivo](assets/help/images/buttonZoomFile.png "Zoom no arquivo")  _Zoom no arquivo_: ajusta a visualização para mostrar todos os elementos do arquivo. (3)
  * ![Botão zoom no scrap](assets/help/images/buttonZoomScrap.png "Zoom no scrap")  _Zoom no scrap_: ajusta a visualização para mostrar o scrap atualmente selecionado. (4)
  * ![Botão zoom out](assets/help/images/buttonZoomOut.png "Afastar")  _Afastar_: dá zoom out na visualização do arquivo TH2. (-)

## Opções do elemento
Clicar com o botão direito em um elemento selecionado apresenta uma janela (overlay) com as opções disponíveis para os elementos selecionados. A janela de opções do elemento também pode ser aberta usando o atalho de teclado 'O' quando houver pelo menos um elemento selecionado.
As opções disponíveis dependem do tipo de elemento selecionado.

Para editar opções do scrap, clique com o botão direito em:
* o botão de seleção de scrap no canto inferior direito, caso exista apenas um scrap no arquivo, ou
* o nome do scrap na caixa de diálogo de seleção de scrap apresentada ao clicar no botão de seleção de scrap, caso existam múltiplos scraps no arquivo.

## Salvar

### Formato original do arquivo
O Mapiah preserva o máximo possível a formatação original do arquivo ao salvar. No entanto, algumas mudanças são feitas durante o parsing e aparecem na versão salva mesmo que o usuário não tenha editado nada:
* Pontos consecutivos de linha com pontos finais idênticos são mesclados em um único ponto de linha.
* Linhas com zero ou um ponto de linha são removidas.
* Referências inexistentes de borda de área são removidas, isto é, a área menciona um ID de borda, mas não há uma linha com o mesmo ID no arquivo.
* Áreas sem referências de borda são removidas.
* Opções de linha definidas na área [LINE DATA] são movidas para a definição da linha. Não confundir com opções de ponto de linha, que são definidas na área [LINE DATA] e são preservadas lá.
* Opções de subtipo definidas antes do primeiro ponto de linha ou no primeiro ponto são transformadas em subtipo da linha.

### Versões web
Salvar em versões web é, na prática, uma solicitação de download. Caso seu navegador esteja configurado para baixar automaticamente para uma pasta padrão, verifique lá o arquivo atualizado após salvar.

## Simplificar linhas
Curvas Bézier e segmentos de linha reta são simplificados de forma diferente. Para simplificar linhas, selecione-as primeiro. É possível ter outros tipos de elementos selecionados (pontos ou áreas) durante a simplificação; eles não serão alterados pelo processo.

### Métodos de simplificação
Há três métodos de simplificação de linha disponíveis:
* __Manter tipos originais (Ctrl+L)__: cada segmento de linha é simplificado usando o algoritmo de simplificação do seu próprio tipo.
* __Forçar Bézier (Ctrl+Alt+L)__: todos os segmentos de linha são, se necessário, primeiro convertidos para curvas Bézier e então simplificados usando o algoritmo de simplificação de Bézier.
* __Forçar reta (Ctrl+Shift+L)__: todos os segmentos de linha são, se necessário, primeiro convertidos para retas e então simplificados usando o algoritmo de simplificação de reta.

### Segmentos de linha em curva Bézier
Cada pressionamento de _Ctrl+[Alt]+L_ executa uma rodada de simplificação. O Mapiah usa um algoritmo interativo para simplificar segmentos em curva Bézier. Ele opera no espaço do canvas. A tolerância inicial (epsilon) equivale a 1,5 pixels de tela. Esse valor é convertido para coordenadas do canvas. Em cada execução subsequente, a tolerância é aumentada pelo mesmo valor inicial.

### Segmentos de linha mistos
Quando uma linha contém tanto segmentos em curva Bézier quanto segmentos retos, o Mapiah trata cada parte separadamente. Cada parte contendo apenas segmentos Bézier é simplificada usando o algoritmo de simplificação de Bézier. Cada parte contendo apenas segmentos retos é simplificada usando o algoritmo de simplificação de reta.

### Segmentos de linha reta
Cada pressionamento de _Ctrl+[Shift]+L_ executa uma rodada de simplificação. O Mapiah usa uma versão interativa (não recursiva) do [algoritmo de Ramer–Douglas–Peucker](https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm) para simplificar segmentos de linha reta. Ele opera no espaço do canvas. A tolerância inicial (epsilon) equivale a 1,5 pixels de tela. Esse valor é convertido para coordenadas do canvas. Em cada execução subsequente, a tolerância é aumentada pelo mesmo valor inicial.

## Snap
Há várias opções de snap disponíveis que podem ser controladas na janela apresentada quando o botão ![Botão Snap](assets/help/images/buttonSnap.png "Snap") é pressionado:

* Snap do arquivo XVI (zero ou mais opções podem ser selecionadas):
  * __Linhas de grade__: snap nas linhas de grade.
  * __Interseções da grade__: snap nas interseções das linhas de grade do arquivo XVI.
  * __Shots__: snap nos pontos inicial e final dos shots no arquivo XVI.
  * __Linhas do sketch__: snap nos pontos das linhas do sketch no arquivo XVI.
  * __Estações__: snap nas estações definidas no arquivo XVI.
* Snap de pontos (opção única):
  * __Nenhum__: não fazer snap em pontos do arquivo TH2.
  * __Pontos__: snap em todos os pontos definidos no arquivo TH2.
  * __Pontos por tipo__: snap somente nos tipos de ponto selecionados no arquivo TH2.
* Snap de pontos de linha (opção única):
  * __Pontos de linha__: snap em todos os pontos de linha no arquivo TH2.
  * __Pontos de linha por tipo__: snap somente nos pontos de linha dos tipos de linha selecionados.
  * __Nenhum__: não fazer snap em pontos de linha.

## Zoom e pan
A visualização do arquivo TH2 pode ser aproximada e afastada usando os botões de zoom ou a roda do mouse.
A visualização também pode ser movida (pan) clicando com o botão direito e arrastando o mouse.
_Ctrl+roda do mouse_ move verticalmente, _Shift+roda do mouse_ move horizontalmente.
