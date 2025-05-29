# Flatpak build instructions

## As regular user

1. Update main Flutter docker image:
```
cd ~/devel/mapiah/packaging/linux/flutter-build/20.04; docker build -t mapiah-flutter-build:20.04 .
```

2. Update flatpak build image:
```

cd ~/devel/mapiah/packaging/linux/flatpak-build; docker build -t mapiah-flatpak-build:20.04 .
```

3. Run the flatpak build image:
```
docker run -it --entrypoint /bin/bash rsevero847/mapiah-flatpak-build
```

## Inside the container

4. Clone Mapiah source code inside /opt/devel:
```
cd /opt/devel; git clone --depth 1 -b main https://github.com/rsevero/mapiah.git
```

5. Update version info at:
   1. pubspec.yaml
   2. packaging/linux/org.mapiah.Mapiah.desktop
   3. packaging/linux/org.mapiah.Mapiah.metainfo.xml

6. Build the app:
```
cd /opt/devel/mapiah; ./packaging/linux/build-flutter-app.sh
```
7. Update sha256 checksum for built app at /opt/devel/mapiah/packaging/linux/flatpak-build/org.mapiah.Mapiah.yml:
```
sha256sum /opt/devel/mapiah/Mapiah-Linux-Portable.tar.gz
```
