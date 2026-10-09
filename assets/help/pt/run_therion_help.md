<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
Esta caixa de diálogo executa o Therion com o arquivo de configuração raiz do projeto carregado e exibe sua saída em tempo real.

## Status

Mostra o estado atual da execução do Therion:

* **Executando** — o Therion está sendo executado.
* **Ok** — o Therion terminou sem avisos ou erros.
* **Aviso** — o Therion terminou, mas reportou um ou mais avisos.
* **Erro** — o Therion terminou com um ou mais erros, ou não pôde ser iniciado.

## Parâmetros de execução do Therion

Opções extras opcionais de linha de comando passadas ao Therion a cada execução (ex.: `-d` para modo de depuração). O valor é salvo como uma configuração persistente e também pode ser definido via:

* A **página de Configurações** (campo `Therion_RunParameters`).
* O argumento de linha de comando `--therion_run_parameters` do Mapiah (veja a [ajuda da página principal](mapiah_home_help) para detalhes).

## Aviso de arquivos com problemas

Quando você executa o projeto carregado e alguns de seus arquivos `.th2` que o Mapiah já carregou estão com problemas, um aviso acima da saída lista seus caminhos. O Therion pode falhar por causa deles, mas a execução começa mesmo assim. Os caminhos são texto selecionável, e uma lista longa pode ser rolada.

* Só são listados arquivos do projeto carregado que está sendo executado, e apenas os já carregados, expandindo-os na árvore do projeto ou abrindo-os em uma aba. O Mapiah não lê outros arquivos para procurar problemas.
* Nenhum aviso aparece quando você executa um arquivo de configuração que não é o projeto carregado, ou logo após escolher um projeto para executar, antes que ele seja carregado.
* A lista é obtida quando a caixa de diálogo abre. Depois de corrigir e recarregar um arquivo, a execução seguinte não o lista mais.

## Saída

O texto completo produzido pelo Therion durante a execução. Após o término, o arquivo de log do Therion é anexado, seguido dos horários de início e fim.

* As palavras **Warning** (aviso) e **Error** (erro) são destacadas em cores.
* A área de saída é rolável e seu texto pode ser selecionado.
* Clicar em um item da lista de problemas (veja abaixo) rola a saída até a linha correspondente.
* Um diagnóstico com arquivo do projeto e linha reconhecidos pode abrir essa aba de texto na linha indicada. Diagnósticos sem arquivo ou linha permanecem visíveis aqui, mas não podem ser mapeados para uma linha da árvore.

## Tempo decorrido

Mostra o tempo decorrido desde o início da execução. Atualiza ao vivo a cada segundo enquanto o Therion está executando e para quando a execução termina.

## Lista de problemas

Quando o Therion reporta avisos ou erros, eles aparecem como uma lista rolável abaixo da área de saída. Clicar em qualquer item rola a saída até aquela linha.

## Botões e atalhos de teclado

* **Reexecutar Therion** (teclado: **T**) — executa o Therion novamente com o mesmo THConfig e os parâmetros de execução atuais. Habilitado somente quando o Therion não está em execução.
* **Fechar** (teclado: **Escape**) — interrompe qualquer execução em andamento e fecha a caixa de diálogo.
* **Ctrl/Cmd+T** — quando nenhum projeto está carregado, abre um projeto e inicia o Therion. Não fica disponível para trocar de projeto depois que um projeto é carregado ou enquanto esta caixa de diálogo está ativa.

Os diagnósticos do compilador permanecem até que uma execução posterior os substitua; editar um arquivo, por si só, não comprova que o erro foi corrigido.
