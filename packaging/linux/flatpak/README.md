# Flatpak build instructions

1. Update Mapiah version on the following files:
   1. pubspec.yaml
   2. packaging/linux/org.mapiah.Mapiah.desktop
   3. packaging/linux/org.mapiah.Mapiah.metainfo.xml

2. Get the git commit hash for the desired Mapiah version (usually the last one):
```
git log --pretty=format:"%H | %s | %ad | %an" --date=iso
```

3. Clone the mapiah-flatpak-build repository:
```
git clone --depth 1 -b main https://github.com/rsevero/mapiah-flatpak-build.git
```

4. Update the _mapiah_ repository commit hash at the _sources:_ section of _mapiah-flatpak-build/io.github.rsevero.mapiah/flatpak-flutter.yml_ file to the one gotten from step 2 above.

5. Update the flatpak offline manifest:
```
cd ~/devel/mapiah-flatpak-build/io.github.rsevero.mapiah; ../flatpak-flutter.py flatpak-flutter.yml
```

6. Build the flatpak app:
```
flatpak run org.flatpak.Builder --force-clean --sandbox --user --install --install-deps-from=flathub --ccache --mirror-screenshots-url=https://dl.flathub.org/media/ --repo=repo builddir io.github.rsevero.mapiah.yml
```

7. Test the flatpak app:
```
flatpak run io.github.rsevero.mapiah
```

8. Run the linters (one at a time) and solve any issues they report:
```
flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest io.github.rsevero.mapiah.yml
```
```
flatpak run --command=flatpak-builder-lint org.flatpak.Builder repo repo
```
