# Mapiah release

1. Update Mapiah version in `pubspec.yaml`.
2. Update `CHANGELOG.md` with the new version and changes.
3. Update `TODO.md` with changes.
4. Update Flutter version in:
   1. .github/workflows/linux.yml
   2. .github/workflows/windows.yml
   3. codemagic.yaml
5. Commit the previous changes with a comment like 'v0.2.22'
6. Push the previous changes
7. Create a new tag with the new version:
   ```bash
   git tag -a v0.2.22 -m "v0.2.22"
   git push origin v0.2.22
   ```
8. After the new release has been created in GitHub:
   1. update the release title to include the version number and the name of the release;
   2. update the release description including the changelog for the release.

