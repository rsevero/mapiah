# Instruções de instalação
## Índice
- [Instruções de instalação](#instruções-de-instalação)
  - [Índice](#índice)
  - [Introdução](#introdução)
  - [Linux](#linux)
    - [Instalação do Therion no Linux](#instalação-do-therion-no-linux)
    - [Instalação do Mapiah no Linux](#instalação-do-mapiah-no-linux)
      - [Opção 1: Instalação do Mapiah via AppImage](#opção-1-instalação-do-mapiah-via-appimage)
  - [MacOS](#macos)
    - [Instalação do Therion no MacOS](#instalação-do-therion-no-macos)
    - [Instalação do Mapiah no MacOS](#instalação-do-mapiah-no-macos)
  - [Windows](#windows)
    - [Instalação do Therion no Windows](#instalação-do-therion-no-windows)
    - [Instalação do Mapiah no Windows](#instalação-do-mapiah-no-windows)
  - [Primeira execução do Therion (teste)](#primeira-execução-do-therion-teste)

## Introdução
Este documento fornece instruções detalhadas para a instalação do Mapiah nos 3 diferentes sistemas operacionais suportados: Linux, MacOS e Windows.

Como o Mapiah é um software para tornar mais amigável o uso do Therion, o primeiro passo é a instalação do Therion em seu sistema. O segundo passo é a instalação do Mapiah em si.

## Linux
### Instalação do Therion no Linux
Pacotes Therion para diversas distribuições Linux: [Debian GNU/Linux](http://packages.debian.org/testing/science/therion), [Arch Linux](https://aur.archlinux.org/packages/therion/), [Ubuntu](https://packages.ubuntu.com/search?keywords=therion), [Fedora](https://copr.fedorainfracloud.org/coprs/jmbegley/therion/).

Após a instalação do Therion, teste a instalação conforme descrito na seção "Primeira execução do Therion (teste)" abaixo.

### Instalação do Mapiah no Linux
Para o Linux há duas versões disponíveis do Mapiah: um arquivo AppImage e um arquivo flatpak. Ambos tem a mesma funcionalidade, mas o AppImage é mais simples de usar, enquanto o flatpak exige downloads menores para atualizações futuras.

#### Opção 1: Instalação do Mapiah via AppImage
1. Identifique a versão mais recente disponível do Mapiah na página de [lançamentos do Mapiah](https://github.com/rsevero/mapiah/releases).
2. Baixe o arquivo `.AppImage` correspondente.
3. Torne o arquivo baixado executável, por exemplo, usando o comando:
   ```bash
   chmod +x Mapiah-<versão>.AppImage
   ```
4. Execute o Mapiah com o comando:
   ```bash
    ./Mapiah-<versão>-linux-x86_64.AppImage
    ```
5. Abra no Mapiah o arquivo `cave.th2` dos dados de exemplo do Therion (veja seção "Primeira execução do Therion (teste)" abaixo).

    _Obs.:_ se sua instalação do Linux não suportar arquivos `.AppImage`, verifique na web como instalar o suporte a esses arquivos em sua distribuição específica.

#### Opção 2: Instalação do Mapiah via Flatpak
1. Instale o Flatpak em seu sistema, se ainda não estiver disponível em sua máquina. Instruções estão disponíveis em: https://flatpak.org/setup/
2. Baixe o arquivo `.flatpakref` da versão desejada do Mapiah na página de [lançamentos do Mapiah](https://github.com/rsevero/mapiah/releases).
3. Instale o Mapiah com o comando:
   ```bash
   flatpak install --user --from Mapiah-<versão>.flatpakref
   ```

## MacOS
### Instalação do Therion no MacOS
Para instalar o Therion no MacOS, siga as instruções abaixo (adaptadas das disponíveis na página do repositório [homebrew-therion](https://github.com/ladislavb/homebrew-therion)).

Por favor abra o aplicativo Terminal e siga as instruções:
1. Instale as ferramentas de linha de comando
> xcode-select --install
2. Instale o Homebrew - http://brew.sh/
> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
>
Teste a instalação com:
> brew update
> brew doctor
3. Instale o XQuartz
Se o seu macOS não contiver o servidor X11 (10.12 Sierra+), instale-o com o seguinte comando:
> brew install --cask xquartz
4. Instale o MacTeX
> brew install --cask mactex
5. Instale o tcl-tk e o bwidget
> brew install tcl-tk bwidget
6. Instale o Therion
> brew tap ladislavb/homebrew-therion
> brew install therion
7. Copiando Loch para /Applications
O Loch é instalado em <prefix>/opt/therion/loch.app/. Se você tiver uma versão mais antiga do Loch instalada em suas Aplicações, remova-a e copie a nova versão com:
> cp -R <prefix>/opt/therion/loch.app /Applications/loch.app
>
Substitua <prefix> por /usr/local para macOS Intel ou /opt/homebrew para Apple Silicon.
Após a instalação bem-sucedida, você deve ser capaz de:

    iniciar o XTherion digitando o comando xtherion na janela do Terminal
    executar o compilador Therion digitando o comando therion na janela do Terminal
    iniciar o visualizador Loch a partir do Launchpad

### Instalação do Mapiah no MacOS
1. Identifique a versão mais recente disponível do Mapiah na página de [lançamentos do Mapiah](https://github.com/rsevero/mapiah/releases).
2. Baixe o arquivo `.dmg` correspondente.
3. Abra o arquivo `.dmg` baixado e arraste o ícone do Mapiah para a pasta "Applications".
4. Execute o Mapiah a partir da pasta "Applications".
5. Abra no Mapiah o arquivo `cave.th2` dos dados de exemplo do Therion (veja seção "Primeira execução do Therion (teste)" abaixo).

## Windows
### Instalação do Therion no Windows
Baixe o instalador do Therion para Windows na página de [downloads do Therion](https://therion.speleo.sk/download.php) e siga as instruções do instalador.

### Instalação do Mapiah no Windows
1. Identifique a versão mais recente disponível do Mapiah na página de [lançamentos do Mapiah](https://github.com/rsevero/mapiah/releases).
2. Baixe o arquivo `.exe` correspondente.
3. Execute o arquivo `.exe` baixado e siga as instruções do instalador.
4. Após a instalação, execute o Mapiah a partir do menu Iniciar.
5. Abra no Mapiah o arquivo `cave.th2` dos dados de exemplo do Therion (veja seção "Primeira execução do Therion (teste)" abaixo).

## Primeira execução do Therion (teste)
Após instalar o Therion, você pode testá-lo com os [dados de exemplo](https://therion.speleo.sk/downloads/demo.zip) disponíveis na página web do Therion:
1. Baixe os dados de exemplo da página web do Therion e descompacte-os em algum lugar no disco rígido do seu computador.
2. Execute o XTherion (no Unix e MacOS X, digitando 'xtherion' na linha de comando; no Windows, há um atalho no menu Iniciar).
3. Abra o arquivo 'thconfig' do diretório de dados de exemplo.
4. Pressione 'F9' ou clique em 'compile' no menu para executar o Therion nos dados — você verá algumas mensagens do Therion, MetaPost e TeX.
5. Mapas em PDF e um modelo 3D serão criados no diretório de dados de exemplo.
