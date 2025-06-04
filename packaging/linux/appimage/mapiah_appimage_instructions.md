# Creating appimage version of Mapiah

1. Change to mapiah root dir:
```
cd ~/devel/mapiah
```
2. Build updated mapiah release:
```
flutter build linux
```
3. Copy the built release to AppDir:
```
cp -vr build/linux/x64/release/bundle ./AppDir
```
4. Copy the app icon to AppDir:
```
cp -v assets/icons/io.github.rsevero.mapiah.png ./AppDir/
```
5. Run _appimage-builder_ to create the AppImage:
```
appimage-builder --generate
```
