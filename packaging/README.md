# Mapiah release

1. Update Mapiah version in `pubspec.yaml`.
2. Update `CHANGELOG.md` with the new version and changes.
3. Update Flutter version in:
   1. .github/workflows/linux_and_web.yml
   2. .github/workflows/windows.yml
   3. codemagic.yaml
4. Push the previous changes
5. Create a new tag with the new version:
   ```bash
   git tag -a v0.2.6 -m "v0.2.6"
   git push origin v0.2.6
   ```
