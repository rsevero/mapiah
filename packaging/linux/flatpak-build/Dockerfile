FROM rsevero847/mapiah-flutter-build:20.04

USER root

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en

ENV PATH=/opt/devel/flutter/bin:${PATH}

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

ENV FLUTTER_VERSION=3.32.0

RUN set -o xtrace \
    && cd /opt \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y flatpak flatpak-builder \
    && rm -rf /var/lib/apt/lists/* \
    && flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo \
    && flatpak install -y org.freedesktop.Sdk/x86_64/24.08 \
    && flatpak install -y org.freedesktop.Platform/x86_64/24.08 \
    && flatpak install -y flathub org.freedesktop.appstream-glib
