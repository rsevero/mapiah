FROM ubuntu:22.04

USER root

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

ENV HOME=/home/flutter

RUN set -o xtrace \
    && sh -c 'echo "en_US.UTF-8 UTF-8" > /etc/locale.gen' \
    && cd /opt \
    && apt-get update \
    && apt-get install -y locales \
    && update-locale LANG=en_US.UTF-8 \
    && apt-get install -y curl git unzip xz-utils zip libglu1-mesa vim sudo \
    && apt-get install -y clang cmake git ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev \
    && rm -rf /var/lib/apt/lists/*

# The Github runner clones the repository with uid 1001 and gid 1001. This uid 1001 needs to be the set to the container user to give ownership to the repository folder.
# See https://github.com/actions/checkout/issues/766
RUN groupadd --gid 1001 flutter \
    && useradd --create-home \
    --shell /bin/bash \
    --uid 1001 \
    --gid flutter \
    flutter \
    && passwd -d flutter \
    && echo "flutter ALL=(ALL) ALL" >> /etc/sudoers

ARG flutter_version

ENV FLUTTER_ROOT="$HOME/flutter"

ENV PATH=${HOME}/flutter/bin:${PATH}

RUN git clone \
    --depth 1 \
    --branch "$flutter_version" \
    https://github.com/flutter/flutter.git \
    "$FLUTTER_ROOT" \
    && chown -R flutter:flutter "$HOME"

USER flutter:flutter

ENV PATH=${HOME}/flutter/bin:${PATH}

RUN flutter --version \
    && flutter config --no-cli-animations \
    && dart --disable-analytics \
    && flutter config \
    --no-cli-animations \
    --no-analytics \
    --no-enable-android \
    --no-enable-web \
    --no-enable-linux-desktop \
    --no-enable-windows-desktop \
    --no-enable-fuchsia \
    --no-enable-custom-devices \
    --no-enable-ios \
    --no-enable-macos-desktop \
    && flutter doctor

RUN flutter config --enable-linux-desktop \
    && flutter precache \
    && flutter doctor

RUN  flutter config --enable-web \
    && flutter precache \
    && flutter doctor

RUN cd "$HOME" \
    && curl -L -o appimage-builder-x86_64.AppImage \
    https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.1.0/appimage-builder-1.1.0-x86_64.AppImage \
    && chmod +x appimage-builder-x86_64.AppImage \
    && sudo mv appimage-builder-x86_64.AppImage /usr/local/bin/appimage-builder

RUN sudo apt-get update \
    && sudo apt-get install -y appstream appstream-util libappstream-glib8 fuse libfuse2 \
    && sudo rm -rf /var/lib/apt/lists/* \
    && sudo addgroup fuse \
    && sudo adduser flutter fuse
