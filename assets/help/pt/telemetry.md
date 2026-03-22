<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Telemetria — Dados de Uso Anônimos

O Mapiah pode opcionalmente coletar dados de uso anônimos e agregados para ajudar a priorizar o desenvolvimento e entender como o aplicativo é utilizado.

## O que é coletado

A cada dia que você usa o Mapiah, um único registro agregado pode ser enviado contendo:

| Campo | Descrição |
|-------|-----------|
| Data | Data UTC (ex.: 2026-03-20) |
| Tipo de SO | linux, macos ou windows |
| Versão do SO | string de versão bruta do sistema operacional |
| Distribuição Linux | nome da distribuição (apenas Linux, ex.: "Fedora Linux 43") |
| Gerenciador de janelas | ambiente de desktop (apenas Linux, ex.: "KDE") |
| Versão do Mapiah | a versão do Mapiah que você está usando |
| Tipo de build | AppImage, Flatpak ou Other |
| Arquivos TH2 (únicos) | número de arquivos TH2 distintos abertos naquele dia |
| Contagem de aberturas TH2 | total de vezes que um arquivo TH2 foi aberto |
| Tempo em TH2 (minutos) | total de minutos com pelo menos um arquivo TH2 aberto |
| Arquivos THConfig (únicos) | número de arquivos THConfig distintos utilizados |
| Execuções do Therion | número de vezes que o Therion foi executado |
| Tempo no Therion (segundos) | total de segundos gastos executando o Therion |

## O que NÃO é coletado

* Seu nome, e-mail ou qualquer informação de conta
* Identificadores de dispositivo, endereços IP ou localização
* Nomes ou caminhos de arquivos
* O conteúdo de qualquer levantamento espeleológico ou arquivo TH2
* Qualquer informação que possa identificar você ou seu computador

## Como os dados são tratados

Os dados são coletados localmente ao longo do dia, e somente o registro agregado do dia anterior é transmitido. Nenhum dado parcial ou em tempo real sai do seu computador. Os registros são enviados via HTTPS para `api.mapiah.org`. Se o envio falhar (sem rede, servidor fora do ar), o Mapiah tenta novamente automaticamente a cada 15 minutos.

Quando você aceita ou recusa a telemetria pela primeira vez, uma notificação imediata (sem nenhuma informação de identificação) é enviada ao servidor para incrementar o contador anônimo de adesões ou recusas. Isso permite que o Mapiah entenda as tendências gerais de consentimento sem qualquer rastreamento individual.

## Como alterar sua escolha

Você pode ativar ou desativar a telemetria a qualquer momento na página de _Configurações_, na seção **Principal**. O botão de alternância "Compartilhar dados de uso anônimos" controla essa configuração. Você também pode clicar em "Revisar detalhes da telemetria e consentimento" na página de Configurações para ver este diálogo novamente.

Ao optar por não participar, todos os dados de telemetria armazenados localmente são excluídos imediatamente e uma notificação anônima de recusa é enviada ao servidor. Ao optar por participar novamente, uma notificação anônima de adesão é enviada.
