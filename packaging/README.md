# Mapiah release

1. Update Mapiah version in `pubspec.yaml`.
2. Update `CHANGELOG.md` with the new version and changes.
3. Update `TODO.md` with changes.
4. Update Flutter and Mapiah version in the action/workflow files with:
   1. dart run ./scripts/update_flutter_and_mapiah_version.dart
5. Update release info at _./packaging/linux/io.github.rsevero.mapiah.metainfo.xml_ with _CHANGELOG_ info.
6. Commit the previous changes with a comment like 'v0.2.22'
7. Push the previous changes
8. Create a new tag with the new version:
   ```bash
   git tag -a v0.2.22 -m "v0.2.22"
   git push origin v0.2.22
   ```
9. At the _~/devel/io.github.rsevero.mapiah_ repo pull any changes from the remote main branch and create new branch:
      ```bash
      git pull
      git co -b v0.2.22
      ```
10. At the main Mapiah repo _~/devel/mapiah_ generate the Flatpak build files and copy them to the Flathub repo:
   ```bash
   ./scripts/gen_and_copy_flathub.sh
   ```
11. At the _~/devel/io.github.rsevero.mapiah_ repo: 
   1. Test the new release Flatpak build locally with:
      ```bash
      flatpak run --command=flathub-build org.flatpak.Builder --install io.github.rsevero.mapiah.yml
      flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest io.github.rsevero.mapiah.yml
      flatpak run --command=flatpak-builder-lint org.flatpak.Builder repo repo
      flatpak run io.github.rsevero.mapiah
      ```
   2. If everything is OK, push the changes to the Flathub repo:
      ```bash
      git status
      git add -A
      git status
      git commit -m "v0.2.22"
      git push --set-upstream origin v0.2.22
      ```
   3. Create a Pull Request in the Flathub repo and get it merged.
   4. Prepare _io.github.rsevero.mapiah_ repo for future release switching it back to main branch:
      ```bash
      git co main
      git pull
      git br -d v0.2.22
      ```
12. After the new release has been created in GitHub:
   1. update the release title to include the version number and the name of the release;
   2. update the release description including the changelog for the release.

