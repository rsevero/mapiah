FROM ubuntu:24.04

USER root

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

ENV FLUTTER_VERSION=3.32.1

RUN set -o xtrace \
    && sh -c 'echo "en_US.UTF-8 UTF-8" > /etc/locale.gen' \
    && cd /opt \
    && apt-get update \
    && apt-get install -y locales \
    && update-locale LANG=en_US.UTF-8 \
    && apt-get install -y curl git unzip xz-utils zip libglu1-mesa vim sudo \
    && apt-get install -y clang cmake git ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev \
    && rm -rf /var/lib/apt/lists/* \
    && curl -s -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz \
    && mkdir devel \
    && tar -xf flutter.tar.xz -C /opt/devel \
    && rm flutter.tar.xz \
    && useradd -m builder \
    && passwd -d builder \
    && echo "builder ALL=(ALL) ALL" >> /etc/sudoers \
    && chown -R builder:builder /opt/devel

WORKDIR /opt/devel

USER builder

ENV PATH=/opt/devel/flutter/bin:${PATH}

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en

RUN git config --global --add safe.directory /opt/devel/flutter \
    && flutter --disable-analytics \
    && flutter config --enable-linux-desktop
