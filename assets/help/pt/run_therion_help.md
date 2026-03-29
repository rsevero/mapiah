<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
Esta caixa de diálogo executa o Therion com o arquivo THConfig selecionado e exibe sua saída em tempo real.

## Status

Mostra o estado atual da execução do Therion:

* **Executando** — o Therion está sendo executado.
* **Ok** — o Therion terminou sem avisos ou erros.
* **Aviso** — o Therion terminou, mas reportou um ou mais avisos.
* **Erro** — o Therion terminou com um ou mais erros, ou não pôde ser iniciado.

## Parâmetros de execução do Therion

Opções extras opcionais de linha de comando passadas ao Therion a cada execução (ex.: `-d` para modo de depuração). O valor é salvo como uma configuração persistente e também pode ser definido via:

* A **página de Configurações** (campo `Main_TherionRunParameters`).
* O argumento de linha de comando `--therion_run_parameters` do Mapiah (veja a [ajuda da página principal](mapiah_home_help) para detalhes).

## Saída

O texto completo produzido pelo Therion durante a execução. Após o término, o arquivo de log do Therion é anexado, seguido dos horários de início e fim.

* As palavras **Warning** (aviso) e **Error** (erro) são destacadas em cores.
* A área de saída é rolável e seu texto pode ser selecionado.
* Clicar em um item da lista de problemas (veja abaixo) rola a saída até a linha correspondente.

## Tempo decorrido

Mostra o tempo decorrido desde o início da execução. Atualiza ao vivo a cada segundo enquanto o Therion está executando e para quando a execução termina.

## Lista de problemas

Quando o Therion reporta avisos ou erros, eles aparecem como uma lista rolável abaixo da área de saída. Clicar em qualquer item rola a saída até aquela linha.

## Botões e atalhos de teclado

* **Reexecutar Therion** (teclado: **T**) — executa o Therion novamente com o mesmo THConfig e os parâmetros de execução atuais. Habilitado somente quando o Therion não está em execução.
* **Fechar** (teclado: **Escape**) — interrompe qualquer execução em andamento e fecha a caixa de diálogo.
* Teclado: **Ctrl+T** — fecha a caixa de diálogo e reabre o seletor de arquivo THConfig para escolher um arquivo diferente.
