<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
Página inicial do espaço de trabalho, onde são apresentados a árvore do projeto, as abas de arquivos e as ações principais.

_Observação: no Mapiah as teclas Ctrl e Meta (Command no macOS) são intercambiáveis. Nas menções de atalhos abaixo usa-se "Ctrl" por brevidade._

## Fluxo do projeto

**Abrir projeto** é o ponto de entrada normal para um projeto Therion. Selecione qualquer arquivo de configuração raiz, inclusive um arquivo sem a extensão `.thconfig`. O Mapiah carrega esse arquivo e segue recursivamente suas referências `source`, `input` e relacionadas na árvore do projeto. Abrir outro projeto substitui a árvore carregada; o ciclo de vida habitual das abas de arquivo é preservado.

A barra lateral contém nós de arquivos e nós lógicos. Nós de arquivos representam arquivos `thconfig`, `.th` e `.th2`; nós lógicos representam croquis, levantamentos, mapas e centrais encontrados nesses arquivos. Use o campo de pesquisa para filtrar e as setas para expandir ou recolher ramos. A largura e o estado recolhido da barra lateral são persistidos nas configurações. Um marcador de alteração indica alterações não salvas. Indicadores de erro identificam diagnósticos do analisador ou do compilador; arquivos ausentes e referências circulares são relatados como erros do projeto.

Clique em um arquivo `.th2` para abrir sua aba de desenho. Clique em um arquivo `thconfig` ou `.th` para abrir sua aba de texto. Clicar em um croqui, levantamento, mapa ou central seleciona a fonte correspondente e navega até sua posição quando há uma linha de origem.

Use **Executar Therion** para executar a configuração raiz do projeto carregado. No estado vazio, a ação Executar Therion da árvore abre um projeto e o executa. Com um projeto carregado, a ação executa novamente esse projeto. Os diagnósticos do compilador substituem os diagnósticos da execução anterior depois da próxima execução; editar o arquivo, por si só, não os remove.

## Arquivos `.th2` independentes

Desenhos independentes podem ser abertos clicando em um arquivo `.th2` na árvore de um projeto carregado, ou na inicialização usando um caminho posicional ou a opção `--th2`. `Ctrl/Cmd+O` abre um projeto no espaço de trabalho; não é um seletor de arquivos independentes.

```bash
mapiah arquivo.th2
mapiah --th2 arquivo.th2
```

## Barra superior

* **Abrir projeto**: abre a configuração de um projeto no espaço de trabalho. `Ctrl/Cmd+O` e `Ctrl/Cmd+Shift+O` usam essa ação.
* **Executar Therion**: executa o projeto carregado ou, quando nenhum projeto está carregado, abre um projeto e o executa.
* **Página de configurações**: abre as configurações do aplicativo.
* **Página de atalhos de teclado**: mostra os atalhos disponíveis.
* **Ajuda**: mostra esta caixa de diálogo.
* **Sobre**: mostra informações do aplicativo.

## Argumentos de Linha de Comando

Mapiah suporta argumentos de linha de comando para abrir arquivos diretamente ao iniciar.

### Argumentos Posicionais

```bash
mapiah /caminho/para/arquivo.th2          # Abre desenho TH2 independente
mapiah /caminho/para/therion.cfg          # Carrega o projeto e executa Therion
```

O Mapiah detecta arquivos TH2 pela extensão `.th2` e trata qualquer outro arquivo como uma configuração de projeto. A configuração selecionada torna-se a raiz da árvore do projeto.

### Argumentos Nomeados

#### --th2: Abrir arquivos TH2 independentes

Esta opção pode aparecer várias vezes; cada arquivo abre em uma aba de desenho separada.

```bash
mapiah --th2 arquivo1.th2 --th2 arquivo2.th2
mapiah --th2 /caminho/para/levantamento.th2
```

#### --thconfig: Carregar e executar um projeto

Use no máximo um `--thconfig` por comando. A árvore do projeto é carregada para a configuração selecionada, cujo nome não precisa terminar em `.thconfig`.

```bash
mapiah --thconfig projeto.cfg
mapiah --thconfig /caminho/para/therion.cfg
```

#### --therion_run_parameters: Definir opções de linha de comando do Therion

Define opções extras passadas ao Therion na compilação (por exemplo, `-d` para modo de depuração). O valor é persistido como a configuração `Main_TherionRunParameters`.

```bash
mapiah --therion_run_parameters "-d -q"
mapiah --thconfig projeto.cfg --therion_run_parameters "-d"
```

Se faltar o valor de uma opção obrigatória, ou se mais de um `--thconfig` for fornecido, o Mapiah sairá com um erro.
