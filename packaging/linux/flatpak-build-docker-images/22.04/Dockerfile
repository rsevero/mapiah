FROM rsev/flutter-build:22.04

USER root

RUN set -o xtrace \
    && cd /opt \
    && apt-get update \
    && apt-get install -y flatpak \
    && rm -rf /var/lib/apt/lists/* \
    && service dbus start \
    && usermod -a -G _flatpak builder \
    && flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo \
    && flatpak install --system -y --noninteractive flathub org.flatpak.Builder 

    USER builder
    