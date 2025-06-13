# Flatpak build instructions

1. Update Mapiah version on the following files:
   1. pubspec.yaml
   2. packaging/linux/org.mapiah.Mapiah.metainfo.xml
   3. packaging/windows/mapiah.iss

2. Get the git commit hash for the desired Mapiah version (usually the last one):
```
git log --pretty=format:"%H | %s | %ad | %an" --date=iso
```

3. Update _packaging/linux/flatpak/io.github.rsevero.mapiah/flatpak-flutter.yml_ file:
   1. the _mapiah_ repository commit hash at the _sources:_ section to the one gotten from step 2 above.
   2. the Flutter version on the _tag:_ setting inside _sources_

4. Update the flatpak-flutter repository.

5. Copy the Mapiah info to the flatpak-flutter repository:
```
rm -rf ~/devel/flatpak-flutter/io.github.rsevero.mapiah; mkdir -p ~/devel/flatpak-flutter/io.github.rsevero.mapiah; cp -vr ~/devel/mapiah/packaging/linux/flatpak/io.github.rsevero.mapiah/* ~/devel/flatpak-flutter/io.github.rsevero.mapiah
```

6. Update the flatpak offline manifest:
```
cd ~/devel/flatpak-flutter/io.github.rsevero.mapiah; ../flatpak-flutter.py flatpak-flutter.yml
```

7. Build the flatpak app:
```
flatpak run org.flatpak.Builder --force-clean --sandbox --user --install --install-deps-from=flathub --ccache --mirror-screenshots-url=https://dl.flathub.org/media/ --repo=repo builddir io.github.rsevero.mapiah.yml
```

8. Test the flatpak app:
```
flatpak run io.github.rsevero.mapiah
```

9. Run the linters (one at a time) and solve any issues they report:
```
flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest io.github.rsevero.mapiah.yml
```
```
flatpak run --command=flatpak-builder-lint org.flatpak.Builder repo repo
```

10.   Copy newly created build manifest and support info to ~/devel/io.github.rsevero.mapiah:
```
cd ~/devel/flatpak-flutter/io.github.rsevero.mapiah; cp -v flutter-sdk-*.json flutter-shared.sh.patch io.github.rsevero.mapiah.yml package_config.json pubspec-sources.json ~/devel/io.github.rsevero.mapiah
```
