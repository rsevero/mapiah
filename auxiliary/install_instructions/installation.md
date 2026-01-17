# Installation instructions
## Table of contents
- [Installation instructions](#installation-instructions)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Linux](#linux)
    - [Installing Therion on Linux](#installing-therion-on-linux)
    - [Installing Mapiah on Linux](#installing-mapiah-on-linux)
      - [Option 1: Install Mapiah via AppImage](#option-1-install-mapiah-via-appimage)
      - [Option 2: Install Mapiah via Flatpak](#option-2-install-mapiah-via-flatpak)
  - [macOS](#macos)
    - [Installing Therion on macOS](#installing-therion-on-macos)
    - [Installing Mapiah on macOS](#installing-mapiah-on-macos)
  - [Windows](#windows)
    - [Installing Therion on Windows](#installing-therion-on-windows)
    - [Installing Mapiah on Windows](#installing-mapiah-on-windows)
  - [First run of Therion (test)](#first-run-of-therion-test)
  - [Updating Mapiah](#updating-mapiah)

## Introduction
This document provides detailed instructions for installing Mapiah on the three supported operating systems: Linux, macOS, and Windows.

Since Mapiah is software intended to make working with Therion more user-friendly, the first step is to install Therion on your system. The second step is to install Mapiah itself.

## Linux
### Installing Therion on Linux
Therion packages for several Linux distributions: [Debian GNU/Linux](http://packages.debian.org/testing/science/therion), [Arch Linux](https://aur.archlinux.org/packages/therion/), [Ubuntu](https://packages.ubuntu.com/search?keywords=therion), [Fedora](https://copr.fedorainfracloud.org/coprs/jmbegley/therion/).

After installing Therion, test the installation as described in the "First run of Therion (test)" section below.

### Installing Mapiah on Linux
For Linux there are two available Mapiah builds: an AppImage file and a Flatpak file. Both provide the same functionality, but the AppImage is simpler to use, while Flatpak downloads are usually smaller, especially on future updates.

#### Option 1: Install Mapiah via AppImage
1. Find the latest available Mapiah version on the [Mapiah releases page](https://github.com/rsevero/mapiah/releases).
2. Download the corresponding `.AppImage` file.
3. Make the downloaded file executable, for example:
   ```bash
   chmod +x Mapiah-<version>.AppImage
   ```
4. Run Mapiah:
   ```bash
   ./Mapiah-<version>-linux-x86_64.AppImage
   ```
5. In Mapiah, open the `cave.th2` file from Therion's sample data (see the "First run of Therion (test)" section below).

    _Note:_ If your Linux installation does not support `.AppImage` files, look up how to enable AppImage support for your specific distribution.

#### Option 2: Install Mapiah via Flatpak
1. Install Flatpak on your system if it is not already available. Instructions are available at: https://flatpak.org/setup/
2. Download the `.flatpakref` file for the desired Mapiah version from the [Mapiah releases page](https://github.com/rsevero/mapiah/releases).
3. Install Mapiah:
   ```bash
   flatpak install --user --from Mapiah-<version>.flatpakref
   ```

## macOS
### Installing Therion on macOS
To install Therion on macOS, follow the instructions below (adapted from the [homebrew-therion](https://github.com/ladislavb/homebrew-therion) repository page).

Please open the Terminal app and follow these instructions:
1. Install the command line tools:
> xcode-select --install
2. Install Homebrew - http://brew.sh/
> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
>
Test the installation with:
> brew update
> brew doctor
3. Install XQuartz
If your macOS does not include the X11 server (10.12 Sierra+), install it with:
> brew install --cask xquartz
4. Install MacTeX
> brew install --cask mactex
5. Install tcl-tk and bwidget
> brew install tcl-tk bwidget
6. Install Therion
> brew tap ladislavb/homebrew-therion
> brew install therion
7. Copy Loch to /Applications
Loch is installed at `<prefix>/opt/therion/loch.app/`. If you have an older Loch version installed in Applications, remove it and copy the new version with:
> cp -R <prefix>/opt/therion/loch.app /Applications/loch.app
>
Replace `<prefix>` with `/usr/local` for Intel macOS or `/opt/homebrew` for Apple Silicon.

After a successful installation, you should be able to:

    start XTherion by typing the `xtherion` command in Terminal
    run the Therion compiler by typing the `therion` command in Terminal
    start the Loch viewer from Launchpad

### Installing Mapiah on macOS
1. Find the latest available Mapiah version on the [Mapiah releases page](https://github.com/rsevero/mapiah/releases).
2. Download the corresponding `.dmg` file.
3. Open the downloaded `.dmg` file and drag the Mapiah icon to the Applications folder.
4. Run Mapiah from the Applications folder.
5. In Mapiah, open the `cave.th2` file from Therion's sample data (see the "First run of Therion (test)" section below).

## Windows
### Installing Therion on Windows
Download the Therion installer for Windows from the [Therion downloads page](https://therion.speleo.sk/download.php) and follow the installer's instructions.

### Installing Mapiah on Windows
1. Find the latest available Mapiah version on the [Mapiah releases page](https://github.com/rsevero/mapiah/releases).
2. Download the corresponding `.exe` file.
3. Run the downloaded `.exe` and follow the installer's instructions.
4. After installation, start Mapiah from the Start menu.
5. In Mapiah, open the `cave.th2` file from Therion's sample data (see the "First run of Therion (test)" section below).

## First run of Therion (test)
After installing Therion, you can test it with the [sample data](https://therion.speleo.sk/downloads/demo.zip) available on the Therion website:
1. Download the sample data from the Therion website and unzip it somewhere on your disk.
2. Run XTherion (on Unix and macOS, type `xtherion` on the command line; on Windows, there is a shortcut in the Start menu).
3. Open the `thconfig` file from the sample data directory.
4. Press `F9` or click `compile` in the menu to run Therion on the data — you will see some messages from Therion, MetaPost, and TeX.
5. PDF maps and a 3D model will be created in the sample data directory.

## Updating Mapiah
To update Mapiah, follow the same installation instructions for your operating system, downloading the latest available version from the [Mapiah releases page](https://github.com/rsevero/mapiah/releases).
