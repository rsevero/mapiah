<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
Página inicial do aplicativo, onde são apresentadas as principais funções.

_Observação: no Mapiah as teclas Ctrl e Meta (Command no macOS) são intercambiáveis. Nas menções de atalhos abaixo usa-se "Ctrl" por brevidade._

## Barra superior
* ![Ícone novo arquivo](assets/help/images/iconNewFile.png "Novo arquivo") _Novo arquivo_: cria um novo projeto.
* ![Ícone abrir arquivo](assets/help/images/iconOpenFile.png "Abrir arquivo")  _Abrir arquivo_: mostra a caixa de diálogo do sistema para escolher qual arquivo(s) será(ão) aberto(s). Você pode selecionar múltiplos arquivos de uma vez (usando Ctrl+Clique ou Shift+Clique) para abri-los simultaneamente em abas separadas.
* ![Ícone escolher THConfig e executar Therion](assets/help/images/iconChooseTHConfigAndRunTherion.png "Escolher THConfig e executar Therion") _Escolher THConfig e executar Therion_: mostra a caixa de diálogo do sistema para escolher qual arquivo THConfig será usado para executar o Therion.
* ![Ícone executar Therion](assets/help/images/iconRunTherion.png "Executar Therion") _Executar Therion_: executa o Therion com o projeto atualmente aberto.
* ![Ícone página de configurações](assets/help/images/iconSettings.png "Página de configurações") _Página de configurações_: mostra a página de configurações, onde é possível alterar as configurações do aplicativo.
* ![Ícone página de atalhos de teclado](assets/help/images/iconKeyboardShortcuts.png "Página de atalhos de teclado") _Página de atalhos de teclado_: mostra a página de atalhos de teclado, onde é possível ver todos os atalhos disponíveis.
* ![Ícone ajuda](assets/help/images/iconHelp.png "Ajuda") _Ajuda_: mostra esta caixa de diálogo.
* ![Ícone sobre](assets/help/images/iconAbout.png "Sobre") _Sobre_: metainformações do aplicativo.

## Abrindo Múltiplos Arquivos

Você pode abrir múltiplos arquivos TH2 ao mesmo tempo. Quando você clica no botão _Abrir arquivo_, a caixa de diálogo de seleção de arquivo permite que você selecione mais de um arquivo:

* Segure **Ctrl** e clique nos arquivos para selecionar múltiplos arquivos individualmente
* Segure **Shift** e clique para selecionar um intervalo de arquivos
* Clique em **Abrir** para abrir todos os arquivos selecionados em abas separadas

Todos os arquivos selecionados serão abertos no editor de arquivo com cada arquivo tendo sua própria aba. Você pode facilmente alternar entre os arquivos abertos clicando em suas abas, ou usar navegação por teclado para se mover entre eles.

## Argumentos de Linha de Comando

Mapiah suporta argumentos de linha de comando para abrir arquivos diretamente ao iniciar:

### Argumentos Posicionais (Compatibilidade com Versões Anteriores)
```bash
mapiah /caminho/para/arquivo.th2          # Abre arquivo TH2
mapiah /caminho/para/therion.cfg          # Executa Therion com config
```

Ele detecta arquivos TH2 por sua extensão .th2, e trata qualquer outro arquivo como um THConfig para executar o Therion. Isso permite compatibilidade com versões anteriores do Mapiah que só aceitavam um único argumento posicional.

### Argumentos Nomeados

#### --th2: Abrir arquivos TH2
- Pode aparecer múltiplas vezes para abrir vários arquivos
- Cada arquivo abre em uma aba separada

```bash
mapiah --th2 arquivo1.th2 --th2 arquivo2.th2
mapiah --th2 /caminho/para/levantamento.th2
```

#### --thconfig: Executar Therion com THConfig
- Máximo de um --thconfig por comando
- Mostrará erro se múltiplos argumentos --thconfig forem fornecidos

```bash
mapiah --thconfig projeto.cfg
mapiah --thconfig /caminho/para/therion.cfg
```

#### --therion_run_parameters: Definir opções de linha de comando do Therion
- Define opções extras passadas ao Therion na compilação (ex.: `-d` para modo de depuração)
- O valor é persistido como a configuração `Main_TherionRunParameters` (o mesmo campo do diálogo Executar Therion)
- Múltiplas opções podem ser fornecidas separadas por espaço

```bash
mapiah --therion_run_parameters "-d"
mapiah --therion_run_parameters "-d -q"
mapiah --thconfig projeto.cfg --therion_run_parameters "-d"
```

#### Combinando Argumentos
```bash
# Abrir múltiplos arquivos TH2 E executar Therion com config
mapiah --th2 arquivo1.th2 --th2 arquivo2.th2 --thconfig projeto.cfg
```

### Tratamento de Erros
- Se múltiplos argumentos `--thconfig` forem fornecidos, Mapiah sairá com uma mensagem de erro
- Se a flag `--th2`, `--thconfig` ou `--therion_run_parameters` for fornecida sem um valor, Mapiah sairá com uma mensagem de erro
