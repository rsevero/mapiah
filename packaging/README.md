# Mapiah release

1. Update Mapiah version in `pubspec.yaml`.
2. Update `CHANGELOG.md` with the new version and changes.
3. Update `TODO.md` with changes.
4. Update Flutter and Mapiah version in the action/workflow files with:
   1. dart run ./scripts/update_flutter_and_mapiah_version.dart
5. Commit the previous changes with a comment like 'v0.3.0'
6. Push the previous changes
7. Create a new tag with the new version:
   ```bash
   git tag -a v0.3.0 -m "v0.3.0"
   git push origin v0.3.0
   ```
8.  After the new release has been created in GitHub:
   1. update the release title to include the version number and the name of the release;
   2. update the release description including the changelog for the release.

## Mapiah flatpak test release

1. Update Mapiah version in `pubspec.yaml` to some `-rcXX` version.
2. Update Flutter and Mapiah version in the action/workflow files with:
   1. dart run ./scripts/update_flutter_and_mapiah_version.dart
3. Commit the previous changes with a comment like 'v0.3.0'
4. Push the previous changes
5. Create a new lightweight tag with the new version:
   ```bash
   git tag v0.3.0
   git push origin v0.3.0
   ```
6. At the _~/devel/io.github.rsevero.mapiah_ repo pull any changes from the remote main branch and create new branch:
      ```bash
      git co master
      git pull
      ```
7.  At the main Mapiah repo _~/devel/mapiah_ (from the repo root) generate the Flatpak build files and copy them to the Flathub repo:
   ```bash
   ./scripts/gen_and_copy_flathub.sh
   ```
8.  At the _~/devel/io.github.rsevero.mapiah_ repo:
   1. Test the new release Flatpak build locally with:
      ```bash
      flatpak run --command=flathub-build org.flatpak.Builder --install io.github.rsevero.mapiah.yml
      flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest io.github.rsevero.mapiah.yml
      flatpak run --command=flatpak-builder-lint org.flatpak.Builder repo repo
      ```
   2. Test the test release with:
       ```bash
       flatpak run io.github.rsevero.mapiah
      ```
