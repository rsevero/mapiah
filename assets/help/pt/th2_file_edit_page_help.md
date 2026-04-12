<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
Aqui é onde toda a edição de arquivos TH2 é feita.

_Observação: no Mapiah as teclas Ctrl e Meta (Command no macOS) são intercambiáveis. Nas menções de atalhos abaixo usa-se "Ctrl" por brevidade._

## Índice
- [Índice](#índice)
- [Barra superior](#barra-superior)
- [Abas de arquivo](#abas-de-arquivo)
- [Imagens](#imagens)
  - [Modo de transformação da imagem](#modo-de-transformação-da-imagem)
  - [Movimento da imagem](#movimento-da-imagem)
  - [Redimensionamento da imagem](#redimensionamento-da-imagem)
  - [Rotação da imagem](#rotação-da-imagem)
  - [Visibilidade da imagem](#visibilidade-da-imagem)
  - [Visibilidade da grade](#visibilidade-da-grade)
  - [Reordenação de imagens](#reordenação-de-imagens)
- [Modificadores de arrasto](#modificadores-de-arrasto)
  - [Elementos selecionados](#elementos-selecionados)
  - [Pontos finais/controle em edição de linha](#pontos-finaiscontrole-em-edição-de-linha)
- [Croquis](#croquis)
  - [Copiar croqui](#copiar-croqui)
  - [Recortar croqui](#recortar-croqui)
  - [Duplicar croqui](#duplicar-croqui)
  - [Visibilidade do croqui](#visibilidade-do-croqui)
  - [Reordenação de croquis](#reordenação-de-croquis)
- [Desenhando linhas](#desenhando-linhas)
  - [Conexão de mapa](#conexão-de-mapa)
- [Janela de edição](#janela-de-edição)
  - [Canto superior direito](#canto-superior-direito)
  - [Canto inferior direito](#canto-inferior-direito)
- [Opções do elemento](#opções-do-elemento)
- [Opções padrão](#opções-padrão)
- [Salvar](#salvar)
  - [Formato original do arquivo](#formato-original-do-arquivo)
- [Selecionando elementos](#selecionando-elementos)
- [Operações com elementos](#operações-com-elementos)
  - [Copiar e colar](#copiar-e-colar)
  - [Duplicar](#duplicar)
  - [Recortar](#recortar)
- [Simplificar linhas](#simplificar-linhas)
  - [Métodos de simplificação](#métodos-de-simplificação)
  - [Segmentos de linha em curva Bézier](#segmentos-de-linha-em-curva-bézier)
  - [Segmentos de linha mistos](#segmentos-de-linha-mistos)
  - [Segmentos de linha reta](#segmentos-de-linha-reta)
- [Converter segmentos de linha](#converter-segmentos-de-linha)
- [Dividir linha nos pontos selecionados](#dividir-linha-nos-pontos-selecionados)
- [Dividir linhas em cruzamentos](#dividir-linhas-em-cruzamentos)
- [Juntar linhas em extremidades coincidentes](#juntar-linhas-em-extremidades-coincidentes)
- [Mesclar áreas](#mesclar-áreas)
- [Esconder elementos](#esconder-elementos)
- [Pesquisar e selecionar](#pesquisar-e-selecionar)
- [Snap](#snap)
- [Zoom e pan](#zoom-e-pan)

## Barra superior
* À esquerda:
    * ![Ícone voltar](assets/help/images/iconBack.png "Voltar")  _Voltar_: retorna para a janela principal sem salvar o conteúdo.
* À direita:
  * ![Ícone salvar](assets/help/images/iconSave.png "Salvar")  _Salvar_: salva as alterações no mesmo arquivo. Só fica habilitado se houver alterações a serem salvas. (Ctrl+S)
  * ![Ícone salvar como](assets/help/images/iconSaveAs.png "Salvar como")  _Salvar como_: salva as alterações em um novo arquivo. (Shift+Ctrl+S)
  * ![Ícone escolher THConfig e executar Therion](assets/help/images/iconChooseTHConfigAndRunTherion.png "Escolher THConfig e executar Therion") _Escolher THConfig e executar Therion_: mostra a caixa de diálogo do sistema para escolher qual arquivo THConfig será usado para executar o Therion.
  * ![Ícone executar Therion](assets/help/images/iconRunTherion.png "Executar Therion") _Executar Therion_: executa o Therion com o projeto atualmente aberto.
  * ![Ícone ajuda](assets/help/images/iconHelp.png "Ajuda") _Ajuda_: mostra esta caixa de diálogo.
  * ![Ícone fechar](assets/help/images/iconClose.png "Fechar") _Fechar_: fecha a janela de edição do arquivo TH2 sem salvar alterações.

## Abas de arquivo

Quando múltiplos arquivos estão abertos, cada arquivo aparece como uma aba no topo do editor. O nome do arquivo é exibido na aba juntamente com um botão **X** para fechar esse arquivo.

**Recursos das abas:**
* **Alternar entre arquivos**: Clique em qualquer aba para alternar para esse arquivo
* **Fechar um arquivo**: Clique no botão **X** na aba para fechar esse arquivo
* **Rolar as abas**: Se você tiver muitos arquivos abertos, use o mouse para clicar e arrastar horizontalmente nas abas para rolá-las
* **Seleção múltipla**: Use o botão _Abrir arquivo_ na barra superior para selecionar e abrir múltiplos arquivos de uma vez

A aba do arquivo atualmente ativo é destacada, facilitando ver qual arquivo você está editando. Todos os arquivos abertos mantêm seu estado de edição, para que você possa alternar entre eles sem perder seu trabalho.

## Imagens
A janela de imagens é aberta com o botão ![Botão imagens](assets/help/images/buttonImages.png "Imagens") (Alt+I) no canto inferior direito. Ela lista todas as imagens (fundos de levantamento XVI, imagens raster e imagens SVG exclusivas do Mapiah) inseridas no arquivo atual.

Imagens SVG são sempre armazenadas como inserções de imagem exclusivas do Mapiah. Para importar um SVG, o arquivo precisa definir um `viewBox` ou valores numéricos de `width` e `height`. Se nenhum deles estiver disponível, o Mapiah mostra um erro de importação e não insere a imagem.

Um botão _alternar todas_ aparece acima da lista quando há imagens presentes. Seu tooltip e ícone refletem o que o botão fará:
* _Ocultar todas as imagens_ (ícone de olho fechado): exibido quando todas as imagens estão visíveis; clicar oculta todas as imagens.
* _Mostrar todas as imagens_ (ícone de olho): exibido quando alguma imagem está oculta; clicar torna todas as imagens visíveis.

Cada linha de imagem contém:
* Uma caixa de seleção de visibilidade para mostrar ou ocultar a imagem no canvas
* Uma caixa de seleção de visibilidade da grade (somente imagens XVI) para mostrar ou ocultar a grade do levantamento independentemente da imagem
* O nome do arquivo da imagem
* Um botão de edição para entrar no modo de transformação da imagem no canvas
* Um botão de redefinição para restaurar o deslocamento, a escala e a rotação da imagem aos valores padrão
* Um botão de exclusão para remover a imagem
* Um identificador de arrasto (⣿) para reordenar as imagens

### Visibilidade da imagem
Clicar na caixa de seleção de visibilidade alterna se a imagem é exibida no canvas. Imagens ocultas ainda são armazenadas no arquivo.

### Modo de transformação da imagem
Clique no botão de editar de uma linha de imagem para entrar no modo de transformação dessa imagem. A imagem passa a ser destacada no canvas com pequenas alças pretas nos cantos e no meio de cada lado. Clicar novamente na imagem já selecionada enquanto esse modo está ativo alterna para o modo de rotação da imagem, onde as alças dos cantos passam a ser alças curvas de rotação e um marcador de pivô é exibido.

Enquanto o modo de transformação da imagem estiver ativo:
* Arraste a própria imagem para movê-la
* Arraste qualquer alça preta para redimensioná-la
* Clique na imagem selecionada para alternar entre o modo mover/redimensionar e o modo de rotação
* Pressione _H_ para espelhar a imagem horizontalmente
* Pressione _V_ para espelhar a imagem verticalmente
* Use os dois botões de espelhamento mostrados no lado esquerdo do canvas para executar as mesmas ações com o mouse
* Pressione _Esc_ para sair do modo de transformação da imagem

Clique no botão de redefinição em uma linha de imagem para voltar `xx`, `yy` e o ângulo de rotação para `0`, `xScale` e `yScale` para `1`, e a visibilidade da imagem e da grade XVI para o estado padrão visível. A redefinição mantém o XVI root inalterado.

### Movimento da imagem
No modo de transformação da imagem, arraste o corpo da imagem para mover a imagem selecionada.

Movimentação pelo teclado:
* Pressione uma tecla de _Seta_ para mover a imagem selecionada pelo fator de ajuste configurado (`TH2Edit_NudgeFactor`), medido em pixels do canvas
* Pressione _Shift+Seta_ para mover por dez vezes o fator de ajuste
* Pressione _Alt+Seta_ para mover por 1 pixel de tela
* Pressione _Alt+Shift+Seta_ para mover por 10 pixels de tela

Os seguintes modificadores podem ser combinados durante o movimento:
* Mantenha _Alt_ pressionado e arraste em qualquer lugar do canvas para mover a imagem selecionada sem precisar começar sobre o corpo da imagem
* Mantenha _Ctrl_ pressionado enquanto arrasta para restringir o movimento à direção horizontal ou vertical dominante
* Mantenha _Shift_ pressionado enquanto arrasta para desativar temporariamente o snap

### Redimensionamento da imagem
No modo de transformação da imagem, arraste qualquer alça preta para redimensionar a imagem selecionada.

Você também pode espelhar a imagem instantaneamente sem arrastar:
* Pressione _H_ para negar `xScale`
* Pressione _V_ para negar `yScale`
* As ações de espelhamento podem ser desfeitas com _Ctrl+Z_

Modificadores de redimensionamento:
* Mantenha _Ctrl_ pressionado ao arrastar uma alça para preservar a proporção da imagem
* Mantenha _Shift_ pressionado ao arrastar uma alça para redimensionar de forma simétrica em torno do centro da imagem
* Mantenha _Alt_ pressionado ao arrastar uma alça para fazer um redimensionamento mais fino e lento

### Rotação da imagem
Enquanto o modo de transformação da imagem estiver ativo, clique na imagem selecionada para entrar no modo de rotação. As alças dos cantos mudam para alças curvas de rotação e um marcador de pivô aparece.

No modo de rotação:
* Arraste uma alça curva de canto para rotacionar a imagem
* Arraste o marcador de pivô para alterar o centro de rotação
* Mantenha _Ctrl_ pressionado ao rotacionar para aplicar snap do ângulo ao valor configurado
* Mantenha _Shift_ pressionado ao rotacionar para manter o canto oposto fixo

Para imagens XVI com `xviRoot`, o marcador de pivô é mostrado, mas não pode ser movido.

### Visibilidade da grade
Para imagens de fundo XVI, uma segunda caixa de seleção controla se a grade do levantamento é exibida. Ocultar a grade mantém as visadas, as estações e as linhas de esboço visíveis, removendo apenas as linhas da grade do canvas. O estado da visibilidade da grade é salvo com a sessão.

### Reordenação de imagens
Clique e arraste o identificador de arrasto (⣿) de qualquer linha de imagem para alterar sua posição na lista. A ordem das imagens nesta lista determina a ordem de renderização no canvas: imagens listadas antes são desenhadas abaixo das imagens listadas depois. A reordenação pode ser desfeita com _Ctrl+Z_.

Durante o arrasto:
* A linha arrastada desaparece da lista e uma prévia semitransparente dela segue o cursor.
* Uma barra colorida aparece acima da linha onde a imagem arrastada será inserida ao soltar o botão do mouse.

## Modificadores de arrasto
O Mapiah usa os mesmos modificadores de movimento para imagens de fundo, elementos selecionados e pontos finais/controle selecionados no modo de edição de linha. Esses modificadores podem ser combinados.

### Elementos selecionados
Quando um ou mais elementos estão selecionados no modo de seleção:
* Pressione uma tecla de _Seta_ para mover os elementos selecionados pelo fator de ajuste configurado (`TH2Edit_NudgeFactor`), medido em pixels do canvas
* Pressione _Shift+Seta_ para mover por dez vezes o fator de ajuste
* Pressione _Alt+Seta_ para mover por 1 pixel de tela
* Pressione _Alt+Shift+Seta_ para mover por 10 pixels de tela
* Arraste os elementos selecionados para movê-los normalmente
* Mantenha _Alt_ pressionado e arraste em qualquer lugar do canvas para mover a seleção atual sem alterar a seleção
* Mantenha _Ctrl_ pressionado enquanto arrasta para restringir o movimento à direção horizontal ou vertical dominante
* Mantenha _Shift_ pressionado enquanto arrasta para desativar temporariamente o snap

Se a configuração `TH2Edit_EnableElementTransforms` estiver ativada, a seleção atual também passa a suportar redimensionamento, rotação e espelhamento:
* Arraste qualquer alça da seleção para redimensionar os elementos selecionados
* Mantenha _Ctrl_ pressionado enquanto arrasta uma alça da seleção para preservar a proporção atual
* Mantenha _Shift_ pressionado enquanto arrasta uma alça da seleção para redimensionar de forma simétrica em torno do centro da seleção
* Mantenha _Alt_ pressionado enquanto arrasta uma alça da seleção para um redimensionamento mais fino e lento
* Clique nos elementos selecionados para alternar do modo normal de seleção para o modo de rotação de elementos
* No modo de rotação de elementos, arraste uma alça de canto da seleção para rotacionar a seleção
* Mantenha _Ctrl_ pressionado enquanto rotaciona para ajustar o ângulo ao valor configurado
* Mantenha _Shift_ pressionado enquanto rotaciona para manter o canto oposto fixo
* Pressione _H_ para espelhar a seleção horizontalmente
* Pressione _V_ para espelhar a seleção verticalmente

### Pontos finais/controle em edição de linha
Quando um ou mais pontos finais/controle estão selecionados no modo de edição de linha:
* Pressione uma tecla de _Seta_ para mover o ponto ou os pontos selecionados pelo fator de ajuste configurado (`TH2Edit_NudgeFactor`), medido em pixels do canvas
* Pressione _Shift+Seta_ para mover por dez vezes o fator de ajuste
* Pressione _Alt+Seta_ para mover por 1 pixel de tela
* Pressione _Alt+Shift+Seta_ para mover por 10 pixels de tela
* Arraste o ponto ou os pontos selecionados para movê-los normalmente
* Mantenha _Alt_ pressionado e arraste em qualquer lugar do canvas para mover a seleção atual de pontos sem alterar a seleção
* Mantenha _Ctrl_ pressionado enquanto arrasta para restringir o movimento à direção horizontal ou vertical dominante
* Mantenha _Shift_ pressionado enquanto arrasta para desativar temporariamente o snap

## Croquis
Só é possível trabalhar em um croqui por vez. Para trocar o croqui atual, clique no botão de seleção de croquis ![Botão Croquis](assets/help/images/buttonScraps.png "Scraps") no canto inferior direito e escolha o croqui desejado na caixa de diálogo apresentada.

Você também pode _Alt+clicar_ em um croqui inativo para torná-lo o croqui atual.

Cada croqui é listado como uma linha na caixa de diálogo. A linha contém:
* Um botão de rádio para selecioná-lo como o croqui ativo
* Uma caixa de seleção de visibilidade (quando o arquivo tem mais de um croqui) — veja [Visibilidade do croqui](#visibilidade-do-croqui)
* Quatro botões de ícone: _Copiar croqui_, _Recortar croqui_, _Duplicar croqui_ e _Remover croqui_
* Um identificador de arrasto (⣿) para reordenar os croquis (quando o arquivo tem mais de um croqui) — veja [Reordenação de croquis](#reordenação-de-croquis)

Um botão _alternar todos_ aparece acima da lista (quando o arquivo tem mais de um croqui). Seu tooltip e ícone refletem o que o botão fará:
* _Ocultar todos exceto o ativo_ (ícone de olho fechado): exibido quando todos os croquis estão visíveis; clicar oculta todos os croquis exceto o ativo.
* _Mostrar todos os croquis_ (ícone de olho): exibido quando algum croqui está oculto; clicar torna todos os croquis visíveis.

### Copiar croqui
Copia todos os elementos do croqui para a área de transferência sem remover o croqui. O conteúdo da área de transferência pode então ser colado com _Ctrl+V_ no mesmo arquivo ou em outro arquivo aberto.

### Recortar croqui
Copia todos os elementos do croqui para a área de transferência e então remove o croqui do arquivo. O conteúdo da área de transferência pode então ser colado com _Ctrl+V_ no mesmo arquivo ou em outro arquivo aberto. A operação de recortar pode ser desfeita com _Ctrl+Z_, que restaura o croqui e todos os seus elementos.

### Duplicar croqui
Duplica o croqui inteiro, incluindo todos os seus elementos, criando um novo croqui no mesmo arquivo. Novos IDs exclusivos são gerados para todos os elementos duplicados. A operação de duplicação pode ser desfeita com _Ctrl+Z_.

### Visibilidade do croqui
Quando o arquivo tem mais de um croqui, uma caixa de seleção de visibilidade aparece em todas as linhas de croqui, incluindo a do croqui ativo. Marcar ou desmarcar essa caixa alterna se aquele croqui é exibido no canvas.

Se apenas um croqui estiver visível no momento, a caixa de seleção do croqui ativo fica desabilitada para evitar ocultar todos os croquis. Quando o croqui ativo é ocultado, o Mapiah troca automaticamente o croqui ativo pelo mais próximo que estava visível anteriormente.

Se o arquivo tiver apenas um croqui, a caixa de seleção de visibilidade fica oculta.

### Reordenação de croquis
Clique e arraste o identificador de arrasto (⣿) de qualquer linha de croqui para alterar sua posição na lista. A reordenação pode ser desfeita com _Ctrl+Z_.

Durante o arrasto:
* A linha arrastada desaparece da lista e uma prévia semitransparente dela segue o cursor.
* Uma barra colorida aparece acima da linha onde o croqui arrastado será inserido ao soltar o botão do mouse.

## Desenhando linhas
Ao desenhar linhas, cada novo segmento é inicialmente criado como um segmento de linha reta. Para convertê-lo em um segmento de curva Bézier, não solte o botão do mouse e arraste. A posição do mouse será tratada como a posição do único ponto de controle de uma curva Bézier quadrática.

O comportamento exato desse arrasto depende da opção de configuração "Método de criação de nova linha". "Quadrático do Mapiah" mantém o comportamento atual descrito abaixo. "Cúbico suave do xTherion" usa a posição arrastada como o futuro ponto de controle do próximo segmento, espelha o outro ponto de controle do segmento atual em torno do ponto final compartilhado e permite manter Ctrl pressionado durante o arrasto para fixar a distância do ponto de controle espelhado.

Ao desenhar uma linha, você também pode mover pelo teclado o último nó criado:
* Pressione uma tecla _Seta_ para movê-lo pelo fator de nudge configurado (`TH2Edit_NudgeFactor`), medido em pixels do canvas
* Pressione _Shift+Seta_ para mover por dez vezes o fator de nudge
* Pressione _Alt+Seta_ para mover por 1 pixel de tela
* Pressione _Alt+Shift+Seta_ para mover por 10 pixels de tela

Curvas Bézier no Therion (e no Mapiah) são curvas cúbicas, isto é, têm 2 pontos de controle para cada segmento. Apenas durante a criação do segmento, o Mapiah finge que a curva Bézier sendo criada é uma Bézier quadrática (com apenas um ponto de controle) para dar flexibilidade ao usuário na criação do segmento.

Observe que, apesar de o Mapiah simular a existência de apenas um ponto de controle, uma curva Bézier cúbica real é criada com dois pontos de controle, como esperado.

### Conexão de mapa
Para os pontos do tipo Corte selectionados, ao pressionar Ctrl+X, o Mapiah procura por uma opção "Croqui" que termine com "-xs-BASE", onde BASE será tratada como a base onde o corte foi criado. Ele procura por um tipo de ponto base com sua opção "Nome" definida como BASE. Se ambos forem encontrados, uma linha do tipo "conexão de mapa" é criada entre o ponto do corte e o ponto da base.

## Janela de edição

### Canto superior direito
* _Pesquisar_: abre a caixa de diálogo de pesquisa e seleção. (Ver [Pesquisar e selecionar](#pesquisar-e-selecionar))
* ![Botão Snap](assets/help/images/buttonSnap.png "Snap")  _Snap_: alterna a janela de snap, onde são apresentadas as opções de snap. (Ctrl+L)
* _Opções padrão_: abre a janela de opções padrão, onde é possível configurar valores padrão de opções para novos pontos, linhas e áreas. (O sem elementos selecionados)
* ![Botão deletar](assets/help/images/buttonDelete.png "Deletar")  _Deletar_: apaga os elementos atualmente selecionados. Só fica habilitado se houver pelo menos um elemento selecionado. (Delete/Backspace)
* ![Botão desfazer](assets/help/images/buttonUndo.png "Desfazer")  _Desfazer_: desfaz a última operação de edição executada. Só fica habilitado se houver pelo menos uma operação a desfazer. (Ctrl+Z)
* ![Botão refazer](assets/help/images/buttonRedo.png "Refazer")  _Refazer_: refaz a última operação desfeita. Só fica habilitado se houver pelo menos uma operação a refazer. (Ctrl+Y)

Caso existam operações no stack de refazer e uma nova operação de edição seja executada, o stack de refazer é migrado para o stack de desfazer, mantendo os “refazer” acessíveis.

### Canto inferior direito
* ![Botão imagens](assets/help/images/buttonImages.png “Imagens”)  _Imagens_: abre a janela de imagens (overlay). Mostra todas as imagens inseridas no arquivo atual. Cada linha de imagem possui uma caixa de seleção de visibilidade, uma caixa de seleção de visibilidade da grade (somente imagens XVI), um botão de exclusão e um identificador de arrasto para reordenação. Também apresenta um botão “Add Image (I)”. (Alt+I)
* ![Botão scraps](assets/help/images/buttonScraps.png "Scraps")  _Scraps_: abre uma caixa de diálogo para mudar o scrap atual, excluir um scrap existente e adicionar um novo. A caixa de diálogo mostra todos os scraps disponíveis e permite selecionar um deles. A janela de opções do scrap (overlay) é apresentada ao clicar com o botão direito no scrap desejado. (Alt+C)
* ![Botão selecionar elemento](assets/help/images/buttonSelectElement.png "Selecionar elemento")  _Selecionar elemento_: permite selecionar elementos no arquivo TH2. (C)
* ![Botão editar linha](assets/help/images/buttonLineEdit.png "Editar linha")  _Editar linha_: permite editar linhas individuais no arquivo TH2. (N)
  * Um clique duplo em uma linha ou em um de seus segmentos de linha visíveis, usando a ferramenta _Selecionar elemento_, também entra no modo _Editar linha_ para aquela linha.
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

## Opções padrão

Opções padrão são valores de opção que são automaticamente aplicados a novos pontos, linhas ou áreas do tipo correspondente. São definidas uma vez e reutilizadas em todas as criações subsequentes de elementos até serem alteradas ou removidas.

Abra a janela de opções padrão:
* Pressionando 'O' sem nenhum elemento selecionado, ou
* Clicando no botão _Opções padrão_ (ícone de ajuste) no canto superior direito.

A janela contém três abas: **Pontos**, **Linhas** e **Áreas**. Selecione a aba da categoria do elemento para a qual deseja configurar os padrões.

Dentro de cada aba, as opções disponíveis funcionam de forma idêntica ao editor de opções do elemento. Definir uma opção a armazena como padrão para a categoria selecionada. Remover uma opção a exclui dos padrões.

Apenas opções aplicáveis ao tipo específico do elemento recém-criado são aplicadas. Por exemplo, se uma opção "clip" padrão for definida para linhas, ela só será aplicada ao criar tipos de linha que suportam a opção "clip".

O botão **Redefinir** no topo da janela limpa todos os padrões da aba atualmente exibida. O botão fica desabilitado quando nenhum padrão está definido para aquela categoria.

## Salvar

### Formato original do arquivo
O Mapiah preserva o máximo possível a formatação original do arquivo ao salvar. No entanto, algumas mudanças são feitas durante o parsing e aparecem na versão salva mesmo que o usuário não tenha editado nada:
* Pontos consecutivos de linha com pontos finais idênticos são mesclados em um único ponto de linha.
* Linhas com zero ou um ponto de linha são removidas.
* Referências inexistentes de borda de área são removidas, isto é, a área menciona um ID de borda, mas não há uma linha com o mesmo ID no arquivo.
* Áreas sem referências de borda são removidas.
* Opções de linha definidas na área [LINE DATA] são movidas para a definição da linha. Não confundir com opções de ponto de linha, que são definidas na área [LINE DATA] e são preservadas lá.
* Opções de subtipo definidas antes do primeiro ponto de linha ou no primeiro ponto são transformadas em subtipo da linha.

## Selecionando elementos
Para selecionar um elemento, clique nele com a ferramenta _Selecionar elemento_ ativa. Para selecionar vários elementos, mantenha a tecla _Shift_ pressionada enquanto clica neles. Para deselecionar um elemento, mantenha a tecla _Shift_ pressionada enquanto clica nele. Para selecionar todos os elementos, use a opção _Selecionar tudo_ na ferramenta _Selecionar elemento_ ou use o atalho de teclado _Ctrl+A_.

Também é possível selecionar elementos arrastando uma janela de seleção com o mouse. Para fazer isso, clique e segure o botão esquerdo do mouse em uma área vazia do canvas e arraste o mouse. Todos os elementos que estão total ou parcialmente dentro da janela de seleção serão selecionados. Para adicionar elementos à seleção, mantenha a tecla _Shift_ pressionada enquanto arrasta a janela de seleção.

Ao clicar em uma linha que define a borda de uma área, o comportamento depende das teclas modificadoras pressionadas:

1. **Sem modificador (ou modificadores diferentes de Ctrl+Shift)**: tanto a área quanto a linha são candidatas à seleção. Se exatamente uma delas já estiver selecionada, a outra é adicionada; caso contrário, a caixa de diálogo "Vários elementos clicados" é exibida para que você escolha qual(is) elemento(s) adicionar à seleção.
2. **Ctrl+clique (sem Alt nem Shift)**: apenas linhas de borda são adicionadas à seleção diretamente, sem exibir a caixa de diálogo. Se a área tiver mais de uma linha de borda, o primeiro clique seleciona todas as linhas de borda dessa área. Cliques adicionais com Ctrl, enquanto você mantiver Ctrl pressionado, percorrem as linhas de borda da mesma área na ordem em que aparecem nos `THAreaBorderTHIDs` da área e depois voltam a selecionar todas as linhas de borda.
3. **Ctrl+Alt+clique (sem Shift)**: apenas a área é adicionada à seleção diretamente, sem exibir a caixa de diálogo.

## Operações com elementos

### Copiar e colar
Elementos selecionados podem ser copiados para uma área de transferência (clipboard) e colados no arquivo atual ou em outro arquivo aberto.

**Para copiar elementos selecionados:**
- Pressione _Ctrl+C_
- Pelo menos um elemento deve estar selecionado

**Para colar elementos copiados:**
- Pressione _Ctrl+V_
- Os elementos colados aparecem no croqui atual
- Todos os elementos filhos (segmentos de linha, bordas de área, etc.) são automaticamente incluídos na colagem
- As referências de THID são automaticamente resolvidas para evitar conflitos: se o THID de um elemento colado já existe no arquivo de destino, um novo THID exclusivo é automaticamente gerado
- Os elementos colados se tornam a nova seleção, deixando-os prontos para edição ou movimento adicional
- A operação de colagem pode ser desfeita com _Ctrl+Z_

**Colagem entre arquivos:**
Quando você tem múltiplos arquivos abertos em abas, você pode copiar elementos de um arquivo e colá-los em outro arquivo. Simplesmente alterne para a aba do arquivo de destino e pressione _Ctrl+V_.

### Duplicar
Elementos selecionados podem ser rapidamente duplicados no mesmo lugar.

**Para duplicar elementos selecionados:**
- Pressione _Ctrl+D_
- Todos os elementos selecionados e seus filhos são duplicados
- Os elementos duplicados aparecem na mesma posição que os originais
- A operação de duplicação cria novos IDs exclusivos para todos os elementos duplicados
- Os elementos duplicados se tornam a nova seleção
- A operação de duplicação pode ser desfeita com _Ctrl+Z_

### Recortar
Elementos selecionados podem ser recortados (copiados para a área de transferência e imediatamente removidos do arquivo).

**Para recortar elementos selecionados:**
- Pressione _Ctrl+X_
- Pelo menos um elemento deve estar selecionado
- Os elementos são copiados para a área de transferência e então removidos do arquivo
- O conteúdo da área de transferência pode ser colado com _Ctrl+V_ no mesmo arquivo ou em outro arquivo aberto
- A operação de recortar pode ser desfeita com _Ctrl+Z_, que restaura os elementos nas suas posições originais

## Simplificar linhas
Curvas Bézier e segmentos de linha reta são simplificados de forma diferente. Para simplificar linhas, selecione-as primeiro. É possível ter outros tipos de elementos selecionados (pontos ou áreas) durante a simplificação; eles não serão alterados pelo processo.

### Métodos de simplificação
Há três métodos de simplificação de linha disponíveis:
* __Manter tipos originais (Ctrl+L)__: cada segmento de linha é simplificado usando o algoritmo de simplificação do seu próprio tipo.
* __Forçar Bézier (Ctrl+Alt+L)__: todos os segmentos de linha são, se necessário, primeiro convertidos para curvas Bézier e então simplificados usando o algoritmo de simplificação de Bézier.
* __Forçar reta (Ctrl+Shift+L)__: todos os segmentos de linha são, se necessário, primeiro convertidos para retas e então simplificados usando o algoritmo de simplificação de reta.

O __diálogo de simplificação interativa de linhas (Ctrl+Alt+Shift+L)__ expõe esses mesmos parâmetros com uma visualização imediata. Use-o para alternar entre os três métodos e ajustar a intensidade da simplificação antes de confirmar o resultado final. Fechar o diálogo, salvá-lo ou clicar fora dele mantém a visualização atual como uma única ação desfazível. Cancelar restaura as linhas selecionadas originais sem criar uma entrada de desfazer.

### Segmentos de linha em curva Bézier
Cada pressionamento de _Ctrl+[Alt]+L_ executa uma rodada de simplificação. O Mapiah usa um algoritmo interativo para simplificar segmentos em curva Bézier. Ele opera no espaço do canvas. A tolerância inicial (epsilon) equivale a 1,5 pixels de tela. Esse valor é convertido para coordenadas do canvas. Em cada execução subsequente, a tolerância é aumentada pelo mesmo valor inicial.

### Segmentos de linha mistos
Quando uma linha contém tanto segmentos em curva Bézier quanto segmentos retos, o Mapiah trata cada parte separadamente. Cada parte contendo apenas segmentos Bézier é simplificada usando o algoritmo de simplificação de Bézier. Cada parte contendo apenas segmentos retos é simplificada usando o algoritmo de simplificação de reta.

### Segmentos de linha reta
Cada pressionamento de _Ctrl+[Shift]+L_ executa uma rodada de simplificação. O Mapiah usa uma versão interativa (não recursiva) do [algoritmo de Ramer–Douglas–Peucker](https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm) para simplificar segmentos de linha reta. Ele opera no espaço do canvas. A tolerância inicial (epsilon) equivale a 1,5 pixels de tela. Esse valor é convertido para coordenadas do canvas. Em cada execução subsequente, a tolerância é aumentada pelo mesmo valor inicial.

## Converter segmentos de linha

O Mapiah pode converter segmentos de linha entre os tipos reta e Bézier sem alterar a seleção da linha.

**Atalhos e botões:**
- Pressione `J` ou clique no botão **Converter segmentos de linha para Bézier** para converter para Bézier.
- Pressione `Shift+J` ou clique no botão **Converter segmentos de linha para reta** para converter para reta.

**Quando está disponível:**
- No modo de edição de linha (_N_), a ação fica habilitada quando pelo menos um ponto selecionado não é o ponto inicial da linha.
- No modo de seleção (_C_), a ação fica habilitada quando pelo menos uma linha está selecionada.

**Como funciona:**
- No modo de edição de linha, apenas os segmentos selecionados que não são o segmento inicial são convertidos.
- No modo de seleção, todas as linhas selecionadas são processadas e cada segmento não inicial é convertido para o tipo solicitado.
- Segmentos que já estão no tipo solicitado permanecem inalterados.
- Linhas mistas podem ser convertidas em qualquer direção.
- A operação pode ser desfeita com _Ctrl+Z_.

## Dividir linha nos pontos selecionados

No modo de edição de linha (_N_), selecione um ou mais pontos internos da linha e pressione _Ctrl+P_ para dividir a linha em múltiplas linhas nesses pontos.

**Como funciona:**
- A primeira nova linha contém todos os segmentos desde o início da linha original até o primeiro ponto selecionado (inclusive).
- Cada linha subsequente começa com um novo segmento reto cujo ponto final é uma cópia da posição do último ponto de divisão selecionado, seguido pelos segmentos originais até o próximo ponto selecionado (ou o fim da linha).
- Após a divisão, todas as novas linhas criadas ficam selecionadas.
- A operação pode ser desfeita com _Ctrl+Z_.

**IDs:** Se a linha original possuía a opção `-id` (por exemplo, `parede1`), cada nova linha recebe um ID derivado: `parede1-1`, `parede1-2`, e assim por diante.

**Limitação:** Linhas que fazem parte da borda de uma área não podem ser divididas. Uma mensagem é exibida caso isso seja tentado.

## Dividir linhas em cruzamentos

Pressione `Ctrl+Shift+X` para dividir as linhas selecionadas em cada interseção com outras linhas selecionadas no mesmo croqui.

**Como funciona:**
- Para cada linha selecionada, cada ponto de cruzamento com qualquer outra linha selecionada é calculado.
- Cada cruzamento vira um ponto de divisão, produzindo múltiplas linhas.
- As novas linhas herdam as opções da original; se a linha original possuía a opção `-id` (por exemplo, `parede1`), cada nova linha recebe um ID derivado: `parede1-1`, `parede1-2`, e assim por diante.
- Após a divisão, todas as linhas recém-criadas ficam selecionadas.
- A operação pode ser desfeita com `Ctrl+Z`.
- **Limitação:** Linhas que fazem parte da borda de uma área não podem ser divididas. Uma mensagem é exibida caso isso seja tentado.

## Juntar linhas em extremidades coincidentes

Pressione `Ctrl+J` (ou clique no botão **Juntar linhas em extremidades coincidentes**) para juntar linhas selecionadas cujas extremidades de início/fim coincidam.

**Quando está disponível:**
A ação fica habilitada quando há pelo menos duas linhas selecionadas.

**Como funciona:**
- A operação verifica as linhas selecionadas em busca de extremidades coincidentes usando tolerância equivalente a 3 pixels de tela (convertida para coordenadas de canvas no momento da execução, conforme o zoom atual).
- Uma única execução pode produzir múltiplas linhas finais quando as linhas selecionadas formam grupos independentes.
- Para cada linha final criada, prevalecem o tipo e as opções da primeira linha selecionada naquele grupo.
- Os segmentos são reorientados quando necessário para manter continuidade geométrica; segmentos Bézier invertidos preservam a mesma forma visual.
- As linhas finais criadas ficam selecionadas.
- A operação pode ser desfeita com _Ctrl+Z_.

Se não houver extremidades coincidentes, o Mapiah exibe uma mensagem e não altera o arquivo.

## Mesclar áreas

Pressione _Ctrl+M_ (ou clique no botão **Mesclar áreas**) para mesclar as linhas de borda das áreas selecionadas no menor número possível de linhas fechadas, substituindo as áreas selecionadas por uma única área mesclada.

**Quando está disponível:**
A ação é habilitada quando o número total de linhas de borda distintas entre as áreas selecionadas for dois ou mais. As áreas podem ser selecionadas diretamente, ou indiretamente pela seleção de uma ou mais de suas linhas de borda. Isso cobre dois cenários comuns:
- Uma área que já possui mais de uma linha de borda (`THAreaBorderTHID`).
- Duas ou mais áreas selecionadas, seja selecionando as próprias áreas ou suas linhas de borda.

**Como funciona:**
1. O Mapiah coleta todas as áreas selecionadas, mais quaisquer áreas referenciadas por linhas de borda selecionadas, e então reúne suas linhas de borda distintas (LTSAs — Linhas a Mesclar das Áreas Selecionadas).
2. Qualquer LTSA que não esteja fechada (último ponto ≠ primeiro ponto) é automaticamente fechada com um segmento reto.
3. As LTSAs são agrupadas por possibilidade de mesclagem. Linhas pertencem ao mesmo grupo quando se cruzam ou compartilham um segmento geometricamente idêntico; linhas isoladas formam grupos individuais.
4. Para cada grupo com mais de uma linha, todos os segmentos são montados em uma única linha mesclada usando um algoritmo de traçado do contorno externo.
5. Uma única nova área é criada, referenciando todas as linhas mescladas como suas bordas.
6. A área mesclada resultante fica selecionada após a operação.
7. A operação pode ser desfeita com _Ctrl+Z_.

**Opções e IDs:**
- A nova área herda todas as opções (tipo, subtipo etc.) da primeira área selecionada.
- Cada linha mesclada herda todas as opções da primeira LTSA do seu grupo.
- IDs Therion explícitos (`-id`) são preservados quando existiam na área canônica e na linha canônica de cada grupo. Linhas e áreas sem ID explícito recebem IDs gerados automaticamente para que possam ser corretamente referenciados como bordas de área.

Se forem detectados segmentos fora do contorno externo durante a mesclagem, o Mapiah exibe uma mensagem de erro e não realiza alterações.

## Esconder elementos
Pressione _Ctrl+H_ para ocultar temporariamente elementos no canvas sem removê-los do arquivo.

**Quando há elementos selecionados:**
* Os elementos selecionados são adicionados à lista de ocultos e deselecionados.
* Elementos ocultos não são desenhados no canvas e não podem ser clicados ou selecionados.

**Quando não há elementos selecionados:**
* Todos os elementos ocultos voltam a ser visíveis.

Elementos ocultos são um estado temporário apenas do canvas: não são salvos no arquivo e são sempre restaurados quando o arquivo é reaberto.

## Pesquisar e selecionar
O diálogo de pesquisar e selecionar permite encontrar e selecionar elementos no croqui atual com base em suas características. Abra-o clicando no botão ![Botão Pesquisar](assets/help/images/buttonSearch.png "Pesquisar e selecionar") no canto superior direito.

O diálogo tem três seções recolhíveis: **Pontos**, **Linhas** e **Áreas**. Ative uma seção marcando sua caixa de seleção. Cada seção ativada oferece critérios de filtragem:

* **Todos**: seleciona todos os elementos daquele tipo no croqui atual. Ativar esta opção desativa os outros critérios.
* **Por ID**: filtra elementos cujo ID do Therion contém o texto digitado (correspondência parcial, sem distinção de maiúsculas/minúsculas).
* **Por subtipo**: filtra elementos pelo subtipo. Selecione subtipos conhecidos nos chips e/ou digite texto livre para subtipos desconhecidos. Disponível apenas para pontos e linhas.
* **Por tipo**: filtra elementos pelo tipo. Selecione um ou mais tipos dos chips disponíveis. Tipos desconhecidos encontrados no croqui atual também são listados.
* **Por opção**: filtra elementos por opções específicas estarem definidas ou não. Cada opção pode ser definida como _Indefinido_ (ignorado), _Definido_ (elemento deve ter a opção) ou _Não definido_ (elemento não deve ter a opção).
* **Por opção de segmento de linha** _(apenas linhas)_: filtra linhas pela presença ou ausência de opções específicas em seus segmentos de linha. Cada opção pode ser definida como _Indefinido_ (ignorado), _Definido_ (pelo menos um segmento da linha deve ter a opção) ou _Não definido_ (nenhum segmento da linha pode ter a opção).

Quando múltiplos critérios estão ativados dentro de uma seção, um elemento deve corresponder a **todos** eles (lógica E). Quando múltiplas seções estão ativadas, elementos correspondentes de qualquer seção são incluídos (lógica OU).

Uma barra de status na parte inferior mostra o número de elementos que correspondem aos critérios atuais, atualizada ao vivo conforme você altera os filtros.

**Botões de ação:**
* **Definir seleção**: substitui a seleção atual pelos elementos correspondentes.
* **Adicionar à seleção**: adiciona os elementos correspondentes à seleção atual.
* **Remover da seleção**: remove os elementos correspondentes da seleção atual.
* **Cancelar**: fecha o diálogo sem alterar a seleção.
* **Redefinir**: redefine todos os critérios sem fechar o diálogo.

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
