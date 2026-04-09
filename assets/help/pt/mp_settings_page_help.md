<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
Esta página permite configurar as preferências do Mapiah. As configurações são agrupadas em seções exibidas como cartões.

_Observação: no Mapiah as teclas Ctrl e Meta (Command no macOS) são intercambiáveis. Nas menções de atalhos abaixo usa-se "Ctrl" por brevidade._

## Índice
- [Índice](#índice)
- [Usando as configurações](#usando-as-configurações)
  - [Redefinindo uma configuração individual](#redefinindo-uma-configuração-individual)
  - [Botões](#botões)
- [Seção Principal](#seção-principal)
  - [Idioma](#idioma)
- [Seção Edição TH2](#seção-edição-th2)
  - [Espessura da linha](#espessura-da-linha)
  - [Método de criação de nova linha](#método-de-criação-de-nova-linha)
  - [Raio do ponto](#raio-do-ponto)
  - [Ângulo preferencial](#ângulo-preferencial)
  - [Tolerância de seleção](#tolerância-de-seleção)
  - [Mostrar marcas de direção em linhas não selecionadas](#mostrar-marcas-de-direção-em-linhas-não-selecionadas)
- [Seção Therion](#seção-therion)
  - [Caminho do executável do Therion](#caminho-do-executável-do-therion)
  - [Parâmetros de execução do Therion](#parâmetros-de-execução-do-therion)

## Usando as configurações

As alterações feitas na página de configurações não são aplicadas imediatamente. Elas ficam como valores em rascunho até que você as salve ou aplique explicitamente.

### Redefinindo uma configuração individual
Cada configuração possui um botão de redefinição (↺) à sua direita. Clicar nele reverte aquela configuração para seu valor padrão no rascunho, sem salvar.

### Botões
* **Salvar e fechar**: aplica todas as alterações do rascunho e fecha a página de configurações. Se algum campo contiver um valor inválido, o salvamento é bloqueado e os campos inválidos são destacados.
* **Aplicar**: aplica todas as alterações do rascunho, mas mantém a página de configurações aberta.
* **Cancelar**: descarta todas as alterações do rascunho e fecha a página de configurações.
* **Redefinir todas as configurações**: reverte todas as configurações para seus valores padrão no rascunho, sem salvar.

## Seção Principal

### Idioma
Seleciona o idioma usado em toda a interface do aplicativo. A opção padrão segue o idioma do sistema. A alteração desta configuração tem efeito após aplicar e reabrir as páginas atualmente abertas.

## Seção Edição TH2

### Espessura da linha
Controla a espessura visual (em pixels) das linhas desenhadas no canvas. Esta é uma configuração apenas de exibição e não afeta os dados armazenados no arquivo TH2.

### Método de criação de nova linha
Controla o comportamento ao criar um novo segmento de linha clicando e arrastando:
* **Quadrático do Mapiah**: a posição do arrasto é usada como o único ponto de controle de uma aproximação de curva Bézier quadrática.
* **Cúbico suave do xTherion**: a posição do arrasto torna-se o futuro ponto de controle do próximo segmento; o outro ponto de controle do segmento atual é espelhado em torno do ponto final compartilhado. Mantenha _Ctrl_ pressionado durante o arrasto para fixar a distância do ponto de controle espelhado. Este método tenta reproduzir o comportamento do XTherion.

### Raio do ponto
Controla o raio visual (em pixels) dos pontos desenhados no canvas. Esta é uma configuração apenas de exibição e não afeta os dados armazenados no arquivo TH2.

### Ângulo preferencial
Controla o incremento angular (em graus) usado no ajuste da rotação da imagem. Ao rotacionar uma imagem, mantenha _Ctrl_ pressionado para ajustar o ângulo a múltiplos deste valor. Defina como `0` para desativar o ajuste mesmo com _Ctrl_ pressionado.

### Tolerância de seleção
Controla o quão próximo o cursor do mouse deve estar de um elemento (em pixels) para que ele seja considerado clicado e selecionado. Aumentar este valor torna os elementos mais fáceis de clicar.

### Mostrar marcas de direção em linhas não selecionadas
Quando ativado, as marcas de direção são desenhadas em todas as linhas do croqui ativo, independentemente da seleção. Quando desativado (padrão), apenas as linhas selecionadas mostram marcas de direção. Também pode ser alternado com **Ctrl+Alt+R**.

## Seção Therion

### Caminho do executável do Therion
O caminho completo para o executável do Therion no seu sistema. Necessário para que o recurso _Executar Therion_ funcione. Clique no ícone de pasta ou toque no campo para abrir um seletor de arquivo e navegar até o binário do Therion.

### Parâmetros de execução do Therion
Opções extras opcionais de linha de comando passadas ao Therion a cada execução (ex.: `-d` para modo de depuração, `-q` para modo silencioso). Múltiplas opções podem ser inseridas separadas por espaço. O valor também pode ser editado diretamente no diálogo Executar Therion e pode ser predefinido pelo argumento de linha de comando `--therion_run_parameters` do Mapiah. O padrão é vazio (sem opções extras).