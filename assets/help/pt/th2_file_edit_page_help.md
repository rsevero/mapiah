<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
Aqui é onde toda a edição de arquivos TH2 é feita.

## Índice
- [Índice](#índice)
- [Barra superior](#barra-superior)
- [Abas de arquivo](#abas-de-arquivo)
- [Croquis](#croquis)
  - [Copiar croqui](#copiar-croqui)
  - [Recortar croqui](#recortar-croqui)
  - [Duplicar croqui](#duplicar-croqui)
  - [Visibilidade do croqui](#visibilidade-do-croqui)
- [Desenhando linhas](#desenhando-linhas)
  - [Conexão de mapa](#conexão-de-mapa)
- [Janela de edição](#janela-de-edição)
  - [Canto superior direito](#canto-superior-direito)
  - [Canto inferior direito](#canto-inferior-direito)
- [Opções do elemento](#opções-do-elemento)
- [Imagens](#imagens)
  - [Visibilidade da imagem](#visibilidade-da-imagem)
  - [Reordenação de imagens](#reordenação-de-imagens)
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
A janela de imagens é aberta com o botão ![Botão imagens](assets/help/images/buttonImages.png "Imagens") (Alt+I) no canto inferior direito. Ela lista todas as imagens (fundos de levantamento XVI e imagens raster) inseridas no arquivo atual.

Um botão _alternar todas_ aparece acima da lista quando há imagens presentes. Seu tooltip e ícone refletem o que o botão fará:
* _Ocultar todas as imagens_ (ícone de olho fechado): exibido quando todas as imagens estão visíveis; clicar oculta todas as imagens.
* _Mostrar todas as imagens_ (ícone de olho): exibido quando alguma imagem está oculta; clicar torna todas as imagens visíveis.

Cada linha de imagem contém:
* Uma caixa de seleção de visibilidade para mostrar ou ocultar a imagem no canvas
* O nome do arquivo da imagem
* Um botão de exclusão para remover a imagem
* Um identificador de arrasto (⣿) para reordenar as imagens

### Visibilidade da imagem
Clicar na caixa de seleção alterna se a imagem é exibida no canvas. Imagens ocultas ainda são armazenadas no arquivo.

### Reordenação de imagens
Clique e arraste o identificador de arrasto (⣿) de qualquer linha de imagem para alterar sua posição na lista. A ordem das imagens nesta lista determina a ordem de renderização no canvas: imagens listadas antes são desenhadas abaixo das imagens listadas depois. A reordenação pode ser desfeita com _Ctrl+Z_.

Durante o arrasto:
* A linha arrastada desaparece da lista e uma prévia semitransparente dela segue o cursor.
* Uma barra colorida aparece acima da linha onde a imagem arrastada será inserida ao soltar o botão do mouse.

## Croquis
Só é possível trabalhar em um croqui por vez. Para trocar o croqui atual, clique no botão de seleção de croquis ![Botão Croquis](assets/help/images/buttonScraps.png "Scraps") no canto inferior direito e escolha o croqui desejado na caixa de diálogo apresentada.

Você também pode _Alt+clicar_ em um croqui inativo para torná-lo o croqui atual.

Cada croqui é listado como uma linha na caixa de diálogo. A linha contém:
* Um botão de rádio para selecioná-lo como o croqui ativo
* Uma caixa de seleção de visibilidade (quando o arquivo tem mais de um croqui) — veja [Visibilidade do croqui](#visibilidade-do-croqui)
* Quatro botões de ícone: _Copiar croqui_, _Recortar croqui_, _Duplicar croqui_ e _Remover croqui_

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

## Desenhando linhas
Ao desenhar linhas, cada novo segmento é inicialmente criado como um segmento de linha reta. Para convertê-lo em um segmento de curva Bézier, não solte o botão do mouse e arraste. A posição do mouse será tratada como a posição do único ponto de controle de uma curva Bézier quadrática.

O comportamento exato desse arrasto depende da opção de configuração "Método de criação de nova linha". "Quadrático do Mapiah" mantém o comportamento atual descrito abaixo. "Cúbico suave do xTherion" usa a posição arrastada como o futuro ponto de controle do próximo segmento, espelha o outro ponto de controle do segmento atual em torno do ponto final compartilhado e permite manter Ctrl pressionado durante o arrasto para fixar a distância do ponto de controle espelhado.

Curvas Bézier no Therion (e no Mapiah) são curvas cúbicas, isto é, têm 2 pontos de controle para cada segmento. Apenas durante a criação do segmento, o Mapiah finge que a curva Bézier sendo criada é uma Bézier quadrática (com apenas um ponto de controle) para dar flexibilidade ao usuário na criação do segmento.

Observe que, apesar de o Mapiah simular a existência de apenas um ponto de controle, uma curva Bézier cúbica real é criada com dois pontos de controle, como esperado.

### Conexão de mapa
Para os pontos do tipo Corte selectionados, ao pressionar Ctrl+X, o Mapiah procura por uma opção "Croqui" que termine com "-xs-BASE", onde BASE será tratada como a base onde o corte foi criado. Ele procura por um tipo de ponto base com sua opção "Nome" definida como BASE. Se ambos forem encontrados, uma linha do tipo "conexão de mapa" é criada entre o ponto do corte e o ponto da base.

## Janela de edição

### Canto superior direito
* ![Botão Snap](assets/help/images/buttonSnap.png "Snap")  _Snap_: alterna a janela de snap, onde são apresentadas as opções de snap. (Ctrl+L)
* ![Botão deletar](assets/help/images/buttonDelete.png "Deletar")  _Deletar_: apaga os elementos atualmente selecionados. Só fica habilitado se houver pelo menos um elemento selecionado. (Delete/Backspace)
* ![Botão desfazer](assets/help/images/buttonUndo.png "Desfazer")  _Desfazer_: desfaz a última operação de edição executada. Só fica habilitado se houver pelo menos uma operação a desfazer. (Ctrl+Z)
* ![Botão refazer](assets/help/images/buttonRedo.png "Refazer")  _Refazer_: refaz a última operação desfeita. Só fica habilitado se houver pelo menos uma operação a refazer. (Ctrl+Y)

Caso existam operações no stack de refazer e uma nova operação de edição seja executada, o stack de refazer é migrado para o stack de desfazer, mantendo os “refazer” acessíveis.

### Canto inferior direito
* ![Botão imagens](assets/help/images/buttonImages.png “Imagens”)  _Imagens_: abre a janela de imagens (overlay). Mostra todas as imagens inseridas no arquivo atual. Cada linha de imagem possui uma caixa de seleção de visibilidade, um botão de exclusão e um identificador de arrasto para reordenação. Também apresenta um botão “Add Image (I)”. (Alt+I)
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

## Selecionando elementos
Para selecionar um elemento, clique nele com a ferramenta _Selecionar elemento_ ativa. Para selecionar vários elementos, mantenha a tecla _Shift_ pressionada enquanto clica neles. Para deselecionar um elemento, mantenha a tecla _Shift_ pressionada enquanto clica nele. Para selecionar todos os elementos, use a opção _Selecionar tudo_ na ferramenta _Selecionar elemento_ ou use o atalho de teclado _Ctrl+A_.

Também é possível selecionar elementos arrastando uma janela de seleção com o mouse. Para fazer isso, clique e segure o botão esquerdo do mouse em uma área vazia do canvas e arraste o mouse. Todos os elementos que estão total ou parcialmente dentro da janela de seleção serão selecionados. Para adicionar elementos à seleção, mantenha a tecla _Shift_ pressionada enquanto arrasta a janela de seleção.

Quando clicar em uma linha que define uma área, o usuário será apresentado com uma caixa de diálogo "Vários elementos clicados", onde poderá escolher qual elemento selecionar. As opções são a própria linha e a área definida pela linha. Se você Ctrl+Clicar (ou Meta+Clicar) em uma linha que define uma área, a área será selecionada diretamente sem mostrar a caixa de diálogo "Vários elementos clicados". Se você Shift+Ctrl+Clicar (ou Shift+Meta+Clicar) em uma linha que define uma área, a linha será selecionada diretamente sem mostrar a caixa de diálogo "Vários elementos clicados".

## Operações com elementos

### Copiar e colar
Elementos selecionados podem ser copiados para uma área de transferência (clipboard) e colados no arquivo atual ou em outro arquivo aberto.

**Para copiar elementos selecionados:**
- Pressione _Ctrl+C_ (ou _Meta+C_ no macOS)
- Pelo menos um elemento deve estar selecionado

**Para colar elementos copiados:**
- Pressione _Ctrl+V_ (ou _Meta+V_ no macOS)
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
- Pressione _Ctrl+X_ (ou _Meta+X_ no macOS)
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
