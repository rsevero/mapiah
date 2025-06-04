# Flatpak build instructions

1. Update Mapiah version on the following files:
   1. pubspec.yaml
   2. packaging/linux/org.mapiah.Mapiah.desktop
   3. packaging/linux/org.mapiah.Mapiah.metainfo.xml

2. Get the git commit hash for the desired Mapiah version (usually the last one):
```
git log --pretty=format:"%H | %s | %ad | %an" --date=iso
```




## As regular user

1. Update main Flutter docker image:
```
cd ~/devel/mapiah/packaging/linux/flutter-build/20.04; docker build -t flutter-build:22.04 .
```

2. Update flatpak build image:
```

cd ~/devel/mapiah/packaging/linux/flatpak-build; docker build -t mapiah-flatpak-build:22.04 .
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


